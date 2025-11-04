/* Formatted on 8/12/2025 5:48:24 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.API$ACT_RPT
IS
    -- Author  : PAVLO
    -- Created : 19.07.2023 16:48:37
    -- Purpose : Підготовка друкованих форм для актів
    --в пакеті всі документи по індівідуальним планам (ACT_IP_*) та документі до NDT=859 включно

    c_chr10   CONSTANT VARCHAR2 (10) := '\par';

    TYPE r_Person_For_Act IS RECORD
    (
        Atp_Id                 At_Person.Atp_Id%TYPE,
        Atp_Sc                 At_Person.Atp_Sc%TYPE,
        Atp_App                At_Person.Atp_App%TYPE,
        Atp_App_Tp             At_Person.Atp_App_Tp%TYPE,
        Pib                    VARCHAR2 (250),                           --ПІБ
        LN                     VARCHAR2 (50),                       --Прізвище
        Fn                     VARCHAR2 (50),                           --ім"я
        Mn                     VARCHAR2 (50),                    --По батькові
        Birth_Dt               DATE,                         --Дата народження
        Birth_Dt_Str           VARCHAR2 (10),                --Дата народження
        Sex                    VARCHAR2 (20),
        Atp_Citizenship        At_Person.Atp_Citizenship%TYPE,  --Громадянство
        Is_Disabled            VARCHAR2 (90),                   --Інвалідність
        Is_Capable             VARCHAR2 (90),                   --Дієздатність
        Is_Disordered          VARCHAR2 (90), --Когнітивні порушення/ психічні розлади
        Atp_Disorder_Record    At_Person.Atp_Disorder_Record%TYPE,
        Is_Vpo                 VARCHAR2 (90),      --Перебування на обліку ВПО
        Is_Orphan              VARCHAR2 (90), --Ознака сироти чи позбавлення батьківського піклування
        Is_Selfservice         VARCHAR2 (90), --Здатність до самообслуговування
        Live_Address           At_Person.Atp_Live_Address%TYPE, --Місце проживання
        Fact_Address           At_Person.Atp_Fact_Address%TYPE, -- Фактична адреса проживання
        Work_Place             At_Person.Atp_Work_Place%TYPE, --Місце навчання та / або місце роботи
        Is_Adr_Matching        VARCHAR2 (20), --Реєстрація за місцем проживання
        Phone                  At_Person.Atp_Phone%TYPE, --Контактний номер телефону
        Email                  At_Person.Atp_Email%TYPE,
        Relation_Tp            VARCHAR2 (90),               --Родинний зв’язок
        Atp_App_Tp_Name        VARCHAR2 (90),                   --Тип учасника
        Atp_Disable_Record     VARCHAR2 (250),
        At_Live_Address        act.At_Live_Address%TYPE,    --Місце проживання
        history_status         at_person.history_status%TYPE,
        atp_num                NUMBER
    );

    TYPE t_Person_For_Act IS TABLE OF r_Person_For_Act;

    TYPE Tvarchar2 IS TABLE OF VARCHAR2 (4000);

    TYPE Tint IS TABLE OF INTEGER;

    TYPE Rrefer IS RECORD
    (
        Id      NUMBER,
        Decr    VARCHAR2 (4000),
        Ord     INTEGER
    );

    TYPE Trefer IS TABLE OF Rrefer;

    C_TEST             INTEGER := 0; --для відладки, 1 - ф-ції будуть виводити значення nda

    TYPE R_Km IS RECORD
    (
        Pib         VARCHAR2 (250),                                      --ПІБ
        LN          at_other_spec.atop_fn%TYPE,                     --Прізвище
        Fn          at_other_spec.atop_fn%TYPE,                         --ім"я
        Mn          at_other_spec.atop_mn%TYPE,                  --По батькові
        position    at_other_spec.atop_position%TYPE,                 --посада
        phone       at_other_spec.atop_phone%TYPE
    );

    --заміна c_ekr1/c_ekr2/c_ekr3 на ісходні символи
    PROCEDURE Replace_Ekr (p_Result IN OUT BLOB);

    --повертає галочку для друку
    FUNCTION Cnst_Check
        RETURN VARCHAR2;

    --повертає \par для друку
    FUNCTION cnst_par
        RETURN VARCHAR2;

    --повертає підкреслене p_str  p_undrl = TRUE
    FUNCTION Underline (p_Str VARCHAR2, p_Undrl BOOLEAN)
        RETURN VARCHAR2;

    --повертає підкреслене p_str  p_undrl = 1
    FUNCTION Underline (p_Str VARCHAR2, p_Undrl NUMBER)
        RETURN VARCHAR2;

    --повертає підкреслене p_str  p_undrl = 1
    FUNCTION UnderLine_ds (p_str VARCHAR2, p_undrl NUMBER)
        RETURN VARCHAR2;

    FUNCTION mOthers (p_var1    VARCHAR2,
                      p_var2    VARCHAR2,
                      p_delmt   VARCHAR2:= c_chr10)
        RETURN VARCHAR2;

    FUNCTION mOthers_ds (p_pib1    VARCHAR2,
                         p_var1    VARCHAR2,
                         p_pib2    VARCHAR2,
                         p_var2    VARCHAR2,
                         p_delmt   VARCHAR2:= c_chr10)
        RETURN VARCHAR2;

    FUNCTION Getcupib (p_Cu_Id NUMBER)
        RETURN VARCHAR2;

    --дата в форматі dd місяць yyyy(p_tp = 2)/dd місяця yyyy(p_tp = 1)
    FUNCTION Date2str (p_Date DATE, p_Tp INTEGER:= 1)
        RETURN VARCHAR2;

    -- info:   отримання інформації по катоттг
    -- params: p_kaot_id - ід катоттг
    FUNCTION Get_Katottg_Info (p_Kaot_Id NUMBER)
        RETURN VARCHAR2;

    -- info:   отримання інформації по вулиці
    -- params: p_ns_id - ідентифікатор вулиці
    FUNCTION Get_Street_Info (p_Ns_Id NUMBER)
        RETURN VARCHAR2;

    FUNCTION Get_Adr (p_Ind     VARCHAR2,
                      p_Katot   VARCHAR2,
                      p_Strit   VARCHAR2,
                      p_Bild    VARCHAR2,
                      p_Korp    VARCHAR2,
                      p_Kv      VARCHAR2)
        RETURN VARCHAR2;

    --прізвище та ініціали
    FUNCTION Getpib (p_Pib VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION Getscpib (p_Sc_Id NUMBER)
        RETURN VARCHAR2;

    --Власне ім’я прізвище
    FUNCTION Get_Ipr (p_Pib VARCHAR2)
        RETURN VARCHAR2;

    -- кейс-менеджер (Фахівець, який здійснює оцінку потреб)
    --з таблиці At_Other_Spec -> Uss_Ndi.v_ddn_atop_apop_tp 'CCM'
    FUNCTION Get_Km (p_At_Id NUMBER)
        RETURN R_Km;

    PROCEDURE Addparam (p_Param_Name VARCHAR2, p_Param_Value VARCHAR2);

    --надавач послуги
    FUNCTION Get_Nsp_Name (p_rnspm_id uss_rnsp.v_rnsp.rnspm_id%TYPE)
        RETURN VARCHAR2;

    FUNCTION Getatsection (p_At_Id   Act.At_Id%TYPE,
                           p_Atp     At_Person.Atp_Id%TYPE:= -1,
                           p_Nng     At_Section.Ate_Nng%TYPE)
        RETURN At_Section%ROWTYPE;

    --повертає at_section.atef_feature.ate_chield_info
    FUNCTION Get_Atsctchld (p_At_Id   Act.At_Id%TYPE,
                            p_Atp     At_Person.Atp_Id%TYPE:= -1,
                            p_Nng     At_Section.Ate_Nng%TYPE)
        RETURN VARCHAR2;

    --повертає at_section.atef_feature.ate_parent_info
    FUNCTION Get_Atsctprnt (p_At_Id   Act.At_Id%TYPE,
                            p_Atp     At_Person.Atp_Id%TYPE:= -1,
                            p_Nng     At_Section.Ate_Nng%TYPE)
        RETURN VARCHAR2;

    --повертає at_section.atef_feature.ate_notes
    FUNCTION Get_Atsctnt (p_At_Id   Act.At_Id%TYPE,
                          p_Nng     At_Section.Ate_Nng%TYPE,
                          p_Atp     At_Person.Atp_Id%TYPE:= -1)
        RETURN VARCHAR2;

    --повертає at_section_feature.atef_notes
    FUNCTION Get_Ftr_Nt (p_At_Id   Act.At_Id%TYPE,
                         p_Atp     At_Person.Atp_Id%TYPE:= -1,
                         p_Nda     NUMBER,
                         p_Nng     NUMBER:= -1)
        RETURN VARCHAR2;

    --повертає at_section_feature.atef_feature
    FUNCTION Get_Ftr (p_At_Id   Act.At_Id%TYPE,
                      p_Atp     At_Person.Atp_Id%TYPE:= -1,
                      p_Nda     NUMBER,
                      p_Nng     NUMBER:= -1)
        RETURN VARCHAR2;

    FUNCTION Get_Ftr_Chk (p_At_Id   Act.At_Id%TYPE,
                          p_Atp     At_Person.Atp_Id%TYPE:= -1,
                          p_Nda     NUMBER,
                          p_Nng     NUMBER:= -1,
                          p_Chk     VARCHAR2:= 'T')
        RETURN VARCHAR2;

    --прямокутник з галочкой / прямокутник без галочки
    FUNCTION Get_Ftr_Chk2 (p_At_Id   Act.At_Id%TYPE,
                           p_Atp     At_Person.Atp_Id%TYPE:= -1,
                           p_Nda     NUMBER,
                           p_Nng     NUMBER:= -1,
                           p_Chk     VARCHAR2:= 'T')
        RETURN VARCHAR2;

    -- перевірка на Null (прямокутник з галочкой / прямокутник без галочки)
    FUNCTION Atftrisnotnull (p_At_Id      NUMBER,
                             p_Nda        NUMBER,
                             p_def_null   VARCHAR2:= NULL)
        RETURN VARCHAR2;

    FUNCTION AtFtrNtIsNotNull (p_at_id      NUMBER,
                               p_nda        NUMBER,
                               p_def_null   VARCHAR2:= NULL)
        RETURN VARCHAR2;

    --повертає v_ndi_document_attr.nda_indicator1 у випадку, коли він зачекен
    FUNCTION Get_Ftr_Ind (p_At_Id   Act.At_Id%TYPE,
                          p_Atp     At_Person.Atp_Id%TYPE:= -1,
                          p_Nda     NUMBER,
                          p_Nng     NUMBER:= -1,
                          p_Chk     VARCHAR2:= 'T')
        RETURN NUMBER;

    FUNCTION Chk_Val (p_Chk_Val VARCHAR2, p_Val VARCHAR2)
        RETURN VARCHAR2;

    --прямокутник з галочкой / прямокутник без галочки
    FUNCTION Chk_Val2 (p_Chk_Val VARCHAR2, p_Val VARCHAR2)
        RETURN VARCHAR2;

    --список соц.послуг
    FUNCTION Atsrv_Nst_List (p_At_Id   Act.At_Id%TYPE,
                             p_Tp      NUMBER,       --1- надати, 0- відмовити
                             p_Dlm     VARCHAR2:= ', ')
        RETURN VARCHAR2;

    FUNCTION Atdocatr (p_At_Id NUMBER, p_Nda NUMBER)
        RETURN At_Document_Attr%ROWTYPE;

    FUNCTION Atdocatrstr (p_At_Id NUMBER, p_Nda NUMBER)
        RETURN VARCHAR2;

    FUNCTION Atdocatrdt (p_At_Id NUMBER, p_Nda NUMBER)
        RETURN VARCHAR2;

    FUNCTION AtDocAtrId (p_at_id NUMBER, p_nda NUMBER)
        RETURN NUMBER;

    FUNCTION Atdocatrsum (p_At_Id NUMBER, p_Nda NUMBER)
        RETURN VARCHAR2;

    FUNCTION At_Doc_Atr_Lst (p_At_Id   NUMBER,
                             p_Nda     VARCHAR2,
                             Dlmt      VARCHAR2:= ' ')
        RETURN VARCHAR2;

    FUNCTION Get_Ap_Doc_Atr_Str (p_Ap_Id   NUMBER,
                                 p_Nda     NUMBER,
                                 p_App     NUMBER:= NULL)
        RETURN VARCHAR2;

    FUNCTION Get_Atperson_Id (p_At            NUMBER,
                              p_App_Tp        VARCHAR2,
                              p_App_Tp_Only   INTEGER:= NULL)
        RETURN NUMBER;

    FUNCTION Get_Atpersonsc_Id (p_At NUMBER, p_Sc At_Person.Atp_Sc%TYPE)
        RETURN NUMBER;

    FUNCTION Get_Atperson (p_At NUMBER, p_Atp NUMBER)
        RETURN r_Person_For_Act;

    --члени родини
    FUNCTION At_Person_For_Act (p_At IN NUMBER)
        RETURN t_Person_For_Act
        PIPELINED;

    --підписант акта
    FUNCTION Get_Signers_Wucu_Pib (p_At_Id      NUMBER,
                                   p_Ati_Tp     VARCHAR2,
                                   p_Ati_Cuwu   NUMBER:= NULL,
                                   p_Ndt        NUMBER:= NULL)
        RETURN VARCHAR2;

    FUNCTION Get_At_Signers_Pers (p_At_Id NUMBER, p_Atp_Id NUMBER)
        RETURN r_Person_For_Act;

    --Строк виконання/Термін виконання для At_individual_plan.atip_term_tp (uss_ndi.v_ddn_atip_term)
    FUNCTION Get_Atip_Term (p_Atip_Id NUMBER)
        RETURN VARCHAR2;

    FUNCTION Gender (p_Val VARCHAR2)
        RETURN VARCHAR2;

    --ознака інвалідності 1/0
    FUNCTION Is_Disabled (p_Val VARCHAR2)
        RETURN NUMBER;

    --Група інвалідності (p_all =1 пошук по усіх, 0 - віключити з пошуку без інвалідності)
    FUNCTION Disabledgrp (p_Val VARCHAR2, p_All INTEGER:= 1)
        RETURN VARCHAR2;

    --значення довдника типу uss_ndi.dic_dv (у разі множинного вибіру значення через кому без пробілів p_val='1,4,5')
    FUNCTION v_Ddn (p_v_Ddn VARCHAR2, p_Val VARCHAR2, p_dlm VARCHAR2:= NULL)
        RETURN VARCHAR2;

    FUNCTION Get_Ndi_Doc_Atr_Name (p_Nda NUMBER)
        RETURN VARCHAR2;

    -- флажок вставки підпису з планшету
    FUNCTION get_sign_mark (p_at_id     IN NUMBER,
                            p_atp_id    IN NUMBER,
                            p_default   IN VARCHAR2 DEFAULT '______________')
        RETURN VARCHAR2;

    --#89463 АКТ оцінки потреб сім’ї  APOP
    FUNCTION Build_Act_Needs_Assessment (p_At_Id IN NUMBER)
        RETURN BLOB;

    --причина відмови ВІД надання
    FUNCTION Get_At_Reject_List (p_At_Id IN NUMBER)
        RETURN VARCHAR2;

    --#90632 «Акт оцінки потреб особи» (з висновком оцінки потреб особи) APOP
    FUNCTION Build_Act_Needs_Assessment_S2 (p_At_Id IN NUMBER)
        RETURN BLOB;

    --«Акт оцінки потреб сім’їи» (з висновком оцінки потреб особи) AVOP
    FUNCTION ACT_DOC_804_AVOP_S1 (p_at_id IN NUMBER)
        RETURN BLOB;

    --«Акт оцінки потреб сім’їи» (з висновком оцінки потреб особи) AVOP
    FUNCTION ACT_DOC_804_AVOP_S2 (p_at_id IN NUMBER)
        RETURN BLOB;

    --#91351 «Алфавітна картка отримувача соціальної послуги»
    FUNCTION Build_Act_Kard_R3 (p_At_Id IN NUMBER)
        RETURN BLOB;

    --#91353 «Картка визначення індивідуальних потреб особи/сім’ї в наданні СП натуральної допомоги»
    FUNCTION Build_Act_Kard_R4 (p_At_Id IN NUMBER)
        RETURN BLOB;

    --#92995 «Договір про надання соціальних послуг»
    FUNCTION Act_Doc_858_And_Ip (p_At_Id IN NUMBER)
        RETURN BLOB;

    --#92990 Індивідуальний план надання СП консультування
    FUNCTION Act_Ip_Doc_846_R1 (p_At_Id IN NUMBER, p_Bild_Doc NUMBER:= 1)
        RETURN BLOB;

    --#94480 ІНДИВІДУАЛЬНИЙ ПЛАН надання соціальної послуги натуральної допомоги
    FUNCTION Act_Ip_Doc_847_R1 (p_At_Id IN NUMBER, p_Bild_Doc NUMBER:= 1)
        RETURN BLOB;

    -- IC #94111
    -- 848 - Створення друкованої форми індивідуального плану для послуги 003.0 (Посередництво)
    FUNCTION Act_Ip_Doc_848_R1 (p_At_Id IN NUMBER, p_Bild_Doc NUMBER:= 1)
        RETURN BLOB;

    --#94143 План соц.супроводу сім'ї/особи у СЖО
    FUNCTION Act_Ip_Doc_857_R1 (p_At_Id IN NUMBER, p_Bild_Doc NUMBER:= 1)
        RETURN BLOB;

    -- IC #94112
    -- 865 - Створення друкованої форми індивідуального плану для послуги 004.0 (Представництво інтересів)
    FUNCTION Act_Ip_Doc_865_R1 (p_At_Id IN NUMBER, p_Bild_Doc NUMBER:= 1)
        RETURN BLOB;

    --#94139 ІНДИВІДУАЛЬНИЙ ПЛАН надання соціальної послуги надання притулку бездомним особам
    FUNCTION Act_Ip_Doc_867_R1 (p_At_Id IN NUMBER, p_Bild_Doc NUMBER:= 1)
        RETURN BLOB;

    -- #94333 ІНДИВІДУАЛЬНИЙ ПЛАН надання соціальної послуги стаціонарного догляду
    FUNCTION Act_Ip_Doc_870_R1 (p_At_Id IN NUMBER, p_Bild_Doc NUMBER:= 1)
        RETURN BLOB;

    --#94141 ІНДИВІДУАЛЬНИЙ ПЛАН соціального захисту дитини, яка опинилась у СЖО, дитини-сироти та дитини, позбавленої батьківського піклування
    FUNCTION Act_Ip_Doc_871_R1 (p_At_Id IN NUMBER, p_Bild_Doc NUMBER:= 1)
        RETURN BLOB;

    -- #94144 Індивідуальний план надання соціальної послуги підтриманого проживання осіб
    --        похилого віку та осіб з інвалідністю
    FUNCTION Act_Ip_Doc_873_R1 (p_At_Id IN NUMBER, p_Bild_Doc NUMBER:= 1)
        RETURN BLOB;

    -- #94145 Індивідуальний план надання соціальної послуги підтриманого проживання бездомних осіб
    FUNCTION Act_Ip_Doc_874_R1 (p_At_Id IN NUMBER, p_Bild_Doc NUMBER:= 1)
        RETURN BLOB;

    -- IC #94329
    -- 876 - Створення друкованої форми «План соціального супроводження прийомної сім'ї, дитячого будинку сімейного типу» для послуги 010.2
    FUNCTION Act_Ip_Doc_876_R1 (p_At_Id IN NUMBER, p_Bild_Doc NUMBER:= 1)
        RETURN BLOB;

    -- #94330 Індивідуальний план надання соціальної послуги соціального супроводу при працевлаштуванні та на робочому місці
    FUNCTION Act_Ip_Doc_878_R1 (p_At_Id IN NUMBER, p_Bild_Doc NUMBER:= 1)
        RETURN BLOB;

    -- #94331 ІНДИВІДУАЛЬНИЙ ПЛАН надання соціальної послуги соціальної адаптації
    FUNCTION Act_Ip_Doc_883_R1 (p_At_Id IN NUMBER, p_Bild_Doc NUMBER:= 1)
        RETURN BLOB;

    -- #94078 ІНДИВІДУАЛЬНИЙ ПЛАН надання соціальної послуги догляду та виховання дітей в умовах, наближених до сімейних
    FUNCTION ACT_IP_DOC_884_R1 (p_at_id IN NUMBER, p_bild_doc NUMBER:= 1)
        RETURN BLOB;

    -- #94334 ІНДИВІДУАЛЬНИЙ ПЛАН надання соціальної послуги денного догляду
    FUNCTION Act_Ip_Doc_892_R1 (p_At_Id IN NUMBER, p_Bild_Doc NUMBER:= 1)
        RETURN BLOB;

    --#94998  017.3-893-Інд.план надання СП Соц.-психолог. реабілітація наркотики_психотропи
    FUNCTION ACT_IP_DOC_893_R1 (p_at_id IN NUMBER, p_bild_doc NUMBER:= 1)
        RETURN BLOB;

    -- #94335 ІНДИВІДУАЛЬНИЙ ПЛАН надання соціальної послуги Паліативний догляд
    FUNCTION Act_Ip_Doc_894_R1 (p_At_Id IN NUMBER, p_Bild_Doc NUMBER:= 1)
        RETURN BLOB;

    -- #95002 ІНДИВІДУАЛЬНИЙ ПЛАН надання соціальної послуги перекладу жестовою мовою
    FUNCTION Act_Ip_Doc_895_R1 (p_At_Id IN NUMBER, p_Bild_Doc NUMBER:= 1)
        RETURN BLOB;

    --#94997 017.1-897-Інд.план надання СП соц.реабілітації для осіб з інтелект. та псих. порушеннями
    FUNCTION ACT_IP_DOC_897_R1 (p_at_id IN NUMBER, p_bild_doc NUMBER:= 1)
        RETURN BLOB;

    --#94999 ІНДИВІДУАЛЬНИЙ ПЛАН надання соціальної послуги тимчасового відпочинку для батьків або осіб, які їх замінюють 018.1
    FUNCTION Act_Ip_Doc_899_R1 (p_At_Id IN NUMBER, p_Bild_Doc NUMBER:= 1)
        RETURN BLOB;

    --#95000 ІНДИВІДУАЛЬНИЙ ПЛАН надання соціальної послуги супроводу під час інклюзивного навчання
    FUNCTION Act_Ip_Doc_1001_R1 (p_At_Id IN NUMBER, p_Bild_Doc NUMBER:= 1)
        RETURN BLOB;

    --#95001 ІНДИВІДУАЛЬНИЙ ПЛАН надання соціальної послуги фізичного супроводу
    FUNCTION Act_Ip_Doc_1003_R1 (p_At_Id IN NUMBER, p_Bild_Doc NUMBER:= 1)
        RETURN BLOB;

    --#94332 Інд.план надання СП соціальної інтеграції та реінтеграції бездомних осіб
    FUNCTION Act_Ip_Doc_1006_R1 (p_At_Id IN NUMBER, p_Bild_Doc NUMBER:= 1)
        RETURN BLOB;

    -- #98709 015.1- Інд_план надання СП догляду вдома
    FUNCTION ACT_IP_DOC_1012_R1 (p_at_id IN NUMBER, p_bild_doc NUMBER:= 1)
        RETURN BLOB;

    --#93536 для 1.3 колонка Наявні документи  p_tp-1 -список типів док, 2- список документів
    FUNCTION Get_Doc_803_1_3 (p_Ap_Id    IN NUMBER,
                              p_App_Id      NUMBER,
                              p_Tp          NUMBER)
        RETURN VARCHAR2;

    --#93536 «Акт про надання повнолітній особі соціальних послуг екстрено (кризово)»
    FUNCTION Act_Doc_803_R1 (p_At_Id IN NUMBER)
        RETURN BLOB;

    --#94404 ЩОДЕННИК РОБОТИ з прийомною сім'єю/дитячим будинком сімейного типу
    FUNCTION Act_Doc_834_R1 (p_At_Id IN NUMBER)
        RETURN BLOB;

    --#91350 «Карта визначення індивідуальних потреб особи в наданні СП консультування»
    FUNCTION ACT_DOC_837_R1 (p_At_Id IN NUMBER)
        RETURN BLOB;

    --#92242 «Анкета вуличного консультування»
    FUNCTION Act_Doc_838_R1 (p_At_Id IN NUMBER)
        RETURN BLOB;

    --#93919 «Направлення сім`ї/особи до іншого суб’єкта для надання соціальних послуг»
    FUNCTION Act_Doc_840_R1 (p_At_Id IN NUMBER)
        RETURN BLOB;

    --#94121 «Акт з надання соціальної послуги кризового та екстреного втручання» для послуги 012.0
    FUNCTION Act_Doc_841_R1 (p_At_Id IN NUMBER)
        RETURN BLOB;

    --#91757 «Повідомлення надавача про надання / відмову в наданні соціальних послуг»  (з автозаповнення)
    --function ACT_DOC_843_R1(p_at_id in number) return blob;
    --#96292 «Повідомлення надавача про надання / відмову в наданні соціальних послуг»  (з автозаповнення)
    FUNCTION Act_Doc_843_R2 (p_At_Id IN NUMBER)
        RETURN BLOB;

    --#93370 «Оцінка кризової ситуації СП кризового та екстреного втручання»
    FUNCTION Act_Doc_845_R1 (p_At_Id IN NUMBER)
        RETURN BLOB;

    --#95284 ІНФОРМАЦІЯ про призупинення надання СП
    FUNCTION Act_Doc_849_R1 (p_At_Id IN NUMBER)
        RETURN BLOB;

    --#91713  РІШЕННЯ про надання / відмову в наданні соціальних послуг (uss_esr.DNET$PAY_TERMINATE/FUNCTION Fill_Attrs_850)
    FUNCTION Act_Doc_850_R1 (p_At_Id IN NUMBER)
        RETURN BLOB;

    --#91716 ПОВІДОМЛЕННЯ про надання / відмову в наданні соціальних послуг  (uss_esr.DNET$PAY_TERMINATE/FUNCTION Fill_Attrs_851)
    --function ACT_DOC_851_R1(p_at_id  IN NUMBER) return blob;
    --96292 ПОВІДОМЛЕННЯ про надання / відмову в наданні соціальних послуг  (uss_esr.DNET$PAY_TERMINATE/FUNCTION Fill_Attrs_851)
    FUNCTION Act_Doc_851_R2 (p_At_Id IN NUMBER)
        RETURN BLOB;

    --#91717 Клопотання про влаштування особи з інвалідністю, особи похилого віку до інтернатної(го) установи/закладу
    FUNCTION Act_Doc_852_R1 (p_At_Id IN NUMBER)
        RETURN BLOB;

    -- #91719 Повідомлення про направлення клопотання про влаштування особи з інвалідністю, особи похилого віку до інтернатної(го) установи/закладу
    FUNCTION Act_Doc_853_R1 (p_At_Id IN NUMBER)
        RETURN BLOB;

    --#91721 ndt 854 «Путівка на влаштування до інтернатної(го) установи/закладу»  (uss_esr.DNET$PAY_TERMINATE/FUNCTION Fill_Attrs_854)
    FUNCTION Act_Doc_854_R1 (p_At_Id IN NUMBER)
        RETURN BLOB;

    --91436 Повідомлення СПСЗН про прийняття особи на обслуговування до інтернатного закладу
    FUNCTION Act_Doc_855_R1 (p_At_Id IN NUMBER)
        RETURN BLOB;

    --#91438 «Повідомлення органу ПФУ про прийняття на обслуговування до інтернатного закладу»
    FUNCTION Act_Doc_856_R1 (p_At_Id IN NUMBER)
        RETURN BLOB;

    -- #93371 «Звіт за результатами соціального супроводу сім’ї/особи»
    FUNCTION Act_Doc_859_R1 (p_At_Id IN NUMBER)
        RETURN BLOB;

    ----------------------------------------------------------------
    FUNCTION Build_Tctr (p_At_Id IN NUMBER)
        RETURN BLOB;

    FUNCTION Build_Stub (p_At_Id IN NUMBER, p_Bild_Doc NUMBER:= 1)
        RETURN BLOB;

    FUNCTION Getmonthname (p_Mnum NUMBER, p_Vidm CHAR:= 'N' -- N,R,D,Z,O,M,K (називний, родовий, давальний...)
                                                           )
        RETURN VARCHAR2;
END Api$act_Rpt;
/


GRANT EXECUTE ON USS_ESR.API$ACT_RPT TO DNET_PROXY
/

GRANT EXECUTE ON USS_ESR.API$ACT_RPT TO II01RC_USS_ESR_RPT
/

GRANT EXECUTE ON USS_ESR.API$ACT_RPT TO II01RC_USS_ESR_WEB
/

GRANT EXECUTE ON USS_ESR.API$ACT_RPT TO OKOMISAROV
/

GRANT EXECUTE ON USS_ESR.API$ACT_RPT TO PCHUBAROV
/

GRANT EXECUTE ON USS_ESR.API$ACT_RPT TO SHOST
/

GRANT EXECUTE ON USS_ESR.API$ACT_RPT TO USS_RPT
/


/* Formatted on 8/12/2025 5:48:41 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.API$ACT_RPT
IS
    -- друковані форми для актів:
    --select t.*, t.rowid from Uss_Ndi.v_Ndi_At_Print_Config t

    c_ekr1          CONSTANT VARCHAR2 (10) := '[' || CHR (1) || ']';     --"\"
    c_ekr2          CONSTANT VARCHAR2 (10) := '[' || CHR (2) || ']';     --"{"
    c_ekr3          CONSTANT VARCHAR2 (10) := '[' || CHR (3) || ']';     --"}"
    --галочка
    c_check         CONSTANT VARCHAR2 (900)
        := '{\rtlch\fcs1 \af0 \ltrch\fcs0 \lang1033\langfe1033\langnp1033\insrsid16478594 {\field{\*\fldinst SYMBOL 80 \\f "Wingdings 2" \\s 11}{\fldrslt\f157\fs22}}}' ;
    --прямокутник з галочкой
    c_chk           CONSTANT VARCHAR2 (900)
        := '{\field{\*\fldinst SYMBOL 82 \\f "Wingdings 2" \\s 12}}' ; --шрифт "Wingdings 2"
    --q'[{\rtlch\fcs1 \af0\afs24 \ltrch\fcs0 \f50\fs24\lang1033\langfe1058\langnp1033\insrsid7754010\charrsid8275394 \u9745\'3f}]'; --шрифт "Segoe UI Symbol" 12розмір

    --прямокутник без галочки
    c_unchk         CONSTANT VARCHAR2 (900)
        := --'{\field{\*\fldinst SYMBOL 48 \\f "Wingdings 2" \\s 12}}';  --прямокутник, трохи схожй не квадрат шрифт "Wingdings 2"
           q'[{\rtlch\fcs1 \af0\afs24 \ltrch\fcs0 \f50\fs24\lang1033\langfe1058\langnp1033\insrsid7754010\charrsid8275394 \u9744\'3f}]' ; --шрифт "Segoe UI Symbol" 12розмір
    c_unchk_ds      CONSTANT VARCHAR2 (900)
        := --'{\field{\*\fldinst SYMBOL 48 \\f "Wingdings 2" \\s 12}}';  --прямокутник, трохи схожй не квадрат шрифт "Wingdings 2"
           q'{\rtlch\fcs1 \af0\afs24 \ltrch\fcs0 \f50\fs24\lang1033\langfe1058\langnp1033\insrsid7754010\charrsid8275394 \u9744\''3f}' ; --шрифт "Segoe UI Symbol" 12розмір

    --c_chr10     constant varchar2(10) := '\par';

    c_date_empty    CONSTANT VARCHAR2 (30) := '«____»____________20___';
    c_date_empty2   CONSTANT VARCHAR2 (30) := '____.____ 20___';

    --заміна c_ekr1/c_ekr2/c_ekr3 на ісходні символи
    PROCEDURE replace_ekr (p_result IN OUT BLOB)
    IS
        l_clob   CLOB;
    BEGIN
        IF Rdm$rtfl_Univ.Get_g_Bld_Tp = rdm$rtfl_univ.c_Bld_Tp_Db
        THEN
            DBMS_LOB.createtemporary (l_clob, TRUE, DBMS_LOB.SESSION);
            l_clob :=
                REPLACE (
                    REPLACE (
                        REPLACE (tools.ConvertB2C (p_result), c_ekr1, '\'),
                        c_ekr2,
                        '{'),
                    c_ekr3,
                    '}');
            p_result := tools.convertc2b (l_clob);
            DBMS_LOB.freetemporary (l_clob);
        END IF;
    END;

    --екранує спецсимволи
    FUNCTION org2ekr (p_value VARCHAR2)
        RETURN VARCHAR2
    IS
    BEGIN
        --екранувати '\{}'
        IF Rdm$rtfl_Univ.Get_g_Bld_Tp = rdm$rtfl_univ.c_Bld_Tp_Db
        THEN
            RETURN REPLACE (
                       REPLACE (REPLACE (p_value, '\', c_ekr1), '{', c_ekr2),
                       '}',
                       c_ekr3);
        ELSE
            RETURN p_value;
        END IF;
    END;

    FUNCTION NVL2 (val1 VARCHAR2, val2 VARCHAR2, val3 VARCHAR2:= NULL)
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN CASE WHEN val1 IS NOT NULL THEN val2 ELSE val3 END;
    END;

    FUNCTION Space (p_Len INTEGER, p_Val VARCHAR2:= '_')
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN LPAD (p_Val, p_Len, p_Val);
    END;

    FUNCTION replace_null (p_v1 VARCHAR2, p_v2 VARCHAR2, p_v3 VARCHAR2)
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN REPLACE (p_v1, p_v2, NVL (p_v3, 'null'));
    END;

    FUNCTION GetCuPIB (p_Cu_Id NUMBER)
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN Ikis_Rbm.Tools.Getcupib (p_Cu_Id);
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    FUNCTION GetScPIB (p_Sc_id NUMBER)
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN Uss_Person.Api$sc_Tools.Get_Pib (p_Sc_id);
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    --прізвище та ініціали
    FUNCTION GetPIB (p_pib VARCHAR2)
        RETURN VARCHAR2
    IS
        x1   VARCHAR2 (100);
        x2   VARCHAR2 (100);
        x3   VARCHAR2 (100);
    BEGIN
        IF TRIM (p_Pib) IS NULL
        THEN
            RETURN NULL;
        END IF;

        x1 :=
            REGEXP_SUBSTR (p_pib,
                           '[^ ]+',
                           1,
                           1);
        x2 :=
            SUBSTR (REGEXP_SUBSTR (p_pib,
                                   '[^ ]+',
                                   1,
                                   2),
                    1,
                    1);
        x3 :=
            SUBSTR (REGEXP_SUBSTR (p_pib,
                                   '[^ ]+',
                                   1,
                                   3),
                    1,
                    1);
        RETURN    x1
               || NVL2 (x2, ' ' || x2 || '.', NULL)
               || NVL2 (x3, ' ' || x3 || '.', NULL);
    END;

    --Власне ім’я прізвище
    FUNCTION Get_IPr (p_pib VARCHAR2)
        RETURN VARCHAR2
    IS
        x1   VARCHAR2 (100);
        x2   VARCHAR2 (100);
    BEGIN
        IF TRIM (p_Pib) IS NULL
        THEN
            RETURN NULL;
        END IF;

        x1 :=
            REGEXP_SUBSTR (p_pib,
                           '[^ ]+',
                           1,
                           1);
        x2 :=
            REGEXP_SUBSTR (p_pib,
                           '[^ ]+',
                           1,
                           2);
        RETURN x2 || ' ' || x1;
    END;

    -- кейс-менеджер (Фахівець, який здійснює оцінку потреб)
    --з таблиці At_Other_Spec -> Uss_Ndi.v_ddn_atop_apop_tp 'CCM'
    FUNCTION Get_Km (p_At_Id NUMBER)
        RETURN r_Km
    IS
        CURSOR Cur IS
            SELECT s.Atop_Ln || ' ' || s.Atop_Fn || ' ' || s.Atop_Mn     Pib, -- ПІБ
                   s.Atop_Ln,
                   s.Atop_Fn,
                   s.Atop_Mn,
                   s.Atop_Position,                                   --посада
                   s.Atop_Phone                                      --телефон
              FROM Uss_Esr.At_Other_Spec s
             WHERE     s.Atop_At = p_At_Id
                   AND s.Atop_Tp = 'CCM'
                   AND s.History_Status = 'A';

        r   r_Km;
    BEGIN
        OPEN Cur;

        FETCH Cur INTO r;

        CLOSE Cur;

        RETURN r;
    END;

    --повертає галочку для друку
    FUNCTION cnst_check
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN org2ekr (c_check);
    END;

    --повертає \par для друку
    FUNCTION cnst_par
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN org2ekr (c_chr10);
    END;

    --повертає підкреслене p_str  p_undrl = TRUE
    FUNCTION UnderLine (p_str VARCHAR2, p_undrl BOOLEAN)
        RETURN VARCHAR2
    IS
    BEGIN
        IF p_undrl
        THEN
            RETURN '\ul ' || p_str || ' \ul0';
        ELSE
            RETURN p_str;
        END IF;
    END;

    --повертає підкреслене p_str  p_undrl = 1
    FUNCTION UnderLine (p_str VARCHAR2, p_undrl NUMBER)
        RETURN VARCHAR2
    IS
    BEGIN
        IF p_undrl = 2 AND p_str IS NULL
        THEN
            RETURN NULL;
        ELSIF p_undrl IN (1, 2)
        THEN
            RETURN '\ul ' || p_str || ' \ul0';
        ELSE
            RETURN p_str;
        END IF;
    END;

    --повертає підкреслене p_str  p_undrl = 1
    FUNCTION UnderLine_ds (p_str VARCHAR2, p_undrl NUMBER)
        RETURN VARCHAR2
    IS
    BEGIN
        IF p_undrl = 2 AND p_str IS NULL
        THEN
            RETURN NULL;
        ELSIF p_undrl IN (1, 2)
        THEN
            RETURN org2ekr (' \ul ' || p_str || '\ul0');
        ELSE
            RETURN p_str;
        END IF;
    END;

    --дата в форматі dd місяць yyyy(p_tp = 2)/dd місяця yyyy(p_tp = 1)
    FUNCTION Date2Str (p_date DATE, p_tp INTEGER:= 1)
        RETURN VARCHAR2
    IS
        l_mnum    VARCHAR2 (2) := TO_CHAR (p_date, 'mm');
        l_mname   VARCHAR2 (50);
    BEGIN
        IF p_date IS NULL
        THEN
            RETURN NULL;
        END IF;

        IF p_tp = 1
        THEN
            l_mname :=
                CASE l_mnum
                    WHEN 1 THEN 'січня'
                    WHEN 2 THEN 'лютого'
                    WHEN 3 THEN 'березня'
                    WHEN 4 THEN 'квітня'
                    WHEN 5 THEN 'травня'
                    WHEN 6 THEN 'червня'
                    WHEN 7 THEN 'липня'
                    WHEN 8 THEN 'серпня'
                    WHEN 9 THEN 'вересня'
                    WHEN 10 THEN 'жовтня'
                    WHEN 11 THEN 'листопада'
                    WHEN 12 THEN 'грудня'
                    ELSE NULL
                END;
        ELSE
            l_mname :=
                CASE l_mnum
                    WHEN 1 THEN 'січень'
                    WHEN 2 THEN 'лютий'
                    WHEN 3 THEN 'березень'
                    WHEN 4 THEN 'квітень'
                    WHEN 5 THEN 'травень'
                    WHEN 6 THEN 'червень'
                    WHEN 7 THEN 'липень'
                    WHEN 8 THEN 'серпень'
                    WHEN 9 THEN 'вересень'
                    WHEN 10 THEN 'жовтень'
                    WHEN 11 THEN 'листопад'
                    WHEN 12 THEN 'грудень'
                    ELSE NULL
                END;
        END IF;

        l_mname :=
               TO_CHAR (p_date, 'dd')
            || ' '
            || l_mname
            || ' '
            || TO_CHAR (p_date, 'yyyy');

        RETURN l_mname;
    END Date2Str;

    -- info:   отримання інформації по катоттг
    -- params: p_kaot_id - ід катоттг
    FUNCTION get_katottg_info (p_kaot_id NUMBER)
        RETURN VARCHAR2
    IS
        v_res   VARCHAR2 (4000);
    BEGIN
        SELECT RTRIM (
                      (CASE
                           WHEN l1_name IS NOT NULL AND l1_name != kaot_name
                           THEN
                               l1_name || ', '
                       END)
                   || (CASE
                           WHEN l2_name IS NOT NULL AND l2_name != kaot_name
                           THEN
                               l2_name || ', '
                       END)
                   || (CASE
                           WHEN l3_name IS NOT NULL AND l3_name != kaot_name
                           THEN
                               l3_name || ', '
                       END)
                   || (CASE
                           WHEN l4_name IS NOT NULL AND l4_name != kaot_name
                           THEN
                               l4_name || ', '
                       END)
                   || (CASE
                           WHEN l5_name IS NOT NULL AND l5_name != kaot_name
                           THEN
                               l5_name || ', '
                       END)
                   || name_temp,
                   ',')
          INTO v_res
          FROM (SELECT m.*,
                       (CASE
                            WHEN kaot_kaot_l1 = kaot_id
                            THEN
                                NULL
                            ELSE
                                (SELECT dic_sname || ' ' || x1.kaot_name
                                   FROM uss_ndi.v_ndi_katottg  x1,
                                        uss_ndi.v_ddn_kaot_tp
                                  WHERE     x1.kaot_id = m.kaot_kaot_l1
                                        AND kaot_tp = dic_value)
                        END)                              AS l1_name,
                       (CASE
                            WHEN kaot_kaot_l2 = kaot_id
                            THEN
                                NULL
                            ELSE
                                (SELECT dic_sname || ' ' || x1.kaot_name
                                   FROM uss_ndi.v_ndi_katottg  x1,
                                        uss_ndi.v_ddn_kaot_tp
                                  WHERE     x1.kaot_id = m.kaot_kaot_l2
                                        AND kaot_tp = dic_value)
                        END)                              AS l2_name,
                       (CASE
                            WHEN kaot_kaot_l3 = kaot_id
                            THEN
                                NULL
                            ELSE
                                (SELECT dic_sname || ' ' || x1.kaot_name
                                   FROM uss_ndi.v_ndi_katottg  x1,
                                        uss_ndi.v_ddn_kaot_tp
                                  WHERE     x1.kaot_id = m.kaot_kaot_l3
                                        AND kaot_tp = dic_value)
                        END)                              AS l3_name,
                       (CASE
                            WHEN kaot_kaot_l4 = kaot_id
                            THEN
                                NULL
                            ELSE
                                (SELECT dic_sname || ' ' || x1.kaot_name
                                   FROM uss_ndi.v_ndi_katottg  x1,
                                        uss_ndi.v_ddn_kaot_tp
                                  WHERE     x1.kaot_id = m.kaot_kaot_l4
                                        AND kaot_tp = dic_value)
                        END)                              AS l4_name,
                       (CASE
                            WHEN kaot_kaot_l5 = kaot_id
                            THEN
                                NULL
                            ELSE
                                (SELECT dic_sname || ' ' || x1.kaot_name
                                   FROM uss_ndi.v_ndi_katottg  x1,
                                        uss_ndi.v_ddn_kaot_tp
                                  WHERE     x1.kaot_id = m.kaot_kaot_l5
                                        AND kaot_tp = dic_value)
                        END)                              AS l5_name,
                       t.dic_sname || ' ' || kaot_name    AS name_temp
                  FROM uss_ndi.v_ndi_katottg  m
                       JOIN uss_ndi.v_ddn_kaot_tp t ON t.dic_code = m.kaot_tp
                 WHERE m.kaot_id = p_kaot_id);

        RETURN v_res;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    -- info:   отримання інформації по вулиці
    -- params: p_ns_id - ідентифікатор вулиці
    FUNCTION get_street_info (p_ns_id NUMBER)
        RETURN VARCHAR2
    IS
        v_res   VARCHAR2 (4000);
    BEGIN
        SELECT    (SELECT nsrt_name || ' '
                     FROM uss_ndi.v_ndi_street_type
                    WHERE ns_nsrt = nsrt_id)
               || ns_name
          INTO v_res
          FROM uss_ndi.v_ndi_street
         WHERE ns_id = p_ns_id;

        RETURN v_res;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;


    FUNCTION Get_adr (p_ind     VARCHAR2,
                      p_katot   VARCHAR2,
                      p_strit   VARCHAR2,
                      p_bild    VARCHAR2,
                      p_korp    VARCHAR2,
                      p_kv      VARCHAR2)
        RETURN VARCHAR2
    IS
        l_katot   VARCHAR2 (500);

        r         VARCHAR2 (4000);
    BEGIN
        l_katot :=
            RTRIM (
                TRIM (
                    REPLACE (REGEXP_REPLACE (p_katot, 'UA(\d){1,}'),
                             ',,',
                             ',')),
                ',');                                   --прибрати код КАТОТТГ
        r :=
               NVL2 (p_ind, p_ind || ' ', NULL)
            || NVL2 (l_katot, l_katot || ', ', NULL)
            || NVL2 (p_strit, p_strit || ' ', NULL)
            || NVL2 (p_bild, p_bild || ' ', NULL)
            || NVL2 (p_korp, 'корп.' || p_korp || ' ', NULL)
            || NVL2 (p_kv, 'кв.' || p_kv, NULL);
        RETURN r;
    END;

    --повертає довідник
    FUNCTION CreateRef (p_int TInt,                       --масив id довідника
                                    p_vrch TVarchar2    --масив назв довідника
                                                    )
        RETURN TRefer
    IS
        tbl   TRefer;
    BEGIN
        SELECT id, decr, ROWNUM
          BULK COLLECT INTO tbl
          FROM (SELECT ROWNUM rn, COLUMN_VALUE id FROM TABLE (p_int)) t1,
               (SELECT ROWNUM rn, COLUMN_VALUE decr FROM TABLE (p_vrch)) t2
         WHERE t1.rn = t2.rn;

        RETURN tbl;
    END;

    PROCEDURE AddParam (p_Param_Name VARCHAR2, p_Param_Value VARCHAR2)
    IS
    BEGIN
        IF C_TEST = 3
        THEN                                      --для перегенерації шаблонів
            rdm$rtfl_univ.addparam (
                p_Param_Name    => p_Param_Name,
                p_Param_Value   => '$' || p_Param_Name || '$');
            RETURN;
        END IF;

        IF C_TEST = 1
        THEN
            rdm$rtfl_univ.addparam (
                p_Param_Name    => p_Param_Name,
                p_Param_Value   => p_Param_Name || '/' || p_Param_Value);
            RETURN;
        END IF;

        rdm$rtfl_univ.AddParam (p_Param_Name    => p_Param_Name,
                                p_Param_Value   => org2ekr (p_Param_Value));
    END;

    --надавач послуги
    FUNCTION Get_Nsp_Name (p_rnspm_id uss_rnsp.v_rnsp.rnspm_id%TYPE)
        RETURN VARCHAR2
    IS
        CURSOR cur IS
            SELECT TRIM (
                       REPLACE (
                           (CASE r.rnspm_tp
                                WHEN 'O'
                                THEN
                                    COALESCE (r.rnsps_last_name,
                                              r.rnsps_first_name)
                                ELSE
                                       r.rnsps_last_name
                                    || ' '
                                    || r.rnsps_first_name
                                    || ' '
                                    || r.rnsps_middle_name
                            END),
                           '  '))
              FROM uss_rnsp.v_rnsp r
             WHERE r.rnspm_id = p_rnspm_id;

        result   VARCHAR2 (1000);
    BEGIN
        OPEN cur;

        FETCH cur INTO result;

        CLOSE cur;

        RETURN result;
    END;

    --повертає at_section_feature.atef_notes
    FUNCTION Get_Ftr_Nt (p_at_id   act.at_id%TYPE,
                         p_atp     at_person.atp_id%TYPE:= -1,
                         p_nda     NUMBER,
                         p_nng     NUMBER:= -1)
        RETURN VARCHAR2
    IS
        CURSOR cur IS
            SELECT f.atef_notes
              FROM uss_esr.at_section s, uss_esr.at_section_feature f
             WHERE     s.ate_at = p_at_id
                   AND (p_atp = -1 OR s.ate_atp = p_atp)
                   AND (p_nng = -1 OR s.ate_nng = p_nng)
                   AND f.atef_ate = s.ate_id
                   AND f.atef_nda = p_nda;

        r   at_section_feature.atef_notes%TYPE;
    BEGIN
        IF C_TEST = 1
        THEN
            RETURN p_nda;
        END IF;

        IF C_TEST = 2
        THEN
            RETURN 'Коменар,введений вручну';
        END IF;

        OPEN cur;

        FETCH cur INTO r;

        CLOSE cur;

        RETURN r;
    END;

    --повертає атрибути в одну строку
    --p_nda = '2955, 2956, 2957'
    FUNCTION Get_Ftr_Nt_Lst (p_at_id   act.at_id%TYPE,
                             p_atp     at_person.atp_id%TYPE:= -1,
                             p_nda     VARCHAR2,
                             p_nng     NUMBER:= -1,
                             dlmt      VARCHAR2:= ' ')
        RETURN VARCHAR2
    IS
        l_result   VARCHAR2 (32000);
    BEGIN
        FOR c IN (SELECT TO_NUMBER (COLUMN_VALUE) nda FROM XMLTABLE (p_nda))
        LOOP
            IF C_TEST = 1
            THEN
                l_result := l_result || dlmt || c.nda;
            ELSE
                l_result :=
                       l_result
                    || dlmt
                    || Api$act_Rpt.Get_Ftr_Nt (p_At_Id   => p_At_Id,
                                               p_Atp     => p_Atp,
                                               p_Nda     => c.nda,
                                               p_Nng     => p_Nng);
            END IF;
        END LOOP;

        RETURN TRIM (l_result);
    END;

    --повертає at_section_feature.atef_feature
    FUNCTION Get_Ftr (p_at_id   act.at_id%TYPE,
                      p_atp     at_person.atp_id%TYPE:= -1,
                      p_nda     NUMBER,
                      p_nng     NUMBER:= -1)
        RETURN VARCHAR2
    IS
        CURSOR cur IS
            SELECT f.atef_feature
              FROM uss_esr.at_section s, uss_esr.at_section_feature f
             WHERE     s.ate_at = p_at_id
                   AND (p_atp = -1 OR s.ate_atp = p_atp)
                   AND (p_nng = -1 OR s.ate_nng = p_nng)
                   AND f.atef_ate = s.ate_id
                   AND f.atef_nda = p_nda;

        l_res   at_section_feature.atef_feature%TYPE;
    BEGIN
        IF C_TEST = 1
        THEN
            RETURN p_nda;
        END IF;

        OPEN cur;

        FETCH cur INTO l_res;

        CLOSE cur;

        RETURN l_res;
    END;

    FUNCTION Get_Ftr_Chk (p_at_id   act.at_id%TYPE,
                          p_atp     at_person.atp_id%TYPE:= -1,
                          p_nda     NUMBER,
                          p_nng     NUMBER:= -1,
                          p_chk     VARCHAR2:= 'T')
        RETURN VARCHAR2
    IS
        l_res   at_section_feature.atef_feature%TYPE;
    BEGIN
        IF C_TEST = 1
        THEN
            RETURN p_nda;
        END IF;

        l_res :=
            Get_Ftr (p_at_id   => p_at_id,
                     p_atp     => p_atp,
                     p_nda     => p_nda,
                     p_nng     => p_nng);

        IF l_res = p_chk
        THEN
            RETURN org2ekr (c_check);
        ELSE
            RETURN NULL;
        END IF;
    END;

    FUNCTION Get_Ftr_ChkF (p_at_id   act.at_id%TYPE,
                           p_atp     at_person.atp_id%TYPE:= -1,
                           p_nda     NUMBER,
                           p_nng     NUMBER:= -1)
        RETURN VARCHAR2
    IS
    BEGIN
        IF C_TEST = 1
        THEN
            RETURN p_nda;
        END IF;

        IF Get_Ftr (p_at_id   => p_at_id,
                    p_atp     => p_atp,
                    p_nda     => p_nda,
                    p_nng     => p_nng) = 'F'
        THEN
            RETURN org2ekr (c_check);
        ELSE
            RETURN NULL;
        END IF;
    END;

    --прямокутник з галочкой / прямокутник без галочки
    FUNCTION Get_Ftr_Chk2 (p_at_id   act.at_id%TYPE,
                           p_atp     at_person.atp_id%TYPE:= -1,
                           p_nda     NUMBER,
                           p_nng     NUMBER:= -1,
                           p_chk     VARCHAR2:= 'T')
        RETURN VARCHAR2
    IS
        l_res   at_section_feature.atef_feature%TYPE;
    BEGIN
        IF C_TEST = 1
        THEN
            RETURN p_nda;
        END IF;

        l_res :=
            Get_Ftr (p_at_id   => p_at_id,
                     p_atp     => p_atp,
                     p_nda     => p_nda,
                     p_nng     => p_nng);

        IF l_res = p_chk
        THEN
            RETURN org2ekr (c_chk);
        ELSE
            RETURN org2ekr (c_unchk);
        END IF;
    END;

    -- перевірка на Null (прямокутник з галочкой / прямокутник без галочки)
    FUNCTION AtFtrIsNotNull (p_at_id      NUMBER,
                             p_nda        NUMBER,
                             p_def_null   VARCHAR2:= NULL)
        RETURN VARCHAR2
    IS
        l_res   at_section_feature.atef_feature%TYPE;
    BEGIN
        l_res := Get_Ftr (p_at_id => p_at_id, p_nda => p_nda);

        IF p_def_null IS NOT NULL
        THEN
            IF NVL (l_res, p_def_null) = p_def_null
            THEN
                RETURN org2ekr (c_unchk);
            ELSE
                RETURN org2ekr (c_unchk);
            END IF;
        END IF;

        IF l_res IS NOT NULL
        THEN
            RETURN org2ekr (c_chk);
        ELSE
            RETURN org2ekr (c_unchk);
        END IF;
    END;

    -- перевірка на Null (прямокутник з галочкой / прямокутник без галочки)
    FUNCTION AtFtrNtIsNotNull (p_at_id      NUMBER,
                               p_nda        NUMBER,
                               p_def_null   VARCHAR2:= NULL)
        RETURN VARCHAR2
    IS
        l_res   at_section_feature.atef_notes%TYPE;
    BEGIN
        l_res := Get_Ftr_Nt (p_at_id => p_at_id, p_nda => p_nda);

        IF p_def_null IS NOT NULL
        THEN
            IF NVL (l_res, p_def_null) = p_def_null
            THEN
                RETURN org2ekr (c_unchk);
            ELSE
                RETURN org2ekr (c_unchk);
            END IF;
        END IF;

        IF l_res IS NOT NULL
        THEN
            RETURN org2ekr (c_chk);
        ELSE
            RETURN org2ekr (c_unchk);
        END IF;
    END;

    --повертає v_ndi_document_attr.nda_indicator1 у випадку, коли він зачекен
    FUNCTION Get_Ftr_Ind (p_at_id   act.at_id%TYPE,
                          p_atp     at_person.atp_id%TYPE:= -1,
                          p_nda     NUMBER,
                          p_nng     NUMBER:= -1,
                          p_chk     VARCHAR2:= 'T')
        RETURN NUMBER
    IS
        CURSOR cur IS
              SELECT f.atef_feature, a.nda_indicator1
                FROM uss_esr.at_section         s,
                     uss_esr.at_section_feature f,
                     uss_ndi.v_ndi_document_attr a
               WHERE     s.ate_at = p_at_id
                     AND (p_atp = -1 OR s.ate_atp = p_atp)
                     AND (p_nng = -1 OR s.ate_nng = p_nng)
                     AND f.atef_ate = s.ate_id
                     AND f.atef_nda = p_nda
                     AND a.nda_id = f.atef_nda
            ORDER BY f.atef_id;

        l_res   cur%ROWTYPE;
    BEGIN
        OPEN cur;

        FETCH cur INTO l_res;

        CLOSE cur;

        IF C_TEST = 1
        THEN
            SELECT MAX (a.nda_indicator1)
              INTO l_res.nda_indicator1
              FROM uss_ndi.v_ndi_document_attr a
             WHERE a.nda_id = p_nda;

            RETURN l_res.nda_indicator1;
        END IF;

        IF l_res.atef_feature = p_chk
        THEN
            RETURN l_res.nda_indicator1;
        ELSE
            RETURN NULL;
        END IF;
    END;

    --повертає at_section.atef_feature.ate_chield_info
    FUNCTION get_AtSctChld (p_at_id   act.at_id%TYPE,
                            p_atp     at_person.atp_id%TYPE:= -1,
                            p_nng     at_section.ate_nng%TYPE)
        RETURN VARCHAR2
    IS
        CURSOR cur IS
            SELECT s.ate_chield_info
              FROM uss_esr.at_section s
             WHERE     s.ate_at = p_at_id
                   AND (p_atp = -1 OR s.ate_atp = p_atp)
                   AND s.ate_nng = p_nng;

        r   at_section.ate_chield_info%TYPE;
    BEGIN
        IF C_TEST = 1
        THEN
            RETURN p_nng;
        END IF;

        IF C_TEST = 2
        THEN
            RETURN 'Коменар,ввдений вручну';
        END IF;

        OPEN cur;

        FETCH cur INTO r;

        CLOSE cur;

        RETURN r;
    END;

    --повертає at_section.atef_feature.ate_parent_info
    FUNCTION get_AtSctPrnt (p_at_id   act.at_id%TYPE,
                            p_atp     at_person.atp_id%TYPE:= -1,
                            p_nng     at_section.ate_nng%TYPE)
        RETURN VARCHAR2
    IS
        CURSOR cur IS
            SELECT s.ate_parent_info
              FROM uss_esr.at_section s
             WHERE     s.ate_at = p_at_id
                   AND (p_atp = -1 OR s.ate_atp = p_atp)
                   AND s.ate_nng = p_nng;

        r   at_section.ate_parent_info%TYPE;
    BEGIN
        IF C_TEST = 1
        THEN
            RETURN p_nng;
        END IF;

        IF C_TEST = 2
        THEN
            RETURN 'Коменар,ввдений вручну';
        END IF;

        OPEN cur;

        FETCH cur INTO r;

        CLOSE cur;

        RETURN r;
    END;

    --повертає at_section.atef_feature.ate_notes
    FUNCTION get_AtSctNt (p_at_id   act.at_id%TYPE,
                          p_nng     at_section.ate_nng%TYPE,
                          p_atp     at_person.atp_id%TYPE:= -1)
        RETURN VARCHAR2
    IS
        CURSOR cur IS
            SELECT s.ate_notes
              FROM uss_esr.at_section s
             WHERE     s.ate_at = p_at_id
                   AND (p_atp = -1 OR s.ate_atp = p_atp)
                   AND s.ate_nng = p_nng;

        r   at_section.ate_notes%TYPE;
    BEGIN
        IF C_TEST = 1
        THEN
            RETURN p_nng;
        END IF;

        IF C_TEST = 2
        THEN
            RETURN 'Коменар,ввдений вручну';
        END IF;

        OPEN cur;

        FETCH cur INTO r;

        CLOSE cur;

        RETURN r;
    END;

    -- повертає at_other_spec pib
    FUNCTION GetOtherSpec (p_at_id        act.at_id%TYPE,
                           p_atop_tp      at_other_spec.atop_tp%TYPE,
                           p_mode      IN NUMBER DEFAULT 0)
        RETURN VARCHAR2
    IS
        CURSOR cur IS
            SELECT LISTAGG (
                          s.atop_ln
                       || ' '
                       || s.atop_fn
                       || ' '
                       || s.atop_mn
                       || CASE
                              WHEN p_mode = 1 THEN ', ' || s.atop_position
                          END,
                       ', '
                       ON OVERFLOW TRUNCATE '...')
                   WITHIN GROUP (ORDER BY s.atop_ln)
              FROM uss_esr.at_other_spec s
             WHERE     s.atop_at = p_at_id
                   AND s.atop_tp = p_atop_tp
                   AND s.History_Status = 'A';

        r   VARCHAR2 (4000);
    BEGIN
        IF C_TEST = 1
        THEN
            RETURN p_at_id;
        END IF;

        IF C_TEST = 2
        THEN
            RETURN 'ПІБ іншого спеціаліста';
        END IF;

        OPEN cur;

        FETCH cur INTO r;

        CLOSE cur;

        RETURN r;
    END;

    -- повертає at_other_spec pib
    FUNCTION GetOtherSpecDist (p_at_id        act.at_id%TYPE,
                               p_atop_tp      at_other_spec.atop_tp%TYPE,
                               p_mode      IN NUMBER DEFAULT 0)
        RETURN VARCHAR2
    IS
        CURSOR cur IS
            SELECT LISTAGG (
                       DISTINCT
                              s.atop_ln
                           || ' '
                           || s.atop_fn
                           || ' '
                           || s.atop_mn
                           || CASE
                                  WHEN p_mode = 1
                                  THEN
                                      ', ' || s.atop_position
                              END,
                       ', '
                       ON OVERFLOW TRUNCATE '...')
                   WITHIN GROUP (ORDER BY s.atop_ln)
              FROM uss_esr.at_other_spec s
             WHERE     s.atop_at = p_at_id
                   AND s.atop_tp = p_atop_tp
                   AND s.History_Status = 'A';

        r   VARCHAR2 (4000);
    BEGIN
        IF C_TEST = 1
        THEN
            RETURN p_at_id;
        END IF;

        IF C_TEST = 2
        THEN
            RETURN 'ПІБ іншого спеціаліста';
        END IF;

        OPEN cur;

        FETCH cur INTO r;

        CLOSE cur;

        RETURN r;
    END;

    FUNCTION GetAtSection (p_at_id   act.at_id%TYPE,
                           p_atp     at_person.atp_id%TYPE:= -1,
                           p_nng     at_section.ate_nng%TYPE)
        RETURN at_section%ROWTYPE
    IS
        CURSOR cur IS
            SELECT s.*
              FROM uss_esr.at_section s
             WHERE     s.ate_at = p_at_id
                   AND (p_atp = -1 OR s.ate_atp = p_atp)
                   AND s.ate_nng = p_nng;

        r   at_section%ROWTYPE;
    BEGIN
        OPEN cur;

        FETCH cur INTO r;

        CLOSE cur;

        RETURN r;
    END;

    FUNCTION Chk_Val (p_Chk_Val VARCHAR2, p_Val VARCHAR2)
        RETURN VARCHAR2
    IS
    BEGIN
        IF c_Test = 1
        THEN
            RETURN NVL (p_Val, p_Chk_Val);
        END IF;

        IF p_Chk_Val = p_Val
        THEN
            RETURN Org2ekr (c_Check);
        ELSE
            RETURN NULL;
        END IF;
    END;

    --прямокутник з галочкой / прямокутник без галочки
    FUNCTION chk_val2 (p_chk_val VARCHAR2, p_val VARCHAR2)
        RETURN VARCHAR2
    IS
    BEGIN
        IF C_TEST = 1
        THEN
            RETURN NVL (p_val, p_chk_val);
        END IF;

        IF p_chk_val = p_val
        THEN
            RETURN org2ekr (c_chk);
        ELSE
            RETURN org2ekr (c_unchk);
        END IF;
    END;

    FUNCTION mOthers (p_var1    VARCHAR2,
                      p_var2    VARCHAR2,
                      p_delmt   VARCHAR2:= c_chr10)
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN LTRIM (RTRIM (p_var1 || p_delmt || p_var2, p_delmt), p_delmt);
    END;

    FUNCTION mOthers_ds (p_pib1    VARCHAR2,
                         p_var1    VARCHAR2,
                         p_pib2    VARCHAR2,
                         p_var2    VARCHAR2,
                         p_delmt   VARCHAR2:= c_chr10)
        RETURN VARCHAR2
    IS
        l_delmt   VARCHAR2 (20) := org2ekr (p_delmt);
    BEGIN
        RETURN LTRIM (
                   RTRIM (
                          CASE
                              WHEN p_var1 IS NOT NULL
                              THEN
                                  Underline_ds (p_pib1, 2) || ': '
                          END
                       || p_var1
                       || l_delmt
                       || CASE
                              WHEN p_var2 IS NOT NULL
                              THEN
                                  Underline_ds (p_pib2, 2) || ': '
                          END
                       || p_var2,
                       l_delmt),
                   l_delmt);
    END;

    --uss_esr.at_service
    FUNCTION AtSrvChk (p_at_id act.at_id%TYPE, p_nst NUMBER)
        RETURN VARCHAR2
    IS
        CURSOR cur IS
            SELECT s.ats_id
              FROM uss_esr.at_service s
             WHERE     s.ats_at = p_at_id
                   AND s.ats_nst = p_nst
                   AND s.history_status = 'A'
                   AND s.ats_st IN ('PP',
                                    'SG',
                                    'P',
                                    'R')                             -- надати
                                        ;

        l_res   VARCHAR2 (1000);
    BEGIN
        IF C_TEST = 1
        THEN
            RETURN p_nst;
        END IF;

        OPEN cur;

        FETCH cur INTO l_res;

        CLOSE cur;

        IF l_res IS NOT NULL
        THEN
            RETURN org2ekr (c_check);
        ELSE
            RETURN NULL;
        END IF;
    END;

    --прямокутник з галочкой / прямокутник без галочки
    FUNCTION AtSrvChk2 (p_at_id act.at_id%TYPE, p_nst NUMBER)
        RETURN VARCHAR2
    IS
        CURSOR cur IS
            SELECT s.ats_id
              FROM uss_esr.at_service s
             WHERE     s.ats_at = p_at_id
                   AND s.ats_nst = p_nst
                   AND s.history_status = 'A'
                   AND s.ats_st IN ('PP',
                                    'SG',
                                    'P',
                                    'R')                             -- надати
                                        ;

        l_res   VARCHAR2 (1000);
    BEGIN
        IF C_TEST = 1
        THEN
            RETURN p_nst;
        END IF;

        OPEN cur;

        FETCH cur INTO l_res;

        CLOSE cur;

        IF l_res IS NOT NULL
        THEN
            RETURN org2ekr (c_chk);
        ELSE
            RETURN org2ekr (c_unchk);
        END IF;
    END;

    FUNCTION get_at_service_AtId (p_at_id NUMBER)
        RETURN NUMBER
    IS
        --at_service шукаємо по at_main_link від головного договора (з at_tp = 'APOP' and at_main_link_tp = 'DECISION') у підлеглих
        CURSOR c IS
            SELECT a2.at_id
              FROM act a, act a2
             WHERE     a.at_id = p_at_id
                   AND a2.at_main_link = a.at_main_link
                   AND EXISTS
                           (SELECT NULL
                              FROM uss_esr.at_service s
                             WHERE     s.ats_at = a2.at_id
                                   AND s.history_status = 'A');

        l_at   NUMBER;
    BEGIN
        OPEN c;

        FETCH c INTO l_at;

        CLOSE c;

        RETURN l_at;
    END;

    --список соц.послуг
    FUNCTION AtSrv_Nst_List (p_at_id   act.at_id%TYPE,
                             p_tp      NUMBER,       --1- надати, 0- відмовити
                             p_dlm     VARCHAR2:= ', ')
        RETURN VARCHAR2
    IS
        CURSOR cur IS
            SELECT LISTAGG (nst.nst_name, p_dlm)
                       WITHIN GROUP (ORDER BY nst.nst_order)
              FROM uss_esr.at_service s, Uss_Ndi.v_Ndi_Service_Type nst -- uss_ndi.v_ddn_tctr_ats_st st
             WHERE     s.ats_at = p_at_id
                   AND s.history_status = 'A'
                   AND nst.nst_id = s.ats_nst
                   AND CASE
                           WHEN     p_tp = 1
                                AND s.ats_st IN ('PP',
                                                 'SG',
                                                 'P',
                                                 'R')
                           THEN
                               1                                   --1- надати
                           WHEN p_tp = 0 AND s.ats_st IN ('PR', 'V')
                           THEN
                               1                                --0- відмовити
                           WHEN NVL (p_tp, 3) = 3
                           THEN
                               1
                       END = 1;

        l_res   VARCHAR2 (3200);
    BEGIN
        OPEN cur;

        FETCH cur INTO l_res;

        CLOSE cur;

        RETURN l_res;
    END;

    --p_nst = '123, 3451'
    FUNCTION get_nst (p_nst VARCHAR2)
        RETURN VARCHAR2
    IS
        l_res   VARCHAR2 (1000);
    BEGIN
        SELECT LISTAGG (st.nst_name, ', ')
                   WITHIN GROUP (ORDER BY st.nst_order)
          INTO l_res
          FROM uss_ndi.v_ndi_service_type st, XMLTABLE (p_nst) t
         WHERE st.nst_id IN TO_NUMBER (t.COLUMN_VALUE);

        RETURN l_res;
    END;

    FUNCTION AtDocAtr (p_at_id NUMBER, p_nda NUMBER)
        RETURN at_document_attr%ROWTYPE
    IS
        CURSOR cur IS
            SELECT a.*
              FROM uss_esr.at_document d, uss_esr.at_document_attr a
             WHERE     d.atd_at = p_at_id
                   AND d.history_status = 'A'
                   AND a.atda_atd = d.atd_id
                   AND a.atda_nda = p_nda
                   AND a.history_status = 'A';

        r   at_document_attr%ROWTYPE;
    BEGIN
        OPEN cur;

        FETCH cur INTO r;

        CLOSE cur;

        RETURN r;
    END;

    FUNCTION AtDocAtrStr (p_at_id NUMBER, p_nda NUMBER)
        RETURN VARCHAR2
    IS
        CURSOR cur IS
            SELECT a.atda_val_string
              FROM uss_esr.at_document d, uss_esr.at_document_attr a
             WHERE     d.atd_at = p_at_id
                   AND d.history_status = 'A'
                   AND a.atda_atd = d.atd_id
                   AND a.atda_nda = p_nda
                   AND a.history_status = 'A';

        r   at_document_attr.atda_val_string%TYPE;
    BEGIN
        IF C_TEST = 1
        THEN
            RETURN p_nda;
        END IF;

        IF C_TEST = 2
        THEN
            RETURN 'Коменар,ввдений вручну';
        END IF;

        OPEN cur;

        FETCH cur INTO r;

        CLOSE cur;

        RETURN r;
    END;

    FUNCTION AtDocAtrDt (p_at_id NUMBER, p_nda NUMBER)
        RETURN VARCHAR2
    IS
        CURSOR cur IS
            SELECT a.atda_val_dt
              FROM uss_esr.at_document d, uss_esr.at_document_attr a
             WHERE     d.atd_at = p_at_id
                   AND d.history_status = 'A'
                   AND a.atda_atd = d.atd_id
                   AND a.atda_nda = p_nda
                   AND a.history_status = 'A';

        r   DATE;
    BEGIN
        IF C_TEST = 1
        THEN
            RETURN p_nda;
        END IF;

        OPEN cur;

        FETCH cur INTO r;

        CLOSE cur;

        RETURN CASE WHEN r IS NOT NULL THEN TO_CHAR (r, 'dd.mm.yyyy') END;
    END;

    FUNCTION AtDocAtrId (p_at_id NUMBER, p_nda NUMBER)
        RETURN NUMBER
    IS
        CURSOR cur IS
            SELECT a.atda_val_id
              FROM uss_esr.at_document d, uss_esr.at_document_attr a
             WHERE     d.atd_at = p_at_id
                   AND d.history_status = 'A'
                   AND a.atda_atd = d.atd_id
                   AND a.atda_nda = p_nda
                   AND a.history_status = 'A';

        r   NUMBER;
    BEGIN
        IF C_TEST = 1
        THEN
            RETURN p_nda;
        END IF;

        OPEN cur;

        FETCH cur INTO r;

        CLOSE cur;

        RETURN CASE WHEN r IS NOT NULL THEN r END;
    END;

    FUNCTION AtDocAtrSum (p_at_id NUMBER, p_nda NUMBER)
        RETURN VARCHAR2
    IS
        CURSOR cur IS
            SELECT MAX (a.atda_val_sum)
              FROM at_document d, at_document_attr a
             WHERE     d.atd_at = p_at_id
                   AND d.history_status = 'A'
                   AND a.atda_atd = d.atd_id
                   AND a.atda_nda = p_nda
                   AND a.history_status = 'A';

        r   NUMBER;
    BEGIN
        OPEN cur;

        FETCH cur INTO r;

        CLOSE cur;

        RETURN CASE
                   WHEN r IS NOT NULL
                   THEN
                       TO_CHAR (r,
                                'FM9G999G999G999G999G990D00',
                                'NLS_NUMERIC_CHARACTERS=''.''''')
               END;
    END;

    --повертає атрибути в одну строку
    --p_nda = '2955, 2956, 2957'
    FUNCTION At_Doc_Atr_Lst (p_at_id   NUMBER,
                             p_nda     VARCHAR2,
                             dlmt      VARCHAR2:= ' ')
        RETURN VARCHAR2
    IS
        l_result   VARCHAR2 (32000);
    BEGIN
        FOR c IN (SELECT TO_NUMBER (COLUMN_VALUE) nda FROM XMLTABLE (p_nda))
        LOOP
            IF C_TEST = 1
            THEN
                l_result := l_result || dlmt || c.nda;
            ELSE
                l_result := l_result || dlmt || AtDocAtrStr (p_at_id, c.nda);
            END IF;
        END LOOP;

        RETURN TRIM (l_result);
    END;

    FUNCTION Get_Ap_Doc_Atr_Str (p_Ap_Id   NUMBER,
                                 p_Nda     NUMBER,
                                 p_App     NUMBER:= NULL)
        RETURN VARCHAR2
    IS
        CURSOR Cur IS
            SELECT a.Apda_Val_String
              FROM Uss_Esr.Ap_Document d, Uss_Esr.Ap_Document_Attr a
             WHERE     d.Apd_Ap = p_Ap_Id
                   AND d.History_Status = 'A'
                   AND d.Apd_App = NVL (p_App, d.Apd_App)
                   AND a.Apda_Apd = d.Apd_Id
                   AND a.Apda_Nda = p_Nda
                   AND a.History_Status = 'A';

        r   Ap_Document_Attr.Apda_Val_String%TYPE;
    BEGIN
        IF c_Test = 1
        THEN
            RETURN p_Nda;
        END IF;

        IF c_Test = 2
        THEN
            RETURN 'Коменар,ввдений вручну';
        END IF;

        OPEN Cur;

        FETCH Cur INTO r;

        CLOSE Cur;

        RETURN r;
    END;

    FUNCTION get_AtPerson (p_at NUMBER, p_atp NUMBER)
        RETURN R_Person_for_act
    IS
        CURSOR cur IS
            SELECT p.atp_id,
                   p.atp_sc,
                   p.atp_app,
                   ATP_APP_TP,
                   p.atp_ln || ' ' || p.atp_fn || ' ' || p.atp_mn
                       pib,
                   p.atp_ln,                                        --Прізвище
                   p.atp_fn,
                   p.atp_mn,
                   atp_birth_dt,                             --Дата народження
                   TO_CHAR (atp_birth_dt, 'dd.mm.yyyy'),     --Дата народження
                   --decode(p.atp_sex, 'F', 'Ж', 'M', 'Ч')  sex, --s.Dic_Name sex,
                   p.atp_sex,
                   atp_citizenship,                             --Громадянство
                   atp_is_disabled,                             --Інвалідність
                   atp_is_capable,                              --Дієздатність
                   atp_is_disordered, --Когнітивні порушення/ психічні розлади
                   atp_disorder_record,
                   p.atp_is_vpo,                   --Перебування на обліку ВПО
                   ATP_IS_ORPHAN, --Ознака сироти чи позбавлення батьківського піклування
                   ATP_IS_SELFSERVICE,       --Здатність до самообслуговування
                   atp_live_address,                        --Місце проживання
                   atp_fact_address,             -- Фактична адреса проживання
                   atp_work_place,      --Місце навчання та / або місце роботи
                   atp_is_adr_matching,      --Реєстрація за місцем проживання
                   atp_phone,                      --Контактний номер телефону
                   p.atp_email,
                   Rt.Dic_Name
                       AS Atp_Relation_Tp_Name,             --Родинний зв’язок
                   Appt.Dic_Name
                       AS Atp_App_Tp_Name,                      --Тип учасника
                   p.atp_disable_record,
                   a.at_live_address,
                   p.history_status,
                   atp_num
              FROM uss_esr.at_person          p,
                   act                        a,
                   Uss_Ndi.v_Ddn_Relation_Tp  Rt,
                   Uss_Ndi.v_Ddn_App_Tp       Appt                         --,
             --Uss_Ndi.v_ddn_gender s
             WHERE     p.atp_at = p_at
                   AND p.atp_id = p_atp
                   AND a.at_id = p.atp_at
                   AND Rt.Dic_Value(+) = p.Atp_Relation_Tp
                   AND Appt.Dic_Value(+) = p.Atp_App_Tp--and s.Dic_Value(+)= p.atp_sex
                                                       ;

        r   R_Person_for_act;
    BEGIN
        OPEN cur;

        FETCH cur INTO r;

        CLOSE cur;

        RETURN r;
    END;

    FUNCTION get_AtPerson_id (p_at            NUMBER,
                              p_App_Tp        VARCHAR2,
                              p_App_Tp_only   INTEGER:= NULL)
        RETURN NUMBER
    IS
        l_id   NUMBER;
    BEGIN
        IF p_App_Tp_only = 1
        THEN
            SELECT p.atp_id
              INTO l_id
              FROM uss_esr.at_person p
             WHERE     p.atp_at = p_at
                   AND p.history_status = 'A'
                   AND p.Atp_App_Tp = p_App_Tp
             FETCH FIRST ROW ONLY;
        ELSE
            SELECT p.atp_id
              INTO l_id
              FROM (  SELECT p.atp_id
                        FROM uss_esr.at_person p, Uss_Ndi.v_Ddn_App_Tp Appt
                       WHERE     p.atp_at = p_at
                             AND p.history_status = 'A'
                             AND Appt.dic_value(+) = p.Atp_App_Tp
                    ORDER BY DECODE (p.Atp_App_Tp,
                                     p_App_Tp, 0,
                                     Appt.dic_srtordr)) p
             FETCH FIRST ROW ONLY;
        END IF;

        RETURN l_id;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    FUNCTION get_AtPerson_id (p_at NUMBER)
        RETURN NUMBER
    IS
        l_id   NUMBER;
    BEGIN
          SELECT p.atp_id
            INTO l_id
            FROM uss_esr.at_person p, Uss_Ndi.v_Ddn_App_Tp Appt
           WHERE     p.atp_at = p_at
                 AND p.history_status = 'A'
                 AND Appt.dic_value(+) = p.Atp_App_Tp
        ORDER BY DECODE (p.Atp_App_Tp,
                         'OS', 0,
                         'Z', 1,
                         'FMS', 2,
                         Appt.dic_srtordr + 10)
           FETCH FIRST ROW ONLY;

        RETURN l_id;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    FUNCTION get_AtPersonSc_id (p_at NUMBER, p_sc at_person.atp_sc%TYPE)
        RETURN NUMBER
    IS
        l_id   NUMBER;
    BEGIN
          SELECT p.atp_id
            INTO l_id
            FROM uss_esr.at_person p, Uss_Ndi.v_Ddn_App_Tp Appt
           WHERE     p.atp_at = p_at
                 AND p.atp_sc = p_sc
                 AND p.history_status = 'A'
                 AND Appt.dic_value(+) = p.Atp_App_Tp
        ORDER BY Appt.dic_srtordr
           FETCH FIRST ROW ONLY;

        RETURN l_id;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    --члени родини
    FUNCTION At_Person_for_act (p_at IN NUMBER)
        RETURN T_Person_for_act
        PIPELINED
    IS
        r   R_Person_for_act;
    BEGIN
        FOR c IN (SELECT p.atp_id
                    FROM uss_esr.at_person p
                   WHERE p.atp_at = p_at AND p.history_status = 'A')
        LOOP
            r := get_AtPerson (p_at => p_at, p_atp => c.atp_id);
            PIPE ROW (r);
        END LOOP;
    END;

    /*Дивлячись хто там на формі вказаний. Наприклад в "інформації про припинення"
    там "Керівник надавача соціальних послуг". Тобто це підписант з типом PR.
    Треба брати ПІБ через at_signers.at_cu. В "рішенні про припинення" там є такі підписанти:
    -Спеціаліст уповноваженого органу / надавача соціальних послуг з опрацювання заяв
    -Керівник уповноваженого органу / надавача соціальних послуг
    В цьому випадку "Спеціаліст  надавача соціальних послуг з опрацювання заяв" це кейс-менеджер.
    Кейс менеджер скоріш за все не буде явно себе вказувати у якості підписанта тому його треба брати по act.at_cu.
    Замість нього може бути "Спеціаліст уповноваженого органу", в такому випадку треба брати по Act.At_Wu.
    Наступного підписанта вже вказують явно. Тобто для "Керівник надавача соціальних послуг" це буде at_signer,
    у якого ati_tp=PR, посилання на юзера в нього в Ati_Cu. Для "Керівник уповноваженого органу" це буде at_signer,
    у якого ati_tp=SB, посилання на юзера в нього - Ati_Wu
    */

    --підписант акта
    FUNCTION get_signers_wucu_pib (p_at_id      NUMBER,
                                   p_ati_tp     VARCHAR2,
                                   p_ati_cuwu   NUMBER:= NULL,
                                   p_ndt        NUMBER:= NULL)
        RETURN VARCHAR2
    IS
        l_sng   VARCHAR2 (100);
    BEGIN
        IF p_ndt IS NULL
        THEN
            SELECT MAX (
                       CASE p_ati_cuwu
                           WHEN 1
                           THEN
                               Api$Act_Rpt.GetCuPIB (s.ati_cu)
                           WHEN 2
                           THEN
                               Tools.Getuserpib (s.ati_wu)
                           ELSE
                               NVL (Api$Act_Rpt.GetCuPIB (s.ati_cu),
                                    Tools.Getuserpib (s.ati_wu))
                       END)
              INTO l_sng
              FROM at_signers s
             WHERE     s.ati_at = p_at_id
                   AND s.history_status = 'A'
                   AND s.ati_is_signed = 'T'
                   AND s.ati_tp = p_ati_tp;
        ELSE
            SELECT MAX (
                       CASE p_ati_cuwu
                           WHEN 1
                           THEN
                               Api$Act_Rpt.GetCuPIB (s.ati_cu)
                           WHEN 2
                           THEN
                               Tools.Getuserpib (s.ati_wu)
                           ELSE
                               NVL (Api$Act_Rpt.GetCuPIB (s.ati_cu),
                                    Tools.Getuserpib (s.ati_wu))
                       END)
              INTO l_sng
              FROM at_signers s, at_document d
             WHERE     s.ati_at = p_at_id
                   AND s.history_status = 'A'
                   AND s.ati_is_signed = 'T'
                   AND s.ati_tp = p_ati_tp
                   AND d.atd_id = s.ati_atd
                   AND d.history_status = 'A'
                   AND d.atd_ndt = p_ndt;
        END IF;

        RETURN l_sng;
    END;

    --перевірка: тільки якщо знайден підписант акта p_atp_id в at_person
    FUNCTION get_at_signers (p_at_id NUMBER, p_atp_id NUMBER)
        RETURN at_signers%ROWTYPE
    IS
        CURSOR c IS
            SELECT s.*
              FROM at_signers s, at_person p, Uss_Ndi.v_Ddn_App_Tp tp
             WHERE     s.ati_at = p_at_id
                   AND p.atp_id = p_atp_id
                   AND (p.atp_id = s.ati_atp OR p.atp_sc = s.ati_sc)
                   AND s.history_status = 'A'
                   AND p.history_status = 'A'
                   AND tp.dic_value(+) = p.atp_app_tp;

        r   at_signers%ROWTYPE;
    BEGIN
        OPEN c;

        FETCH c INTO r;

        CLOSE c;

        RETURN r;
    END;

    FUNCTION get_at_signers_pers (p_at_id NUMBER, p_atp_id NUMBER)
        RETURN R_Person_for_act
    IS
    BEGIN
        IF get_at_signers (p_at_id, p_atp_id).ati_at IS NOT NULL
        THEN
            RETURN get_AtPerson (p_at => p_at_id, p_atp => p_atp_id);
        ELSE
            RETURN NULL;
        END IF;
    END;

    FUNCTION Gender (p_val VARCHAR2)
        RETURN VARCHAR2
    IS
        Result   VARCHAR2 (100);
    BEGIN
        SELECT MAX (t.DIC_NAME)
          INTO Result
          FROM uss_ndi.v_ddn_gender t
         WHERE t.DIC_VALUE = p_val;

        RETURN Result;
    END;

    --ознака інвалідності 1/0
    FUNCTION is_disabled (p_val VARCHAR2)
        RETURN NUMBER
    IS
    BEGIN
        CASE
            WHEN p_val = '0'
            THEN
                RETURN 0;
            WHEN p_val BETWEEN '1' AND '4'
            THEN
                RETURN 1;
            ELSE
                RETURN NULL;
        END CASE;
    END;

    --Група інвалідності (p_all =1 пошук по усіх, 0 - віключити з пошуку без інвалідності)
    FUNCTION DisabledGrp (p_val VARCHAR2, p_all INTEGER:= 1)
        RETURN VARCHAR2
    IS
        Res   VARCHAR2 (100);
    BEGIN
        SELECT MAX (t.DIC_NAME)
          INTO Res
          FROM uss_ndi.V_DDN_SCY_GROUP t
         WHERE t.DIC_VALUE = p_val AND (p_all = 1 OR p_val <> '0');

        RETURN Res;
    END;

    --значення довдника типу uss_ndi.dic_dv (у разі множинного вибіру значення через кому без пробілів p_val='1,4,5')
    FUNCTION v_ddn (p_v_ddn VARCHAR2, p_val VARCHAR2, p_dlm VARCHAR2:= NULL)
        RETURN VARCHAR2
    IS
        c          SYS_REFCURSOR;
        l_Result   VARCHAR2 (4000);
    BEGIN
        l_Result :=
            q'[select listagg(t.DIC_NAME, :p_dlm) Within GROUP(ORDER BY t.DIC_SRTORDR) from :p_v_ddn t where ',:p_val,' like '%,'||t.DIC_VALUE||',%']';
        l_Result := REPLACE (l_Result, ':p_v_ddn', p_v_ddn);
        l_Result := REPLACE (l_Result, ':p_val', p_val);
        l_Result :=
            REPLACE (
                l_Result,
                ':p_dlm',
                CASE
                    WHEN p_dlm IS NULL THEN 'null'
                    ELSE '''' || p_dlm || ''''
                END);

        IF p_v_ddn IS NOT NULL
        THEN
            --open c for 'select max(t.DIC_NAME) from '|| p_v_ddn ||' t where t.DIC_VALUE = ''' ||p_val||'''';
            OPEN c FOR l_Result;

            FETCH c INTO l_Result;

            CLOSE c;
        END IF;

        RETURN l_Result;
    END;

    FUNCTION Get_Ndi_Doc_Atr (p_Nda NUMBER)
        RETURN Uss_Ndi.v_Ndi_Document_Attr%ROWTYPE
    IS
        CURSOR Cur IS
            SELECT *
              FROM Uss_Ndi.v_Ndi_Document_Attr a
             WHERE a.Nda_Id = p_Nda;

        RESULT   Uss_Ndi.v_Ndi_Document_Attr%ROWTYPE;
    BEGIN
        OPEN Cur;

        FETCH Cur INTO RESULT;

        CLOSE Cur;

        RETURN RESULT;
    END;

    FUNCTION Get_Ndi_Doc_Atr_Name (p_Nda NUMBER)
        RETURN VARCHAR2
    IS
        l_str   VARCHAR2 (1000);
    BEGIN
        SELECT MAX (a.nda_name)
          INTO l_str
          FROM Uss_Ndi.v_Ndi_Document_Attr a
         WHERE a.Nda_Id = p_Nda;

        RETURN l_str;
    END;

    --причина відмови ВІД надання
    FUNCTION Get_At_Reject_List (p_At_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_result   VARCHAR2 (4000);
    BEGIN
        SELECT LISTAGG (r.Njr_Name, ', ') WITHIN GROUP (ORDER BY r.Njr_Order)
          INTO l_result
          FROM At_Reject_Info  i
               JOIN Uss_Ndi.v_Ndi_Reject_Reason r ON i.ari_njr = r.Njr_Id
         WHERE i.ari_at = p_At_Id AND r.History_Status = 'A';

        RETURN l_result;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN NULL;
    END;

    --получити at_id акта, до якого прив"язан інд.план
    FUNCTION get_At_individual_plan_at_id (p_at_id NUMBER)
        RETURN NUMBER
    IS
        CURSOR c IS
            SELECT atip.atip_at
              FROM uss_esr.act                 a,
                   uss_esr.at_links            l,
                   uss_esr.At_individual_plan  atip
             WHERE     1 = 1
                   AND a.at_id = p_at_id
                   AND l.atk_link_at = a.at_main_link
                   AND atip.atip_at = l.atk_at          --зв"язок на інд.плани
                   AND atip.history_status = 'A';

        Result   NUMBER;
    BEGIN
        OPEN c;

        FETCH c INTO Result;

        CLOSE c;

        RETURN Result;
    END;

    --Строк виконання/Термін виконання для At_individual_plan.atip_term_tp (uss_ndi.v_ddn_atip_term)
    FUNCTION get_atip_term (p_atip_id NUMBER)
        RETURN VARCHAR2
    IS
        CURSOR cur IS
            SELECT i.atip_term_tp, i.atip_start_dt, i.atip_stop_dt
              FROM At_individual_plan i
             WHERE i.atip_id = p_atip_id;

        l_tp     VARCHAR2 (10);
        l_dt1    DATE;
        l_dt2    DATE;
        result   VARCHAR2 (100);
    BEGIN
        OPEN cur;

        FETCH cur INTO l_tp, l_dt1, l_dt2;

        CLOSE cur;

        CASE l_tp
            WHEN 'P'
            THEN                                                    --Постійно
                SELECT t.dic_name
                  INTO result
                  FROM uss_ndi.v_ddn_atip_term t
                 WHERE t.DIC_VALUE = 'P';
            WHEN 'VP'
            THEN
                result :=
                    CASE
                        WHEN l_dt1 IS NULL AND l_dt2 IS NOT NULL
                        THEN
                            'по ' || TO_CHAR (l_dt2, 'dd.mm.yyyy')
                        WHEN l_dt1 IS NOT NULL AND l_dt2 IS NOT NULL
                        THEN
                               'з '
                            || TO_CHAR (l_dt1, 'dd.mm.yyyy')
                            || ' по '
                            || TO_CHAR (l_dt2, 'dd.mm.yyyy')
                        WHEN l_dt1 IS NOT NULL
                        THEN
                            'з ' || TO_CHAR (l_dt1, 'dd.mm.yyyy')
                    END;
            ELSE
                NULL;
        END CASE;

        RETURN result;
    END;

    --повертає atp_id/atp_sc (p_ap_sc_id=1/2) для p_tp=1-батько/прийомній 2-мати/прийомна
    --шукаюмо в зверненні/документах
    FUNCTION Get_Father_Mother (p_at_id      act.at_id%TYPE,        --для акта
                                p_tp         NUMBER,
                                p_ap_sc_id   NUMBER:= 1)
        RETURN NUMBER
    IS
        CURSOR c IS
            SELECT DECODE (p_ap_sc_id,  1, p_a.atp_id,  2, p_a.atp_sc)
                       id_,
                   da.*
              FROM uss_esr.act               a,
                   uss_esr.ap_document       d,
                   uss_esr.ap_document_attr  da,
                   uss_esr.ap_person         p_z,                  --звернення
                   uss_esr.at_person         p_a                         --акт
             WHERE     a.at_id = p_at_id
                   AND d.apd_ap = a.at_ap
                   AND d.history_status = 'A'
                   AND da.apda_apd = d.apd_id
                   AND da.history_status = 'A'
                   AND da.apda_val_string = 'T'
                   AND da.apda_nda IN
                           (SELECT a1.nda_id
                              FROM uss_ndi.v_ndi_document_attr  a1,
                                   uss_ndi.v_ndi_nda_config     t
                             WHERE     t.nac_nda = a1.nda_id
                                   AND a1.history_status = 'A'
                                   AND a1.nda_ndt = 605
                                   AND a1.nda_nng = 6
                                   AND t.nac_ap_tp = 'SS')
                   AND p_z.app_id = d.apd_app
                   AND p_a.atp_at = a.at_id
                   AND p_a.atp_sc = p_z.app_sc
                   AND CASE
                           WHEN p_tp = 1 AND p_a.atp_sex = 'M' THEN 1
                           WHEN p_tp = 2 AND p_a.atp_sex = 'F' THEN 1
                       END =
                       1;

        r   c%ROWTYPE;
    BEGIN
        OPEN c;

        FETCH c INTO r;

        CLOSE c;

        RETURN r.id_;
    END;

    --Сім’я/особа потребує надання соціальних послуг select * from USS_NDI.v_NDI_SERVICE_TYPE t where t.nst_ap_tp = 'G' order by t.nst_id;
    --для обраних послуг - квадратик з галочкою, не обраних - без галочки
    PROCEDURE AddNstAtService (p_at_id NUMBER, p_param_nst VARCHAR2:= 'nst-')
    IS
    BEGIN
        addparam (p_param_nst || '1', AtSrvChk2 (p_at_id, p_nst => 401));
        addparam (p_param_nst || '2', AtSrvChk2 (p_at_id, p_nst => 402));
        addparam (p_param_nst || '3', AtSrvChk2 (p_at_id, p_nst => 403));
        addparam (p_param_nst || '4', AtSrvChk2 (p_at_id, p_nst => 404));
        addparam (p_param_nst || '5', AtSrvChk2 (p_at_id, p_nst => 405));
        addparam (p_param_nst || '6', AtSrvChk2 (p_at_id, p_nst => 406));
        addparam (p_param_nst || '7', AtSrvChk2 (p_at_id, p_nst => 407));
        addparam (p_param_nst || '8', AtSrvChk2 (p_at_id, p_nst => 408));
        addparam (p_param_nst || '9', AtSrvChk2 (p_at_id, p_nst => 409));
        addparam (p_param_nst || '10', AtSrvChk2 (p_at_id, p_nst => 411));
        addparam (p_param_nst || '11', AtSrvChk2 (p_at_id, p_nst => 413));
        addparam (p_param_nst || '12', AtSrvChk2 (p_at_id, p_nst => 414));
        addparam (p_param_nst || '13', AtSrvChk2 (p_at_id, p_nst => 415));
        addparam (p_param_nst || '14', AtSrvChk2 (p_at_id, p_nst => 417));
        addparam (p_param_nst || '15', AtSrvChk2 (p_at_id, p_nst => 418));
        addparam (p_param_nst || '16', AtSrvChk2 (p_at_id, p_nst => 419));
        addparam (p_param_nst || '17', AtSrvChk2 (p_at_id, p_nst => 420));
        addparam (p_param_nst || '18', AtSrvChk2 (p_at_id, p_nst => 421));
        addparam (p_param_nst || '19', AtSrvChk2 (p_at_id, p_nst => 422));
        addparam (p_param_nst || '20', AtSrvChk2 (p_at_id, p_nst => 423));
        addparam (p_param_nst || '21', AtSrvChk2 (p_at_id, p_nst => 425));
        addparam (p_param_nst || '22', AtSrvChk2 (p_at_id, p_nst => 426));
        addparam (p_param_nst || '23', AtSrvChk2 (p_at_id, p_nst => 427));
        addparam (p_param_nst || '24', AtSrvChk2 (p_at_id, p_nst => 428));
        addparam (p_param_nst || '25', AtSrvChk2 (p_at_id, p_nst => 429));
        addparam (p_param_nst || '26', AtSrvChk2 (p_at_id, p_nst => 430));
        addparam (p_param_nst || '27', AtSrvChk2 (p_at_id, p_nst => 432));
        addparam (p_param_nst || '28', AtSrvChk2 (p_at_id, p_nst => 433));
        addparam (p_param_nst || '29', AtSrvChk2 (p_at_id, p_nst => 434));
        addparam (p_param_nst || '30', AtSrvChk2 (p_at_id, p_nst => 435));
        addparam (p_param_nst || '31', AtSrvChk2 (p_at_id, p_nst => 437));
        addparam (p_param_nst || '32', AtSrvChk2 (p_at_id, p_nst => 438));
        addparam (p_param_nst || '33', AtSrvChk2 (p_at_id, p_nst => 439));
        addparam (p_param_nst || '34', AtSrvChk2 (p_at_id, p_nst => 440));
        addparam (p_param_nst || '35', AtSrvChk2 (p_at_id, p_nst => 441));
        addparam (p_param_nst || '36', AtSrvChk2 (p_at_id, p_nst => 442));
        addparam (p_param_nst || '37', AtSrvChk2 (p_at_id, p_nst => 443));
    END;

    --Сім’я/особа потребує надання соціальних послуг select * from USS_NDI.v_NDI_SERVICE_TYPE t where t.nst_ap_tp = 'G' order by t.nst_id;
    --для усіх обраних послуг, з нового рядку: кадратик з + галочкою послуга
    PROCEDURE AddNstAtService2 (p_at_id NUMBER, p_param_nst VARCHAR2)
    IS
        l_str   VARCHAR2 (32000);
    BEGIN
        l_str := AtSrv_Nst_List (p_At_Id => p_at_id, p_Tp => 1, p_Dlm => '##' /*||c_chr10*/
                                                                             );

        IF l_str IS NOT NULL
        THEN
            l_str :=
                   c_chk
                || ' '
                || REPLACE (l_str, '##', '' || c_chr10 || c_chk || ' ');
        END IF;

        addparam (p_param_nst, l_str);
    END;

    FUNCTION ds_child (p_at_id IN NUMBER)
        RETURN VARCHAR2
    IS
        C_P_NNG   CONSTANT INTEGER := 119; -- секція 118 - "2.Стан та потреби дитини", можливо треба взяти 119

        l_sql              VARCHAR2 (32000);
    BEGIN
        l_sql := q'[
with
  function ActId return number is
  begin
    --return 862;
    return :p_at_id;
  end;

  function atr(p_atp number, p_nda number)return varchar2 is
  begin
   return uss_esr.Api$Act_Rpt.Get_Ftr(ActId(),p_atp,p_nda);
  end;
  function atrNt(p_atp number, p_nda number)return varchar2 is
  begin
   return uss_esr.Api$Act_Rpt.Get_Ftr_Nt(ActId(),p_atp,p_nda);
  end;
  function atrChk(p_atp number, p_nda number)return varchar2 is
  begin
   --return uss_esr.Api$Act_Rpt.Get_Ftr_Chk(ActId(),p_atp,p_nda);
   return uss_esr.Api$Act_Rpt.Get_Ftr_Chk2(ActId(),p_atp,p_nda);
  end;
  function SctChld(p_atp number, p_nng number)return varchar2 is
  begin
   return uss_esr.Api$Act_Rpt.get_AtSctChld(ActId(),p_atp,p_nng);
  end;
  function SctPrnt(p_atp number, p_nng number)return varchar2 is
  begin
   return uss_esr.Api$Act_Rpt.get_AtSctPrnt(ActId(),p_atp,p_nng);
  end;
  function SctNt(p_atp number, p_nng number)return varchar2 is
  begin
   return uss_esr.Api$Act_Rpt.get_AtSctNt(ActId(),p_nng,p_atp);
  end;
  function chk_val(p_chk_val varchar2, p_val varchar2)return varchar2 is
  begin
   --return uss_esr.Api$Act_Rpt.chk_val(p_chk_val,p_val);
   return uss_esr.Api$Act_Rpt.chk_val2(p_chk_val,p_val);
  end;

select p.atp_ln||' '||p.atp_fn||' '||p.atp_mn F18,
       chk_val('NE', atr(atp_id,3142)) F19_1, --uss_ndi.V_DDN_EXIST_SGN1
       chk_val('EX', atr(atp_id,3142)) F19_2,
       chk_val('UN', atr(atp_id,3142)) F19_3,
       atrChk(atp_id,3143) F20,
       atrChk(atp_id,3144) F21,
       atrChk(atp_id,3145) F22,
       atrChk(atp_id,3146) F23,
       atrChk(atp_id,3147) F24,
       atrChk(atp_id,3148) F25,
       atrChk(atp_id,3149) F26,
       atrChk(atp_id,3150) F27,
       atrChk(atp_id,3151) F28,
       atrChk(atp_id,3152) F29,
       atrChk(atp_id,3153) F30,
       atrChk(atp_id,3154) F31,
       atrChk(atp_id,3155) F32,
       --має медичну картку
       atrChk(atp_id,3156) F33,
       atrChk(atp_id,3157) F34,
       atrChk(atp_id,3158) F35,
       SctChld(atp_id,119) f36,
       SctPrnt(atp_id,119) f37,
       SctNt  (atp_id,119) f38,
       --2) харчування
       chk_val('NE', atr(atp_id,3162)) F39_1,
       chk_val('EX', atr(atp_id,3162)) F39_2,
       chk_val('UN', atr(atp_id,3162)) F39_3,
       atrChk(atp_id,3163) F40,
       atrChk(atp_id,3164) F41,
       atrChk(atp_id,3165) F42,
       atrChk(atp_id,3166) F43,
       SctChld(atp_id,120) f44,
       SctPrnt(atp_id,120) f45,
       SctNt  (atp_id,120) f46,
       --3) навчання та досягнення
       chk_val('NE', atr(atp_id,3170)) F47_1,
       chk_val('EX', atr(atp_id,3170)) F47_2,
       chk_val('UN', atr(atp_id,3170)) F47_3,
       atrChk(atp_id,3171) F48,
       atrChk(atp_id,3172) F49,
       atrChk(atp_id,3173) F50,
       atrChk(atp_id,3174) F51,
       atrChk(atp_id,3175) F52,
       atrChk(atp_id,3176) F53,
       atrChk(atp_id,3177) F54,
       atrChk(atp_id,3178) F55,
       atrChk(atp_id,3179) F56,
       atrChk(atp_id,3180) F57,
       atrChk(atp_id,3181) F58,
       atrChk(atp_id,3182) F59,
       atrChk(atp_id,3183) F60,
       atrChk(atp_id,3184) F61,
       atrChk(atp_id,3185) F62,
       atrChk(atp_id,3186) F63,
       atrChk(atp_id,3187) F64,
       SctChld(atp_id,121) f65,
       SctPrnt(atp_id,121) f66,
       SctNt  (atp_id,121) f67,
       --4) емоційний стан
       chk_val('NE', atr(atp_id,3191)) F68_1,
       chk_val('EX', atr(atp_id,3191)) F68_2,
       chk_val('UN', atr(atp_id,3191)) F68_3,
       atrChk(atp_id,3192) F69,
       atrChk(atp_id,3193) F70,
       atrChk(atp_id,3194) F71,
       atrChk(atp_id,3195) F72,
       atrChk(atp_id,3196) F73,
       atrChk(atp_id,3197) F74,
       atrChk(atp_id,3198) F75,
       atrChk(atp_id,3199) F76,
       atrChk(atp_id,3200) F77,
       atrChk(atp_id,3201) F78,
       SctChld(atp_id,122) f79,
       SctPrnt(atp_id,122) f80,
       SctNt  (atp_id,122) f81,
       --5) шкідливі звички
       chk_val('NE', atr(atp_id,3205)) F82_1,
       chk_val('EX', atr(atp_id,3205)) F82_2,
       chk_val('UN', atr(atp_id,3205)) F82_3,
       atrChk(atp_id,3206) F83,
       atrChk(atp_id,3207) F84,
       atrChk(atp_id,3208) F85,
       atrChk(atp_id,3209) F86,
       atrChk(atp_id,3210) F87,
       atrChk(atp_id,3211) F88,
       atrChk(atp_id,3212) F89,
       atrChk(atp_id,3213) F90,
       atrChk(atp_id,3214) F91,
       atrChk(atp_id,3215) F92,
       atrChk(atp_id,3216) F93,
       atrChk(atp_id,3217) F94,
       atrChk(atp_id,3218) F95,
       atrChk(atp_id,3219) F96,
       atrChk(atp_id,3220) F97,
       atrNt (atp_id,3220) F98,
       SctChld(atp_id,123) f99,
       SctPrnt(atp_id,123) f100,
       SctNt  (atp_id,123) f101,
       --6) сімейні та соціальні стосунки
       chk_val('NE', atr(atp_id,3237)) F102_1,
       chk_val('EX', atr(atp_id,3237)) F102_2,
       chk_val('UN', atr(atp_id,3237)) F102_3,
       atrChk(atp_id,3238) F103,
       atrChk(atp_id,3239) F104,
       atrChk(atp_id,3240) F105,
       atrChk(atp_id,3241) F106,
       atrChk(atp_id,3242) F107,
       atrChk(atp_id,3243) F108,
       atrChk(atp_id,3244) F109,
       atrChk(atp_id,3245) F110,
       SctChld(atp_id,125) f111,
       SctPrnt(atp_id,125) f112,
       SctNt  (atp_id,125) f113,
       --7) самообслуговування
       chk_val('NE', atr(atp_id,3249)) F114_1,
       chk_val('EX', atr(atp_id,3249)) F114_2,
       chk_val('UN', atr(atp_id,3249)) F114_3,
       atrChk(atp_id,3250) F115,
       atrChk(atp_id,3251) F116,
       atrChk(atp_id,3252) F117,
       atrChk(atp_id,3253) F118,
       atrChk(atp_id,3254) F119,
       atrChk(atp_id,3255) F120,
       SctChld(atp_id,126) f121,
       SctPrnt(atp_id,126) f122,
       SctNt  (atp_id,126) f123,
       atrNt (atp_id,3259) F124

 from uss_esr.v_at_section s, uss_esr.v_At_Person p
where s.ate_at = ActId() and s.ate_nng = :p_nng
  and p.atp_at = s.ate_at
  and p.atp_id = s.ate_atp
  and p.history_status = 'A'
  --and months_between(sysdate, p.atp_birth_dt)/12 < 18 --ознака дитини
order by p.atp_birth_dt
]';

        l_sql :=
            REGEXP_REPLACE (l_sql,
                            ':p_at_id',
                            p_at_id,
                            1,
                            0,
                            'i');
        l_sql :=
            REGEXP_REPLACE (l_sql,
                            ':p_nng',
                            C_P_NNG,
                            1,
                            0,
                            'i');
        RETURN l_sql;
    END;


    --повертає at_section.atef_feature.ate_notes
    FUNCTION Get_Section_Notes (p_at_Id   IN NUMBER,
                                p_nng        at_section.ate_nng%TYPE,
                                p_atp        at_person.atp_id%TYPE := -1)
        RETURN VARCHAR2
    IS
        r   VARCHAR2 (32000);
    BEGIN
        IF C_TEST = 1
        THEN
            RETURN p_nng;
        END IF;

        IF C_TEST = 2
        THEN
            RETURN 'Коменар,ввдений вручну';
        END IF;

        SELECT LISTAGG (s.ate_notes, c_chr10) WITHIN GROUP (ORDER BY 1)
          INTO r
          FROM uss_esr.at_section s
         WHERE     s.ate_at = p_at_id
               AND (p_atp = -1 OR s.ate_atp = p_atp)
               AND s.ate_nng = p_nng;

        RETURN r;
    END;

    FUNCTION get_Act_Prove_Dt (p_at_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_dt   VARCHAR2 (18);
    BEGIN
        SELECT TO_CHAR (MIN (h.hs_dt), 'DD.MM.YYYY')
          INTO l_dt
          FROM AT_log L JOIN uss_esr.histsession h ON h.hs_id = L.ATL_HS
         WHERE     atl_at = p_At_Id
               AND L.ATL_MESSAGE LIKE CHR (38) || '17'
               AND l.atl_st IN ('SA', 'SD');

        RETURN l_dt;
    END;

    FUNCTION get_sign_mark (p_at_id     IN NUMBER,
                            p_atp_id    IN NUMBER,
                            p_default   IN VARCHAR2 DEFAULT '______________')
        RETURN VARCHAR2
    IS
        l_cnt   NUMBER;
    BEGIN
        SELECT COUNT (*)
          INTO l_cnt
          FROM at_document t
         WHERE     t.atd_at = p_at_id
               AND t.atd_ndt = 1017
               AND t.history_status = 'A'
               AND t.atd_atp = p_atp_id;

        RETURN CASE WHEN l_cnt > 0 THEN 'pts' || p_atp_id ELSE p_default END;
    END;

    FUNCTION get_gender_sc (p_sc_id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_res   VARCHAR2 (1000);
    BEGIN
        l_res := uss_person.api$sc_tools.GET_GENDER (p_sc_id, 1);
        RETURN l_res;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    --загальна частина акту
    PROCEDURE bld_act_needs_assessment (p_at_id IN NUMBER)
    IS
        CURSOR c_at IS
            SELECT a.at_ap,
                   a.at_pc,
                   a.at_org,
                   a.at_dt,
                   a.at_action_start_dt,
                   a.at_action_stop_dt,
                   a.at_family_info,
                   a.at_live_address,
                   a.at_case_class,
                   a.at_cu,
                   a.at_rnspm,
                   p.atp_fact_address,
                   DECODE (a.at_tp, 'AVOP', 1)
                       is_AVOP,
                   --для APOP беремо з заяви, для AVOP - з at_tp='PDSP'
                   DECODE (a.at_tp, 'AVOP', a_pdsp.at_num, ap.ap_num)
                       num,
                   DECODE (a.at_tp, 'AVOP', a_pdsp.at_dt, ap.ap_reg_dt)
                       dt,
                   sc.sc_unique,
                   p.atp_id,
                   pc.pc_sc,
                   p.Atp_App_Tp,
                   a.at_main_link,
                   (SELECT COUNT (*)
                      FROM at_person z
                     WHERE z.atp_at = a.at_id AND z.history_status = 'A')
                       AS atp_cnt
              FROM uss_esr.act              a,
                   appeal                   ap,
                   uss_esr.personalcase     pc,
                   uss_esr.At_Person        p,
                   uss_person.v_socialcard  sc,
                   uss_esr.act              a_pdsp
             WHERE     a.at_id = p_at_id
                   AND pc.pc_id(+) = a.at_pc
                   AND p.atp_at = a.at_id
                   AND p.atp_sc = pc.pc_sc(+)
                   AND sc.sc_id(+) = a.at_sc
                   AND ap.ap_id(+) = a.at_ap
                   AND a_pdsp.at_ap(+) = a.at_ap
                   AND a_pdsp.at_tp(+) = 'PDSP';

        l_at     c_at%ROWTYPE;

        l_FAtp   NUMBER;                                             --особа 1
        l_MAtp   NUMBER;                                             --особа 2

        l_str    VARCHAR2 (32000);

        --повертає at_section.atef_feature.ate_notes
        FUNCTION Comnt (p_nng   at_section.ate_nng%TYPE,
                        p_atp   at_person.atp_id%TYPE:= -1)
            RETURN VARCHAR2
        IS
            r   VARCHAR2 (32000);
        BEGIN
            IF C_TEST = 1
            THEN
                RETURN p_nng;
            END IF;

            IF C_TEST = 2
            THEN
                RETURN 'Коменар,ввдений вручну';
            END IF;

            SELECT LISTAGG (s.ate_notes, c_chr10) WITHIN GROUP (ORDER BY 1)
              INTO r
              FROM uss_esr.at_section s
             WHERE     s.ate_at = p_at_id
                   AND (p_atp = -1 OR s.ate_atp = p_atp)
                   AND s.ate_nng = p_nng;

            RETURN r;
        END;
    BEGIN
        OPEN c_at;

        FETCH c_at INTO l_at;

        CLOSE c_at;

        --шукаємо по секції з заповненими даними двох осіб
        /*  select max(s.ate_atp),
                 case when max(s.ate_atp) <> min(s.ate_atp) then min(s.ate_atp) end
            into l_FAtp, l_MAtp
            from uss_esr.at_section s
            join at_person p on (p.atp_id = s.ate_atp)
            where s.ate_at = p_at_id and s.ate_nng = 128;*/
        SELECT MAX (p1), MAX (p2)
          INTO l_FAtp, l_MAtp
          FROM (  SELECT s.ate_atp                  AS p1,
                         LEAD (s.ate_atp)
                             OVER (ORDER BY
                                       p.atp_birth_dt,
                                       p.atp_ln,
                                       p.atp_fn,
                                       p.atp_mn)    AS p2
                    FROM uss_esr.at_section s
                         JOIN at_person p
                             ON (    p.atp_id = s.ate_atp
                                 AND p.history_status = 'A')
                   WHERE s.ate_at = p_at_id AND s.ate_nng = 128
                ORDER BY p.atp_birth_dt,
                         p.atp_ln,
                         p.atp_fn,
                         p.atp_mn
                   FETCH FIRST ROW ONLY);

        --  raise_application_error(-20000, 'l_FAtp='||l_FAtp||';l_MAtp='||l_MAtp);

        --1. Загальна інформація про членів сім’ї
        addparam ('f1', l_at.num);                            --№ повідомлення
        addparam ('f2', TO_CHAR (l_at.dt, 'dd.mm.yyyy'));
        addparam ('f3', Get_Nsp_Name (p_rnspm_id => l_at.At_rnspm)); --Організація
        addparam ('f4', GetCuPIB (l_at.at_cu)); --Фахівець, відповідальний за проведення
        addparam (
            'f5',
            NVL (TO_CHAR (l_at.at_action_start_dt, 'dd.mm.yyyy'),
                 c_date_empty2));                                    --Початок
        addparam (
            'f6',
            NVL (TO_CHAR (l_at.at_action_stop_dt, 'dd.mm.yyyy'),
                 c_date_empty2));

        addparam ('f7', l_at.at_family_info); --Загальна інформація про членів сім’ї
        addparam ('f8', NVL (l_at.at_live_address, l_at.atp_fact_address)); --Місце проживання

        --члени родини
        l_str := q'[
     select
           row_number() over(order by birth_dt) as "F09",
           pib          as F9,
           birth_dt_str as F10,
           Relation_Tp  as F11,
           case when is_disabled = 'T' then 'наявна' else 'відсутня' end F12,
           case when is_capable  = 'T' then 'дієздатний(а)'
                when is_capable  = 'F' then 'недієздатний(а)'
           end        as F13_old,
           case when trunc(months_between(sysdate, t.birth_dt)/12) > 18 and
                     is_capable = 'T' then uss_esr.Api$Act_Rpt.Chk_Val2(1,1)
                else uss_esr.Api$Act_Rpt.Chk_Val2(1,2)
           end as F13,
           work_place as F14,
           case when is_adr_matching = 'T' then 'Так' end as F15,
           case when is_adr_matching = 'F' then 'Ні'  end as F16,
           phone        as F17,
           Fact_Address as F18
     from table(uss_esr.Api$Act_Rpt.At_Person_for_act(:p_at_id)) t
     order by atp_num--birth_dt, pib
   ]';
        l_str :=
            REGEXP_REPLACE (l_str,
                            ':p_at_id',
                            p_at_id,
                            1,
                            0,
                            'i');
        rdm$rtfl_univ.AddDataset ('ds_fam', l_str);

        --2. Стан та потреби дитини, ets
        rdm$rtfl_univ.AddDataset ('ds_child', ds_child (p_at_id));

        --3. Стан дорослих членів сім’ї
        addparam ('F125', get_AtPerson (p_at_id, l_FAtp).pib);
        addparam ('F125-1', get_AtPerson (p_at_id, l_MAtp).pib);
        addparam ('F126', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3269));
        addparam ('F126-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3269));
        --Коментарі
        addparam ('F126-1', Comnt (p_nng => 128)); --mOthers(Get_Ftr_Nt(p_at_id, l_FAtp, 3269),Get_Ftr_Nt(p_at_id, l_MAtp, 3269)));

        -- Має інвалідність: блок підкреслення
        /*
        declare
          aInt     TInt;
        begin
          l_str:= '3270з порушенням опорно-рухового апарату та центральної і периферичної нервової системи3270,'||c_chr10||
                  '3271органів слуху3271,'||c_chr10||
                  '3272органів зору3272,'||c_chr10||
                  '3273внутрішніх органів3273,'||c_chr10||
                  '3274з психічними захворюваннями та розумовою відсталістю3274,'||c_chr10||
                  '3275з онкологічними захворюваннями3275';
          aInt:= TInt(3270, 3271, 3272, 3273, 3274, 3275);
          for i in 1..aInt.count loop
            if Get_Ftr(p_at_id, l_FAtp, aInt(i)) = 'T' or Get_Ftr(p_at_id, l_MAtp, aInt(i)) = 'T' then
              l_str:= regexp_replace(l_str, aInt(i), '\ul', 1, 1);
              l_str:= regexp_replace(l_str, aInt(i), '\ul0', 1, 1);
             else
              l_str:= replace(l_str, aInt(i));
             end if;
          end loop;

          addparam('F127',  l_str);
        end;*/


        --у прив'язці до l_FAtp/l_MAtp
        l_str :=
               UnderLine (
                   Get_Ndi_Doc_Atr (p_Nda => 3270).nda_name, --з порушенням опорно-рухового апарату та центральної і периферичної нервової системи,',
                      Get_Ftr (p_at_id, l_FAtp, 3270) = 'T'
                   OR Get_Ftr (p_at_id, l_MAtp, 3270) = 'T')
            || c_chr10
            || UnderLine (
                   Get_Ndi_Doc_Atr (p_Nda => 3271).nda_name, --'органів слуху,',
                      Get_Ftr (p_at_id, l_FAtp, 3271) = 'T'
                   OR Get_Ftr (p_at_id, l_MAtp, 3271) = 'T')
            || c_chr10
            || UnderLine (
                   Get_Ndi_Doc_Atr (p_Nda => 3272).nda_name, --'органів зору,',
                      Get_Ftr (p_at_id, l_FAtp, 3272) = 'T'
                   OR Get_Ftr (p_at_id, l_MAtp, 3272) = 'T')
            || c_chr10
            || UnderLine (
                   Get_Ndi_Doc_Atr (p_Nda => 3273).nda_name, --'внутрішніх органів,',
                      Get_Ftr (p_at_id, l_FAtp, 3273) = 'T'
                   OR Get_Ftr (p_at_id, l_MAtp, 3273) = 'T')
            || c_chr10
            || UnderLine (
                   Get_Ndi_Doc_Atr (p_Nda => 3274).nda_name, --'з психічними захворюваннями та розумовою відсталістю,',
                      Get_Ftr (p_at_id, l_FAtp, 3274) = 'T'
                   OR Get_Ftr (p_at_id, l_MAtp, 3274) = 'T')
            || c_chr10
            || UnderLine (
                   Get_Ndi_Doc_Atr (p_Nda => 3275).nda_name, --'з онкологічними захворюваннями',
                      Get_Ftr (p_at_id, l_FAtp, 3275) = 'T'
                   OR Get_Ftr (p_at_id, l_MAtp, 3275) = 'T');
        addparam ('F127', l_str);


        l_str :=
               Get_Ftr (p_at_id, l_FAtp, 3270)
            || Get_Ftr (p_at_id, l_FAtp, 3271)
            || Get_Ftr (p_at_id, l_FAtp, 3272)
            || Get_Ftr (p_at_id, l_FAtp, 3273)
            || Get_Ftr (p_at_id, l_FAtp, 3274)
            || Get_Ftr (p_at_id, l_FAtp, 3275);
        l_str := REPLACE (l_str, 'F');

        IF l_str LIKE '%T%'
        THEN
            addparam ('F133', c_chk);
        ELSE
            addparam ('F133', c_unchk);
        END IF;

        l_str :=
               Get_Ftr (p_at_id, l_MAtp, 3270)
            || Get_Ftr (p_at_id, l_MAtp, 3271)
            || Get_Ftr (p_at_id, l_MAtp, 3272)
            || Get_Ftr (p_at_id, l_MAtp, 3273)
            || Get_Ftr (p_at_id, l_MAtp, 3274)
            || Get_Ftr (p_at_id, l_MAtp, 3275);
        l_str := REPLACE (l_str, 'F');

        IF l_str LIKE '%T%'
        THEN
            addparam ('F133-2', c_chk);
        ELSE
            addparam ('F133-2', c_unchk);
        END IF;

        addparam ('F134', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3276));
        addparam ('F134-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3276));
        addparam ('F135', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3277));
        addparam ('F135-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3277));
        --інше
        addparam (
            'F136',
            mOthers (Get_Ftr_Nt (p_at_id, l_FAtp, 3277),
                     Get_Ftr_Nt (p_at_id, l_MAtp, 3277)));

        --Висновок щодо стану здоров’я
        --довідник: задовільний[STS]; незадовільний[N]; невідомо[F] select * from uss_ndi.v_ddn_ss_sts t
        addparam ('F137-1',
                  chk_val2 ('STS', Get_Ftr (p_at_id, l_FAtp, 3289)));
        addparam ('F137-2', chk_val2 ('N', Get_Ftr (p_at_id, l_FAtp, 3289)));
        addparam ('F137-3', chk_val2 ('F', Get_Ftr (p_at_id, l_FAtp, 3289)));
        addparam ('F137-21',
                  chk_val2 ('STS', Get_Ftr (p_at_id, l_MAtp, 3289)));
        addparam ('F137-22', chk_val2 ('N', Get_Ftr (p_at_id, l_MAtp, 3289)));
        addparam ('F137-23', chk_val2 ('F', Get_Ftr (p_at_id, l_MAtp, 3289)));

        --2) емоційний стан
        addparam ('F139', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3290));
        addparam ('F139-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3290));
        --Коментарі
        addparam (
            'F139-1',
            mOthers (Get_Ftr_Nt (p_at_id, l_FAtp, 3290),
                     Get_Ftr_Nt (p_at_id, l_MAtp, 3290)));

        addparam ('F140', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3291));
        addparam ('F140-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3291));
        addparam ('F141', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3292));
        addparam ('F141-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3292));
        addparam ('F142', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3293));
        addparam ('F142-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3293));
        addparam ('F143', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3294));
        addparam ('F143-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3294));
        addparam ('F144', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3295));
        addparam ('F144-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3295));
        addparam ('F145', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3296));
        addparam ('F145-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3296));
        addparam ('F146', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3297));
        addparam ('F146-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3297));
        addparam ('F147', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3298));
        addparam ('F147-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3298));
        addparam ('F148', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3299));
        addparam ('F148-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3299));
        --інше
        addparam (
            'F149',
            mOthers (Get_Ftr_Nt (p_at_id, l_FAtp, 3299),
                     Get_Ftr_Nt (p_at_id, l_MAtp, 3299)));
        --Висновок щодо емоційного стану  uss_ndi.V_DDN_SS_STS
        addparam ('F150-1',
                  chk_val2 ('STS', Get_Ftr (p_at_id, l_FAtp, 3302)));
        addparam ('F150-2', chk_val2 ('N', Get_Ftr (p_at_id, l_FAtp, 3302)));
        addparam ('F150-3', chk_val2 ('F', Get_Ftr (p_at_id, l_FAtp, 3302)));
        addparam ('F150-21',
                  chk_val2 ('STS', Get_Ftr (p_at_id, l_MAtp, 3302)));
        addparam ('F150-22', chk_val2 ('N', Get_Ftr (p_at_id, l_MAtp, 3302)));
        addparam ('F150-23', chk_val2 ('F', Get_Ftr (p_at_id, l_MAtp, 3302)));
        --Коментарі
        addparam ('F151', Comnt (p_nng => 129)); --mOthers(Get_Ftr_Nt(p_at_id, l_FAtp, 3301),Get_Ftr_Nt(p_at_id, l_MAtp, 3301)));

        --3) шкідливі звички
        addparam ('F152', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3303));
        addparam ('F152-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3303));
        addparam ('F153', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3304));
        addparam ('F153-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3304));
        addparam ('F154', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3305));
        addparam ('F154-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3305));
        addparam ('F155', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3306));
        addparam ('F155-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3306));
        addparam ('F156', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3307));
        addparam ('F156-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3307));
        addparam ('F157', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3308));
        addparam ('F157-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3308));
        addparam ('F158', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3309));
        addparam ('F158-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3309));
        addparam ('F159', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3310));
        addparam ('F159-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3310));
        addparam ('F160', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3311));
        addparam ('F160-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3311));
        --інше
        addparam (
            'F161',
            mOthers (Get_Ftr_Nt (p_at_id, l_FAtp, 3311),
                     Get_Ftr_Nt (p_at_id, l_MAtp, 3311)));
        --Висновок щодо наявності ознак девіантної поведінки uss_ndi.V_DDN_EXIST_SGN1
        addparam ('F162-1',
                  Get_Ftr_Chk2 (p_at_id,
                                l_FAtp,
                                p_Nda   => 3315,
                                p_Chk   => 'NE'));
        addparam ('F162-2',
                  Get_Ftr_Chk2 (p_at_id,
                                l_FAtp,
                                p_Nda   => 3315,
                                p_Chk   => 'EX'));
        addparam ('F162-3',
                  Get_Ftr_Chk2 (p_at_id,
                                l_FAtp,
                                p_Nda   => 3315,
                                p_Chk   => 'UN'));
        addparam ('F162-21',
                  Get_Ftr_Chk2 (p_at_id,
                                l_MAtp,
                                p_Nda   => 3315,
                                p_Chk   => 'NE'));
        addparam ('F162-22',
                  Get_Ftr_Chk2 (p_at_id,
                                l_MAtp,
                                p_Nda   => 3315,
                                p_Chk   => 'EX'));
        addparam ('F162-23',
                  Get_Ftr_Chk2 (p_at_id,
                                l_MAtp,
                                p_Nda   => 3315,
                                p_Chk   => 'UN'));
        --Коментарі
        addparam ('F163', Comnt (p_nng => 130)); --mOthers(Get_Ftr_Nt(p_at_id, l_FAtp, 3314),Get_Ftr_Nt(p_at_id, l_MAtp, 3314)));

        --4) соціальні контакти
        addparam ('F164', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3316));
        addparam ('F164-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3316));
        addparam ('F165', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3317));
        addparam ('F165-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3317));
        addparam ('F166-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3318));
        --Коментарі
        addparam ('F166', Comnt (p_nng => 131)); --mOthers(Get_Ftr_Nt(p_at_id, l_FAtp, 3318),Get_Ftr_Nt(p_at_id, l_MAtp, 3318)));

        --5) соціальна історія
        --був(була)
        addparam ('F167', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3319));
        addparam ('F167-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3319));
        addparam ('F168', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3320));
        addparam ('F168-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3320));
        addparam ('F169', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3321));
        addparam ('F169-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3321));
        addparam ('F170', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3322));
        addparam ('F170-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3322));
        addparam ('F171', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3323));
        addparam ('F171-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3323));
        addparam ('F172', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3324));
        addparam ('F172-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3324));
        addparam ('F173', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3325));
        addparam ('F173-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3325));
        addparam ('F174', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3326));
        addparam ('F174-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3326));
        --є
        addparam ('f167d', Get_Ftr_Chk2 (p_at_id, l_FAtp, 7401));
        addparam ('f167d-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 7401));
        addparam ('f168d', Get_Ftr_Chk2 (p_at_id, l_FAtp, 7402));
        addparam ('f168d-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 7402));
        addparam ('f169d', Get_Ftr_Chk2 (p_at_id, l_FAtp, 7404));
        addparam ('f169d-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 7404));
        addparam ('f170d', Get_Ftr_Chk2 (p_at_id, l_FAtp, 7405));
        addparam ('f170d-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 7405));
        addparam ('f171d', Get_Ftr_Chk2 (p_at_id, l_FAtp, 7406));
        addparam ('f171d-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 7406));
        addparam ('f172d', Get_Ftr_Chk2 (p_at_id, l_FAtp, 7407));
        addparam ('f172d-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 7407));
        addparam ('f173d', Get_Ftr_Chk2 (p_at_id, l_FAtp, 7408));
        addparam ('f173d-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 7408));

        addparam ('F175', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3327)); --Перебуває під слідством.
        addparam ('F175-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3327));
        addparam ('F176', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3328));        --інше
        addparam ('F176-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3328));
        --інше (коментар)
        addparam (
            'F177',
            mOthers (Get_Ftr_Nt (p_at_id, l_FAtp, 3328),
                     Get_Ftr_Nt (p_at_id, l_MAtp, 3328)));

        addparam ('F178', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3330));
        addparam ('F178-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3330));
        addparam ('F179', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3331));
        addparam ('F179-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3331));
        --Висновок щодо впливу соціальної історії uss_ndi.V_DDN_SS_PST
        addparam ('F180-1',
                  chk_val2 ('PST', Get_Ftr (p_at_id, l_FAtp, 3333)));
        addparam ('F180-2', chk_val2 ('N', Get_Ftr (p_at_id, l_FAtp, 3333)));
        addparam ('F180-3', chk_val2 ('F', Get_Ftr (p_at_id, l_FAtp, 3333)));
        addparam ('F180-21',
                  chk_val2 ('PST', Get_Ftr (p_at_id, l_MAtp, 3333)));
        addparam ('F180-22', chk_val2 ('N', Get_Ftr (p_at_id, l_MAtp, 3333)));
        addparam ('F180-23', chk_val2 ('F', Get_Ftr (p_at_id, l_MAtp, 3333)));
        --Коментарі
        addparam ('F181', Comnt (p_nng => 132)); --mOthers(Get_Ftr_Nt(p_at_id, l_FAtp, 3332),Get_Ftr_Nt(p_at_id, l_MAtp, 3332)));

        --6) зайнятість
        addparam ('F182', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3334));
        addparam ('F182-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3334));
        addparam ('F183', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3335));
        addparam ('F183-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3335));
        addparam ('F184', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3336));
        addparam ('F184-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3336));
        addparam ('F185', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3337));
        addparam ('F185-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3337));
        addparam ('F186', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3338));
        addparam ('F186-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3338));
        addparam ('F187', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3339));
        addparam ('F187-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3339));
        addparam ('F188', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3340));
        addparam ('F188-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3340));
        addparam ('F189', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3341));
        addparam ('F189-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3341));
        addparam ('F190', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3342));
        addparam ('F190-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3342));
        addparam ('F191', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3343));
        addparam ('F191-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3343));
        addparam ('F192', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3344));
        addparam ('F192-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3344));
        --інше
        addparam (
            'F193',
            mOthers (Get_Ftr_Nt (p_at_id, l_FAtp, 3344),
                     Get_Ftr_Nt (p_at_id, l_MAtp, 3344)));
        --Висновок щодо впливу зайнятості  uss_ndi.V_DDN_SS_PST
        addparam ('F194-1',
                  chk_val2 ('PST', Get_Ftr (p_at_id, l_FAtp, 3348)));
        addparam ('F194-2', chk_val2 ('N', Get_Ftr (p_at_id, l_FAtp, 3348)));
        addparam ('F194-3', chk_val2 ('F', Get_Ftr (p_at_id, l_FAtp, 3348)));
        addparam ('F194-21',
                  chk_val2 ('PST', Get_Ftr (p_at_id, l_MAtp, 3348)));
        addparam ('F194-22', chk_val2 ('N', Get_Ftr (p_at_id, l_MAtp, 3348)));
        addparam ('F194-23', chk_val2 ('F', Get_Ftr (p_at_id, l_MAtp, 3348)));
        --Коментарі
        addparam ('F195', Comnt (p_nng => 133)); --mOthers(Get_Ftr_Nt(p_at_id, l_FAtp, 3346),Get_Ftr_Nt(p_at_id, l_MAtp, 3346)));
        addparam (
            'F196',
            mOthers (Get_Ftr_Nt (p_at_id, l_FAtp, 3347),
                     Get_Ftr_Nt (p_at_id, l_MAtp, 3347)));              --інше

        --7) самообслуговування
        addparam ('F197', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3349));
        addparam ('F197-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3349));
        addparam ('F198', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3350));
        addparam ('F198-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3350));
        addparam ('F199', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3351));
        addparam ('F199-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3351));
        addparam ('F200', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3352));
        addparam ('F200-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3352));
        addparam ('F201', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3353));
        addparam ('F201-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3353));
        addparam ('F202', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3354));
        addparam ('F202-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3354));
        addparam ('F203', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3355));
        addparam ('F203-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3355));
        addparam ('F204', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3356));
        addparam ('F204-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3356));
        addparam ('F205', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3357));
        addparam ('F205-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3357));
        addparam ('F206', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3358));
        addparam ('F206-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3358));
        addparam ('F207', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3359));
        addparam ('F207-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3359));
        addparam ('F208', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3360));
        addparam ('F208-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3360));
        --Висновок щодо здатності до самообслуговування  uss_ndi.V_DDN_SS_CAPABLE
        addparam ('F209-1',
                  chk_val2 ('CPB', Get_Ftr (p_at_id, l_FAtp, 3362)));
        addparam ('F209-2',
                  chk_val2 ('PRT', Get_Ftr (p_at_id, l_FAtp, 3362)));
        addparam ('F209-3',
                  chk_val2 ('NOT', Get_Ftr (p_at_id, l_FAtp, 3362)));
        addparam ('F209-21',
                  chk_val2 ('CPB', Get_Ftr (p_at_id, l_MAtp, 3362)));
        addparam ('F209-22',
                  chk_val2 ('PRT', Get_Ftr (p_at_id, l_MAtp, 3362)));
        addparam ('F209-23',
                  chk_val2 ('NOT', Get_Ftr (p_at_id, l_MAtp, 3362)));

        --Коментарі
        addparam ('F210', Comnt (p_nng => 134)); --mOthers(Get_Ftr_Nt(p_at_id, l_FAtp, 3361),Get_Ftr_Nt(p_at_id, l_MAtp, 3361)));

        --8) виконання батьківських обов’язків
        addparam ('F211', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3363));
        addparam ('F211-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3363));
        addparam ('F212', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3364));
        addparam ('F212-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3364));
        addparam ('F213', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3365));
        addparam ('F213-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3365));
        addparam ('F214', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3366));
        addparam ('F214-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3366));
        addparam ('F215', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3367));
        addparam ('F215-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3367));
        addparam ('F216', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3368));
        addparam ('F216-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3368));
        addparam ('F217', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3369));
        addparam ('F217-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3369));
        addparam ('F218', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3370));
        addparam ('F218-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3370));
        addparam ('F219', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3371));
        addparam ('F219-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3371));
        addparam ('F220', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3372));
        addparam ('F220-2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3372));
        --Висновок щодо стану виконання батьком/ матір’ю батьківських обов’язків uss_ndi.V_DDN_SS_PERFORMS
        addparam ('F221-1',
                  chk_val2 ('PRF', Get_Ftr (p_at_id, l_FAtp, 3374)));
        addparam ('F221-2',
                  chk_val2 ('PRT', Get_Ftr (p_at_id, l_FAtp, 3374)));
        addparam ('F221-3',
                  chk_val2 ('NOT', Get_Ftr (p_at_id, l_FAtp, 3374)));
        addparam ('F221-21',
                  chk_val2 ('PRF', Get_Ftr (p_at_id, l_MAtp, 3374)));
        addparam ('F221-22',
                  chk_val2 ('PRT', Get_Ftr (p_at_id, l_MAtp, 3374)));
        addparam ('F221-23',
                  chk_val2 ('NOT', Get_Ftr (p_at_id, l_MAtp, 3374)));
        --Коментарі
        addparam ('F222', Comnt (p_nng => 135)); --mOthers(Get_Ftr_Nt(p_at_id, l_FAtp, 3373),Get_Ftr_Nt(p_at_id, l_MAtp, 3373)));

        --4. Фактори сім’ї та середовища
        --1) мережа соціального супроводу сім’ї uss_ndi.V_DDN_SS_AVL
        addparam ('F223-1', chk_val2 ('N', Get_Ftr (p_at_id, p_nda => 3375)));
        addparam ('F223-2',
                  chk_val2 ('AVL', Get_Ftr (p_at_id, p_nda => 3375)));
        addparam ('F223-3', chk_val2 ('F', Get_Ftr (p_at_id, p_nda => 3375)));

        addparam ('F224', Get_Ftr_Chk2 (p_at_id, p_nda => 3376));
        addparam ('F225', Get_Ftr_Chk2 (p_at_id, p_nda => 3377));
        --Коментарі
        addparam ('F226', get_AtSctNt (p_at_id, p_nng => 136));

        --2) соціальні стосунки сім’ї uss_ndi.V_DDN_SS_STS
        addparam ('F227-1',
                  chk_val2 ('STS', Get_Ftr (p_at_id, p_nda => 3379)));
        addparam ('F227-2', chk_val2 ('N', Get_Ftr (p_at_id, p_nda => 3379)));
        addparam ('F227-3', chk_val2 ('F', Get_Ftr (p_at_id, p_nda => 3379)));

        addparam ('F228', Get_Ftr_Chk2 (p_at_id, p_nda => 3380));
        addparam ('F229', Get_Ftr_Chk2 (p_at_id, p_nda => 3381));
        addparam ('F230', Get_Ftr_Chk2 (p_at_id, p_nda => 3382));
        addparam ('F231', Get_Ftr_Chk2 (p_at_id, p_nda => 3383));
        addparam ('F232', Get_Ftr_Chk2 (p_at_id, p_nda => 3384));
        addparam ('F233', Get_Ftr_Chk2 (p_at_id, p_nda => 3385));
        addparam ('F234', Get_Ftr_Chk2 (p_at_id, p_nda => 3386));
        addparam ('F235', Get_Ftr_Chk2 (p_at_id, p_nda => 3387));
        addparam ('F236', Get_Ftr_Chk2 (p_at_id, p_nda => 3388));
        addparam ('F237', Get_Ftr_Chk2 (p_at_id, p_nda => 3389));
        addparam ('F237-1', Get_Ftr_Nt (p_at_id, p_nda => 3389));
        addparam ('F238', get_AtSctNt (p_at_id, p_nng => 137));    --Коментарі

        --3) основні доходи сім’ї uss_ndi.V_DDN_SS_STS
        addparam ('F239-1',
                  chk_val2 ('STS', Get_Ftr (p_at_id, p_nda => 3391)));
        addparam ('F239-2', chk_val2 ('N', Get_Ftr (p_at_id, p_nda => 3391)));
        addparam ('F239-3', chk_val2 ('F', Get_Ftr (p_at_id, p_nda => 3391)));

        addparam ('F240', Get_Ftr_Chk2 (p_at_id, p_nda => 3392));
        addparam ('F241', Get_Ftr_Chk2 (p_at_id, p_nda => 3393));
        addparam ('F242', Get_Ftr_Chk2 (p_at_id, p_nda => 3394));
        addparam ('F243', Get_Ftr_Chk2 (p_at_id, p_nda => 3395));
        addparam ('F244', Get_Ftr_Chk2 (p_at_id, p_nda => 3396));
        addparam ('F245', Get_Ftr_Chk2 (p_at_id, p_nda => 3397));
        addparam ('F246', Get_Ftr_Chk2 (p_at_id, p_nda => 3398));
        addparam ('F247', Get_Ftr_Chk2 (p_at_id, p_nda => 3399));
        addparam ('F248', Get_Ftr_Chk2 (p_at_id, p_nda => 3400));
        addparam ('F249', Get_Ftr_Chk2 (p_at_id, p_nda => 3401));
        addparam ('F250', Get_Ftr_Chk2 (p_at_id, p_nda => 3402));
        addparam ('F250-1', Get_Ftr_Nt (p_at_id, p_nda => 3402));
        addparam ('F251', get_AtSctNt (p_at_id, p_nng => 138));    --Коментарі

        --4) борги  uss_ndi.V_DDN_EXIST_SGN1
        addparam ('F252-1', chk_val2 ('NE', Get_Ftr (p_at_id, p_nda => 3404)));
        addparam ('F252-2', chk_val2 ('EX', Get_Ftr (p_at_id, p_nda => 3404)));
        addparam ('F252-3', chk_val2 ('UN', Get_Ftr (p_at_id, p_nda => 3404)));
        addparam ('F253', Get_Ftr_Chk2 (p_at_id, p_nda => 3405));
        addparam ('F254', Get_Ftr_Chk2 (p_at_id, p_nda => 3406));
        addparam ('F255', Get_Ftr_Chk2 (p_at_id, p_nda => 3407));
        addparam ('F256', Get_Ftr_Chk2 (p_at_id, p_nda => 3408));
        addparam ('F256-1', Get_Ftr_Nt (p_at_id, p_nda => 3408));
        addparam ('F257', get_AtSctNt (p_at_id, p_nng => 139));    --Коментарі

        --5) члени сім’ї, інші особи, які проживають разом uss_ndi.V_DDN_EXIST_SGN1
        addparam ('F258-1', chk_val2 ('NE', Get_Ftr (p_at_id, p_nda => 3410)));
        addparam ('F258-2', chk_val2 ('EX', Get_Ftr (p_at_id, p_nda => 3410)));
        addparam ('F258-3', chk_val2 ('UN', Get_Ftr (p_at_id, p_nda => 3410)));
        addparam ('F259', Get_Ftr_Chk2 (p_at_id, p_nda => 3411));
        addparam ('F260', Get_Ftr_Chk2 (p_at_id, p_nda => 3412));
        addparam ('F261', Get_Ftr_Chk2 (p_at_id, p_nda => 3413));
        addparam ('F262', Get_Ftr_Chk2 (p_at_id, p_nda => 3414));
        addparam ('F263', Get_Ftr_Chk2 (p_at_id, p_nda => 3415));
        addparam ('F263-1', Get_Ftr_Nt (p_at_id, p_nda => 3415));
        addparam ('F264', get_AtSctNt (p_at_id, p_nng => 140));    --Коментарі

        --6) помешкання та його стан - перенесено у відповідні процедури, бо різне наповнення

        --5. Класифікація випадку  Uss_Ndi.v_Ddn_Case_Class
        addparam ('F283-1', chk_val2 ('SM', l_at.at_case_class));
        addparam ('F283-2', chk_val2 ('MD', l_at.at_case_class));
        addparam ('F283-3', chk_val2 ('DF', l_at.at_case_class));
        addparam ('F283-4', chk_val2 ('EM', l_at.at_case_class));
    END bld_act_needs_assessment;

    --#89905 АКТ оцінки потреб сім’ї APOP  804  APOP
    FUNCTION BUILD_ACT_NEEDS_ASSESSMENT (p_at_id IN NUMBER)
        RETURN BLOB
    IS
        --select t.*, rowid from uss_esr.rpt_templates t where t.rt_code = 'ACT_NEEDS_ASSESSMENT';
        l_jbr_id      NUMBER;
        l_result      BLOB;

        CURSOR c_at IS
            SELECT a.at_ap,
                   a.at_pc,
                   a.at_org,
                   a.at_dt,
                   a.at_action_start_dt,
                   a.at_action_stop_dt,
                   a.at_family_info,
                   a.at_live_address,
                   a.at_case_class,
                   a.at_cu,
                   a.at_rnspm,
                   a.at_redirect_rnspm,
                   a.at_sc                                   --, sc.sc_unique,
              --p.atp_id, pc.pc_sc, p.Atp_App_Tp
              FROM uss_esr.act a --, uss_esr.personalcase pc, uss_esr.At_Person p, uss_person.v_socialcard sc
             WHERE a.at_id = p_at_id--and pc.pc_id = a.at_pc
                                    --and p.atp_at = a.at_id
                                    --and p.atp_sc = pc.pc_sc
                                    --and sc.sc_id = a.at_sc
                                    ;

        c             c_at%ROWTYPE;

        --підписанти
        CURSOR c_sgn (p_tp VARCHAR2)
        IS
            SELECT --Nvl(GetCuPIB(s.ati_Cu), Tools.Getuserpib(s.ati_wu))  pib,
                   s.*
              FROM uss_esr.at_signers s
             WHERE     s.ati_at = p_at_id
                   AND s.ati_tp = p_tp
                   AND s.history_status = 'A'
                   AND s.ati_is_signed = 'T';

        r_sgn         c_sgn%ROWTYPE;

        l_FAtp        NUMBER;                                        --особа 1
        l_MAtp        NUMBER;                                        --особа 2

        l_atp_Id      NUMBER;
        l_person_os   r_Person_for_Act;

        l_str         VARCHAR2 (32000);
        l_sc_unique   VARCHAR2 (50);
        l_cnt         NUMBER;
    BEGIN
        rdm$rtfl_univ.initreport (p_code     => 'ACT_NEEDS_ASSESSMENT',
                                  p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);

        --rdm$rtfl_univ.get_report_result(p_jbr_id => l_jbr_id, p_rpt_blob => l_result);
        --replace_ekr(l_result);
        --return l_result;

        --загальна частина акту
        bld_act_needs_assessment (p_at_id => p_at_id);

        OPEN c_at;

        FETCH c_at INTO c;

        CLOSE c_at;

        --шукаємо по секції з заповненими даними двох осіб
        SELECT MAX (s.ate_atp),
               CASE
                   WHEN MAX (s.ate_atp) <> MIN (s.ate_atp)
                   THEN
                       MIN (s.ate_atp)
               END
          INTO l_FAtp, l_MAtp
          FROM uss_esr.at_section s
         WHERE s.ate_at = p_at_id AND s.ate_nng = 128;


        --4. Фактори сім’ї та середовища
        --6) помешкання та його стан uss_ndi.V_DDN_SS_STS
        addparam ('F265-1',
                  chk_val2 ('STS', Get_Ftr (p_at_id, p_nda => 3417)));
        addparam ('F265-2', chk_val2 ('N', Get_Ftr (p_at_id, p_nda => 3417)));
        addparam ('F265-3', chk_val2 ('F', Get_Ftr (p_at_id, p_nda => 3417)));
        addparam ('F266', Get_Ftr_Chk2 (p_at_id, p_nda => 3418));
        addparam ('F267', Get_Ftr_Chk2 (p_at_id, p_nda => 3419));
        addparam ('F268', Get_Ftr_Chk2 (p_at_id, p_nda => 3420));
        addparam ('F269', Get_Ftr_Chk2 (p_at_id, p_nda => 3421));
        --addparam('F269-1',  Get_Ftr_Chk2(p_at_id, p_nda => 7409));
        addparam ('F270', Get_Ftr_Chk2 (p_at_id, p_nda => 3422));
        --addparam('F270-1',  Get_Ftr_Chk2(p_at_id, p_nda => 7410));
        --addparam('F270-2',  Get_Ftr_Chk2(p_at_id, p_nda => 7411));
        addparam ('F271', Get_Ftr_Chk2 (p_at_id, p_nda => 3423));
        addparam ('F272', Get_Ftr_Chk2 (p_at_id, p_nda => 3424));
        addparam ('F273', Get_Ftr_Chk2 (p_at_id, p_nda => 3425));
        addparam ('F274', Get_Ftr_Chk2 (p_at_id, p_nda => 3426));
        addparam ('F275', Get_Ftr_Chk2 (p_at_id, p_nda => 3427));
        addparam ('F276', Get_Ftr_Chk2 (p_at_id, p_nda => 3428));
        addparam ('F277', Get_Ftr_Chk2 (p_at_id, p_nda => 3429));
        addparam ('F278', Get_Ftr_Chk2 (p_at_id, p_nda => 3430));
        addparam ('F279', Get_Ftr_Chk2 (p_at_id, p_nda => 3431));
        addparam ('F280', Get_Ftr_Chk2 (p_at_id, p_nda => 3432));
        addparam ('F281', Get_Ftr_Chk2 (p_at_id, p_nda => 3433));
        addparam ('F281-1', Get_Ftr_Nt (p_at_id, p_nda => 3433));
        addparam ('F282', get_AtSctNt (p_at_id, p_nng => 141));    --Коментарі


        ----------------------------------------------------
        ----------------------------------------------------
        -- ВИСНОВОК
        ----------------------------------------------------
        ----------------------------------------------------

        SELECT MAX (m)
          INTO l_sc_unique
          FROM (SELECT FIRST_VALUE (s.nsj_num)
                           OVER (
                               ORDER BY
                                   DECODE (pp.atp_app_tp,
                                           'Z', 1,
                                           'OS', 2,
                                           'FMS', 3,
                                           4))    AS m
                  FROM uss_esr.act  t
                       JOIN uss_esr.act a ON (a.at_id = t.at_main_link)
                       JOIN uss_esr.at_person pp
                           ON (    pp.atp_at = a.at_id
                               AND pp.atp_app_tp IN ('Z', 'OS', 'FMS'))
                       JOIN uss_esr.nsp_sc_journal s
                           ON (    s.nsj_rnspm = a.at_rnspm
                               AND s.nsj_sc = pp.atp_sc)
                 WHERE     t.at_id = p_at_id
                       AND a.at_st NOT IN ('VR',
                                           'VD',
                                           'VA',
                                           'AD',
                                           'AR')
                 FETCH FIRST ROW ONLY);

        l_atp_Id :=
            get_AtPerson_id (p_At            => p_at_id,
                             p_App_Tp        => 'Z',
                             p_App_Tp_Only   => 1);
        l_person_os := get_AtPerson (p_At => p_at_id, p_Atp => l_atp_Id);

        addparam ('a1', NVL (l_sc_unique, '---')            /*space(3, '––')*/
                                                );                       --#102856
        addparam ('a2', NVL (GetScPIB (c.at_sc), l_person_os.pib));
        --2.0 Наявність СЖО uss_ndi.V_DDN_EXIST_SGN
        addparam ('a3-1', chk_val2 ('EX', Get_Ftr (p_at_id, p_nda => 2040)));
        addparam ('a3-2', chk_val2 ('NE', Get_Ftr (p_at_id, p_nda => 2040)));
        addparam (
            'a4',
            uss_esr.Api$act_Rpt.v_ddn ('uss_ndi.V_DDN_SS_CAUSES_DLC',
                                       Get_Ftr_Nt (p_at_id, p_nda => 2041),
                                       '; '));

        --Наявність у дитини ознак психологічної травми uss_ndi.V_DDN_EXIST_SGN
        addparam ('a5-1', chk_val2 ('EX', Get_Ftr (p_at_id, p_nda => 2042)));
        addparam ('a5-2', chk_val2 ('NE', Get_Ftr (p_at_id, p_nda => 2042)));
        addparam ('a5-3',
                  NVL (Get_Ftr_Nt (p_at_id, p_nda => 8321), space (66)));
        --2) вплив СЖО на
        /* #100509
        select listagg(pib, ', ') within group (order by birth_dt)
          into l_str
          from table(uss_esr.Api$Act_Rpt.At_Person_for_act(p_at_id)) t
         where months_between(sysdate, t.birth_dt)/12 < 18; --ознака дитини?
        addparam('a6',      l_str);

        --2.1.1 Вплив СЖО на стан задоволення потреб дитини (дітей)   uss_ndi.V_DDN_STSFCN_SGN
        addparam('a7-1',    chk_val2('SF',  Get_Ftr(p_at_id, p_nda => 2043)));
        addparam('a7-2',    chk_val2('AVG', Get_Ftr(p_at_id, p_nda => 2043)));
        addparam('a7-3',    chk_val2('NSF', Get_Ftr(p_at_id, p_nda => 2043)));
        addparam('a8',      Get_Ftr_Nt(p_at_id, p_nda => 2044));*/

        --#100509
        l_str :=
            q'[
    with
      function ActId return number is
      begin
   --     return 862;
        return :p_at_id;
      end;

    select p.atp_ln||' '||p.atp_fn||' '||p.atp_mn AS "A6",
      --2.1.1 Вплив СЖО на стан задоволення потреб дитини (дітей)   uss_ndi.V_DDN_STSFCN_SGN
      uss_esr.Api$Act_Rpt.Get_Ftr_Chk2(p_At_Id => ActId(), p_Atp => p.atp_id, p_nda => 2043, p_Chk => 'SF')  AS "A7-1",
      uss_esr.Api$Act_Rpt.Get_Ftr_Chk2(p_At_Id => ActId(), p_Atp => p.atp_id, p_nda => 2043, p_Chk => 'AVG') AS "A7-2",
      uss_esr.Api$Act_Rpt.Get_Ftr_Chk2(p_At_Id => ActId(), p_Atp => p.atp_id, p_nda => 2043, p_Chk => 'NSF') AS "A7-3",
      uss_esr.Api$Act_Rpt.Get_Ftr_Nt(ActId(), p_nda => 2044, p_atp => p.atp_id)                              AS "A8"

     from uss_esr.v_at_section s, uss_esr.v_At_Person p
    where s.ate_at = ActId() and s.ate_nng = 932
      and p.atp_at = s.ate_at
      and p.atp_id = s.ate_atp
      and p.history_status = 'A'
    order by p.atp_birth_dt
    ]';
        l_str :=
            REGEXP_REPLACE (l_str,
                            ':p_at_id',
                            p_at_id,
                            1,
                            0,
                            'i');
        rdm$rtfl_univ.AddDataset ('ds_chld', l_str);

        --uss_ndi.V_DDN_SS_CAPABLE_1
        addparam ('a9-1', chk_val2 ('CPB', Get_Ftr (p_at_id, p_nda => 2045)));
        addparam ('a9-2', chk_val2 ('PRT', Get_Ftr (p_at_id, p_nda => 2045)));
        addparam ('a9-3', chk_val2 ('NOT', Get_Ftr (p_at_id, p_nda => 2045)));
        addparam ('a10', Get_Ftr_Nt (p_at_id, p_nda => 2046));
        --uss_ndi.V_DDN_ABILITY_SGN
        addparam ('a11-1', chk_val2 ('AB', Get_Ftr (p_at_id, p_nda => 2047)));
        addparam ('a11-2', chk_val2 ('NS', Get_Ftr (p_at_id, p_nda => 2047)));
        addparam ('a11-3', chk_val2 ('NAB', Get_Ftr (p_at_id, p_nda => 2047)));
        addparam ('a12', Get_Ftr_Nt (p_at_id, p_nda => 2048));
        --3) вплив факторів сім’ї та середовища   uss_ndi.V_DDN_PS_NG_SGN
        addparam ('a13-1', chk_val2 ('PS', Get_Ftr (p_at_id, p_nda => 2049)));
        addparam ('a13-2', chk_val2 ('NU', Get_Ftr (p_at_id, p_nda => 2049)));
        addparam ('a13-3', chk_val2 ('NG', Get_Ftr (p_at_id, p_nda => 2049)));
        addparam ('a14', Get_Ftr_Nt (p_at_id, p_nda => 2050));
        --4) тривалість існування проблем uss_ndi.V_DDN_DURAT_SGN
        addparam ('a15-1', chk_val2 ('SVY', Get_Ftr (p_at_id, p_nda => 2051)));
        addparam ('a15-2', chk_val2 ('MY', Get_Ftr (p_at_id, p_nda => 2051)));
        addparam ('a15-3', chk_val2 ('U2Y', Get_Ftr (p_at_id, p_nda => 2051)));
        addparam ('a15-4', chk_val2 ('U2M', Get_Ftr (p_at_id, p_nda => 2051)));
        addparam ('a15-5', chk_val2 ('U2D', Get_Ftr (p_at_id, p_nda => 2051)));
        addparam ('aa16', Get_Ftr_Nt (p_at_id, p_nda => 3695));

        --5) усвідомлення наявності проблем та готовність до співпраці з надавачами послуг uss_ndi.V_DDN_SS_TFN2
        addparam ('a16-1', Get_Ftr_Chk2 (p_at_id, p_nda => 2052));
        addparam ('a16-2', Get_Ftr_Chk2 (p_at_id, p_nda => 2052, p_chk => 'F'));
        addparam ('a17-1', Get_Ftr_Chk2 (p_at_id, p_nda => 2053));
        addparam ('a17-2', Get_Ftr_Chk2 (p_at_id, p_nda => 2053, p_chk => 'F'));
        addparam ('a18', Get_Ftr_Nt (p_at_id, p_nda => 2054));

        addparam ('a19-1', Get_Ftr_Chk2 (p_at_id, p_nda => 2055));
        addparam ('a19-2', Get_Ftr_Chk2 (p_at_id, p_nda => 2055, p_chk => 'F'));
        addparam ('a20-1', Get_Ftr_Chk2 (p_at_id, p_nda => 2056));
        addparam ('a20-2', Get_Ftr_Chk2 (p_at_id, p_nda => 2056, p_chk => 'F'));
        addparam ('a21', Get_Ftr_Nt (p_at_id, p_nda => 2057));

        addparam ('a22-1', Get_Ftr_Chk2 (p_at_id, p_nda => 2058));
        addparam ('a22-2', Get_Ftr_Chk2 (p_at_id, p_nda => 2058, p_chk => 'F'));
        addparam ('a23-1', Get_Ftr_Chk2 (p_at_id, p_nda => 2059));
        addparam ('a23-2', Get_Ftr_Chk2 (p_at_id, p_nda => 2059, p_chk => 'F'));
        addparam ('a24', Get_Ftr_Nt (p_at_id, p_nda => 2060));

        --Сім’я/особа потребує надання соціальних послуг select * from USS_NDI.v_NDI_SERVICE_TYPE t where t.nst_ap_tp = 'G' order by t.nst_id;
        --AddNstAtService(p_at_id);
        AddNstAtService2 (p_at_id, 'nst_all');

        --2.5.5 Завершення справи
        addparam ('a26', Get_Ftr_Chk2 (p_at_id, p_nda => 2062));
        addparam ('a27', Get_Ftr_Chk2 (p_at_id, p_nda => 2063));

        IF Get_Ftr (p_at_id, p_nda => 2063) = 'T'
        THEN                                                       --  #101392
            --addparam('a28',   coalesce(Get_Ftr_Nt(p_at_id, p_nda => 2109), Get_Nsp_Name(p_rnspm_id => Get_Ftr_Nt(p_at_id, p_nda => 5555))));
            addparam (
                'a28',
                COALESCE (
                    Get_Ftr_Nt (p_at_id, p_nda => 5555),
                    uss_rnsp.api$find.Get_Nsp_Name (
                        Get_Ftr (p_at_id, p_nda => 5555)),
                    Get_Ftr_Nt (p_at_id, p_nda => 2063)));
        END IF;

        addparam ('a29', Get_Ftr_Chk2 (p_at_id, p_nda => 2064));
        addparam ('a30', Get_Ftr_Nt (p_at_id, p_nda => 3685));

        --підписи
        BEGIN
            --3. Відмітка про ознайомлення з результатами оцінки потреб
            addparam (
                'a31',
                NVL (get_at_signers_pers (p_at_id, l_FAtp).pib,
                     '_______________________________'));
            --ознайомившись із результатами оцінки, uss_ndi.V_DDN_AGRMT_SGN
            addparam ('a32-1',
                      chk_val2 ('AG', Get_Ftr (p_at_id, l_FAtp, 2065)));
            addparam ('a32-2',
                      chk_val2 ('NAG', Get_Ftr (p_at_id, l_FAtp, 2065)));
            addparam ('a32-3',
                      chk_val2 ('SO', Get_Ftr (p_at_id, l_FAtp, 2065)));
            addparam ('a33', Get_Ftr_Chk2 (p_at_id, l_FAtp, 3704));
            addparam ('a33-1', Get_Ftr_Chk2 (p_at_id, l_FAtp, 7403)); --підписано КЕП

            addparam ('sgn_1', get_sign_mark (p_at_id, l_FAtp));
            --addparam('sgn_1',  'pts392147');

            addparam ('sgn_2', get_sign_mark (p_at_id, l_MAtp));
            --addparam('sgn_2',  'pts392149');

            addparam (
                'a31_2',
                NVL (get_at_signers_pers (p_at_id, l_MAtp).pib,
                     '_______________________________'));
            --ознайомившись із результатами оцінки, uss_ndi.V_DDN_AGRMT_SGN
            addparam ('a32_21',
                      chk_val2 ('AG', Get_Ftr (p_at_id, l_MAtp, 2065)));
            addparam ('a32_22',
                      chk_val2 ('NAG', Get_Ftr (p_at_id, l_MAtp, 2065)));
            addparam ('a32_23',
                      chk_val2 ('SO', Get_Ftr (p_at_id, l_MAtp, 2065)));
            addparam ('a33_2', Get_Ftr_Chk2 (p_at_id, l_MAtp, 3704));
            addparam ('a33_22', Get_Ftr_Chk2 (p_at_id, l_MAtp, 7403)); --підписано КЕП
            --Коментарі
            addparam (
                'a34',
                NVL (
                    mOthers (Get_Ftr_Nt (p_at_id, l_FAtp, 2067),
                             Get_Ftr_Nt (p_at_id, l_MAtp, 2067)),
                    Get_Ftr_Nt (p_at_id, p_Nda => 2067)));

            --4. Фахівець, який здійснює оцінку потреб
            addparam (
                'a35',
                   GetCuPIB (c.at_cu)
                || NVL2 (Get_Ftr_Nt (p_at_id, p_nda => 8328),
                         ', ' || Get_Ftr_Nt (p_at_id, p_nda => 8328))); --ПІБ, посада
            addparam ('a35-1', Get_Ftr_Chk2 (p_at_id, p_nda => 7415)); --підписано КЕП
            addparam ('a37', Get_Ftr_Nt (p_at_id, p_nda => 8327));   --телефон

            --Інші спеціалісти, задіяні в оцінці потреб
            l_str :=
                q'[
      select s.atop_ln||' '||s.atop_fn||' '||s.atop_mn||', '||s.atop_position spc_1,  --ПІБ, посада
             s.atop_phone spc_2 --телефон
        from uss_esr.v_at_other_spec s
       where s.atop_at = :p_at_id --and s.atop_tp = 'OC'
         and s.history_status = 'A'
         and s.atop_Tp != 'CCM'
      ]';
            l_str :=
                REGEXP_REPLACE (l_str,
                                ':p_at_id',
                                p_at_id,
                                1,
                                0,
                                'i');
            rdm$rtfl_univ.AddDataset ('ds_spc', l_str);
        END;

        addparam ('a41', Date2Str (c.at_action_stop_dt));

        --5. Відмітки про затвердження висновку керівником
        addparam ('a42-1', chk_val2 (1, 1));
        addparam ('a42-2', chk_val2 (1, 2));
        --Uss_Ndi.v_Ddn_Case_Class
        addparam ('a43-1', chk_val2 ('SM', c.at_case_class));
        addparam ('a43-2', chk_val2 ('MD', c.at_case_class));
        addparam ('a43-3', chk_val2 ('DF', c.at_case_class));
        addparam ('a43-4', chk_val2 ('EM', c.at_case_class));

        --Керівник
        OPEN c_sgn ('PR');

        FETCH c_sgn INTO r_sgn;

        CLOSE c_sgn;

        addparam (
            'a44',
               Get_Ftr_Nt_Lst (p_at_id, p_nda => '8288,8287,8286')
            ||                                                     --r_sgn.pib
               --посада
               NVL2 (Get_Ftr_Nt (p_at_id, p_nda => 8285),
                     ', ' || Get_Ftr_Nt (p_at_id, p_nda => 8285)));
        addparam ('a44-1', Get_Ftr_Chk2 (p_at_id, p_nda => 7416)); --підписано КЕП
        addparam ('a46', Get_Ftr_Nt (p_At_Id => p_at_id, p_Nda => 8457) /*to_char(r_sgn.ati_sign_dt, 'dd.mm.yyyy')*/
                                                                       ); --#101392

        rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                         p_rpt_blob   => l_result);

        replace_ekr (l_result);

        RETURN l_result;
    END BUILD_ACT_NEEDS_ASSESSMENT;

    PROCEDURE p3_act_needs_assessment_s2 (p_at_id IN NUMBER)
    IS
    BEGIN
        rdm$rtfl_univ.AddDataset (
            'ds_p3',
               q'[
  SELECT pib_1 as fd125,
         pib_2 as fd125_1,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 3269) as fd126,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 3269) as fd126_2,
         (select ListAgg(case when s.ate_atp = l_FAtp then uss_esr.api$act_rpt.UnderLine_ds(pib_1, 1)
                              when s.ate_atp = l_MAtp then uss_esr.api$act_rpt.UnderLine_ds(pib_2, 1)
                          end || ': ' || s.ate_notes, ']'
            || org2ekr (c_chr10)
            || q'[') within group (order by 1)
            from uss_esr.at_section s
           where s.ate_at = p_at_id
             and s.ate_nng = 128
             and s.ate_atp in (l_FAtp, l_MAtp)
             and s.ate_notes is not null
         ) as fd126_1,
         uss_esr.api$act_rpt.UnderLine_ds(uss_esr.api$act_rpt.Get_Ndi_Doc_Atr_Name(p_Nda => 3270), --з порушенням опорно-рухового апарату та центральної і периферичної нервової системи,',
                      case when uss_esr.api$act_rpt.Get_Ftr(p_at_id, l_FAtp, 3270) = 'T' or uss_esr.api$act_rpt.Get_Ftr(p_at_id, l_MAtp, 3270) = 'T' then 1 else 0 end)||']'
            || org2ekr (c_chr10)
            || q'['||
            uss_esr.api$act_rpt.UnderLine_ds(uss_esr.api$act_rpt.Get_Ndi_Doc_Atr_Name(p_Nda => 3271), --'органів слуху,',
                      case when uss_esr.api$act_rpt.Get_Ftr(p_at_id, l_FAtp, 3271) = 'T' or uss_esr.api$act_rpt.Get_Ftr(p_at_id, l_MAtp, 3271) = 'T' then 1 else 0 end)||']'
            || org2ekr (c_chr10)
            || q'['||
            uss_esr.api$act_rpt.UnderLine_ds(uss_esr.api$act_rpt.Get_Ndi_Doc_Atr_Name(p_Nda => 3272), --'органів зору,',
                      case when uss_esr.api$act_rpt.Get_Ftr(p_at_id, l_FAtp, 3272) = 'T' or uss_esr.api$act_rpt.Get_Ftr(p_at_id, l_MAtp, 3272) = 'T' then 1 else 0 end)||']'
            || org2ekr (c_chr10)
            || q'['||
            uss_esr.api$act_rpt.UnderLine_ds(uss_esr.api$act_rpt.Get_Ndi_Doc_Atr_Name(p_Nda => 3273), --'внутрішніх органів,',
                      case when uss_esr.api$act_rpt.Get_Ftr(p_at_id, l_FAtp, 3273) = 'T' or uss_esr.api$act_rpt.Get_Ftr(p_at_id, l_MAtp, 3273) = 'T' then 1 else 0 end)||']'
            || org2ekr (c_chr10)
            || q'['||
            uss_esr.api$act_rpt.UnderLine_ds(uss_esr.api$act_rpt.Get_Ndi_Doc_Atr_Name(p_Nda => 3274), --'з психічними захворюваннями та розумовою відсталістю,',
                      case when uss_esr.api$act_rpt.Get_Ftr(p_at_id, l_FAtp, 3274) = 'T' or uss_esr.api$act_rpt.Get_Ftr(p_at_id, l_MAtp, 3274) = 'T' then 1 else 0 end)||']'
            || org2ekr (c_chr10)
            || q'['||
            uss_esr.api$act_rpt.UnderLine_ds(uss_esr.api$act_rpt.Get_Ndi_Doc_Atr_Name(p_Nda => 3275), --'з онкологічними захворюваннями',
                      case when uss_esr.api$act_rpt.Get_Ftr(p_at_id, l_FAtp, 3275) = 'T' or uss_esr.api$act_rpt.Get_Ftr(p_at_id, l_MAtp, 3275) = 'T' then 1 else 0 end)
         as fd127,
         case when
             nvl(uss_esr.api$act_rpt.Get_Ftr(p_at_id, l_FAtp, 3270)|| uss_esr.api$act_rpt.Get_Ftr(p_at_id, l_FAtp, 3271)||
                       uss_esr.api$act_rpt.Get_Ftr(p_at_id, l_FAtp, 3272)|| uss_esr.api$act_rpt.Get_Ftr(p_at_id, l_FAtp, 3273)||
                       uss_esr.api$act_rpt.Get_Ftr(p_at_id, l_FAtp, 3274)|| uss_esr.api$act_rpt.Get_Ftr(p_at_id, l_FAtp, 3275), 'F') like '%T%'
           then ']'
            || org2ekr (c_chk)
            || q'['
           else ']'
            || org2ekr (c_unchk_ds)
            || q'['
         end as fd133,
         case when
             nvl(uss_esr.api$act_rpt.Get_Ftr(p_at_id, l_MAtp, 3270)|| uss_esr.api$act_rpt.Get_Ftr(p_at_id, l_MAtp, 3271)||
                       uss_esr.api$act_rpt.Get_Ftr(p_at_id, l_MAtp, 3272)|| uss_esr.api$act_rpt.Get_Ftr(p_at_id, l_MAtp, 3273)||
                       uss_esr.api$act_rpt.Get_Ftr(p_at_id, l_MAtp, 3274)|| uss_esr.api$act_rpt.Get_Ftr(p_at_id, l_MAtp, 3275), 'F') like '%T%'
           then ']'
            || org2ekr (c_chk)
            || q'['
           else ']'
            || org2ekr (c_unchk_ds)
            || q'['
         end as fd133_2,

         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 3276) as fd134,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 3276) as fd134_2,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 3277) as fd135,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 3277) as fd135_2,

         uss_esr.api$act_rpt.mOthers_ds(pib_1, uss_esr.api$act_rpt.Get_Ftr_Nt(p_at_id, l_FAtp, 3277),
                      pib_2, uss_esr.api$act_rpt.Get_Ftr_Nt(p_at_id, l_MAtp, 3277)) as fd136,

         --Висновок щодо стану здоров’я
         --довідник: задовільний[STS]; незадовільний[N]; невідомо[F] select * from uss_ndi.v_ddn_ss_sts t
         uss_esr.api$act_rpt.chk_val2('STS', uss_esr.api$act_rpt.Get_Ftr(p_at_id, l_FAtp, 3289)) as fd137_1,
         uss_esr.api$act_rpt.chk_val2('N',   uss_esr.api$act_rpt.Get_Ftr(p_at_id, l_FAtp, 3289)) as fd137_2,
         uss_esr.api$act_rpt.chk_val2('F',   uss_esr.api$act_rpt.Get_Ftr(p_at_id, l_FAtp, 3289)) as fd137_3,
         uss_esr.api$act_rpt.chk_val2('STS', uss_esr.api$act_rpt.Get_Ftr(p_at_id, l_MAtp, 3289)) as fd137_21,
         uss_esr.api$act_rpt.chk_val2('N',   uss_esr.api$act_rpt.Get_Ftr(p_at_id, l_MAtp, 3289)) as fd137_22,
         uss_esr.api$act_rpt.chk_val2('F',   uss_esr.api$act_rpt.Get_Ftr(p_at_id, l_MAtp, 3289)) as fd137_23,

         --2) емоційний стан
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 3290) as fd139,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 3290) as fd139_2,
         --Коментарі
         uss_esr.api$act_rpt.mOthers_ds(pib_1, uss_esr.api$act_rpt.Get_Ftr_Nt(p_at_id, l_FAtp, 3290),
                      pib_2, uss_esr.api$act_rpt.Get_Ftr_Nt(p_at_id, l_MAtp, 3290)) as fd139_1,

         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 3291) as fd140,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 3291) as fd140_2,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 3292) as fd141,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 3292) as fd141_2,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 3293) as fd142,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 3293) as fd142_2,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 3294) as fd143,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 3294) as fd143_2,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 3295) as fd144,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 3295) as fd144_2,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 3296) as fd145,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 3296) as fd145_2,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 3297) as fd146,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 3297) as fd146_2,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 3298) as fd147,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 3298) as fd147_2,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 3299) as fd148,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 3299) as fd148_2,

         --інше
         uss_esr.api$act_rpt.mOthers_ds(pib_1, uss_esr.api$act_rpt.Get_Ftr_Nt(p_at_id, l_FAtp, 3299),
                 pib_2, uss_esr.api$act_rpt.Get_Ftr_Nt(p_at_id, l_MAtp, 3299)) as fd149,
         --Висновок щодо емоційного стану  uss_ndi.V_DDN_SS_STS
         uss_esr.api$act_rpt.chk_val2('STS', uss_esr.api$act_rpt.Get_Ftr(p_at_id, l_FAtp, 3302)) as fd150_1,
         uss_esr.api$act_rpt.chk_val2('N',   uss_esr.api$act_rpt.Get_Ftr(p_at_id, l_FAtp, 3302)) as fd150_2,
         uss_esr.api$act_rpt.chk_val2('F',   uss_esr.api$act_rpt.Get_Ftr(p_at_id, l_FAtp, 3302)) as fd150_3,
         uss_esr.api$act_rpt.chk_val2('STS', uss_esr.api$act_rpt.Get_Ftr(p_at_id, l_MAtp, 3302)) as fd150_21,
         uss_esr.api$act_rpt.chk_val2('N',   uss_esr.api$act_rpt.Get_Ftr(p_at_id, l_MAtp, 3302)) as fd150_22,
         uss_esr.api$act_rpt.chk_val2('F',   uss_esr.api$act_rpt.Get_Ftr(p_at_id, l_MAtp, 3302)) as fd150_23,
         --Коментарі
         (select ListAgg(case when s.ate_atp = l_FAtp then uss_esr.api$act_rpt.UnderLine_ds(pib_1, 1)
                              when s.ate_atp = l_MAtp then uss_esr.api$act_rpt.UnderLine_ds(pib_2, 1)
                          end || ': ' || s.ate_notes, ']'
            || org2ekr (c_chr10)
            || q'[') within group (order by 1)
            from uss_esr.at_section s
           where s.ate_at = p_at_id
             and s.ate_atp in (l_FAtp, l_MAtp)
             and s.ate_nng = 129
             and s.ate_notes is not null
         ) as fd151,

         --3) шкідливі звички
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 3303) as fd152,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 3303) as fd152_2,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 3304) as fd153,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 3304) as fd153_2,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 3305) as fd154,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 3305) as fd154_2,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 3306) as fd155,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 3306) as fd155_2,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 3307) as fd156,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 3307) as fd156_2,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 3308) as fd157,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 3308) as fd157_2,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 3309) as fd158,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 3309) as fd158_2,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 3310) as fd159,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 3310) as fd159_2,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 3311) as fd160,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 3311) as fd160_2,
         --інше
         uss_esr.api$act_rpt.mOthers_ds(pib_1,uss_esr.api$act_rpt.Get_Ftr_Nt(p_at_id, l_FAtp, 3311),
                        pib_2, uss_esr.api$act_rpt.Get_Ftr_Nt(p_at_id, l_MAtp, 3311)) as fd161,
         --Висновок щодо наявності ознак девіантної поведінки uss_ndi.V_DDN_EXIST_SGN1
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, p_Nda => 3315, p_Chk => 'NE') as fd162_1,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, p_Nda => 3315, p_Chk => 'EX') as fd162_2,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, p_Nda => 3315, p_Chk => 'UN') as fd162_3,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, p_Nda => 3315, p_Chk => 'NE') as fd162_21,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, p_Nda => 3315, p_Chk => 'EX') as fd162_22,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, p_Nda => 3315, p_Chk => 'UN') as fd162_23,
         --Коментарі
         (select ListAgg(case when s.ate_atp = l_FAtp then uss_esr.api$act_rpt.UnderLine_ds(pib_1, 1)
                              when s.ate_atp = l_MAtp then uss_esr.api$act_rpt.UnderLine_ds(pib_2, 1)
                          end || ': ' || s.ate_notes, ']'
            || org2ekr (c_chr10)
            || q'[') within group (order by 1)
            from uss_esr.at_section s
           where s.ate_at = p_at_id
             and s.ate_nng = 130
             and s.ate_atp in (l_FAtp, l_MAtp)
             and s.ate_notes is not null
         ) as fd163,

         --4) соціальні контакти
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 3316) as fd164,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 3316) as fd164_2,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 3317) as fd165,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 3317) as fd165_2,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 3318) as fd166_2,
         --Коментарі
         (select ListAgg(case when s.ate_atp = l_FAtp then uss_esr.api$act_rpt.UnderLine_ds(pib_1, 1)
                              when s.ate_atp = l_MAtp then uss_esr.api$act_rpt.UnderLine_ds(pib_2, 1)
                          end || ': ' || s.ate_notes, ']'
            || org2ekr (c_chr10)
            || q'[') within group (order by 1)
            from uss_esr.at_section s
           where s.ate_at = p_at_id
             and s.ate_nng = 131
             and s.ate_atp in (l_FAtp, l_MAtp)
             and s.ate_notes is not null
         ) as fd166,

         --5) соціальна історія
         --був(була)
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 3319) as fd167,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 3319) as fd167_2,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 3320) as fd168,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 3320) as fd168_2,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 3321) as fd169,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 3321) as fd169_2,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 3322) as fd170,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 3322) as fd170_2,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 3323) as fd171,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 3323) as fd171_2,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 3324) as fd172,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 3324) as fd172_2,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 3325) as fd173,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 3325) as fd173_2,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 3326) as fd174,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 3326) as fd174_2,
         --є
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 7401) as fd167d,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 7401) as fd167d_2,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 7402) as fd168d,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 7402) as fd168d_2,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 7404) as fd169d,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 7404) as fd169d_2,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 7405) as fd170d,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 7405) as fd170d_2,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 7406) as fd171d,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 7406) as fd171d_2,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 7407) as fd172d,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 7407) as fd172d_2,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 7408) as fd173d,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 7408) as fd173d_2,
         --Перебуває під слідством.
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 3327) as fd175,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 3327) as fd175_2,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 3328) as fd176, --інше
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 3328) as fd176_2,
         --інше (коментар)
         uss_esr.api$act_rpt.mOthers_ds(pib_1, uss_esr.api$act_rpt.Get_Ftr_Nt(p_at_id, l_FAtp, 3328),
                    pib_2, uss_esr.api$act_rpt.Get_Ftr_Nt(p_at_id, l_MAtp, 3328)) as fd177,

         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 3330) as fd178,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 3330) as fd178_2,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 3331) as fd179,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 3331) as fd179_2,
         --Висновок щодо впливу соціальної історії uss_ndi.V_DDN_SS_PST
         uss_esr.api$act_rpt.chk_val2('PST', uss_esr.api$act_rpt.Get_Ftr(p_at_id, l_FAtp, 3333)) as fd180_1,
         uss_esr.api$act_rpt.chk_val2('N',   uss_esr.api$act_rpt.Get_Ftr(p_at_id, l_FAtp, 3333)) as fd180_2,
         uss_esr.api$act_rpt.chk_val2('F',   uss_esr.api$act_rpt.Get_Ftr(p_at_id, l_FAtp, 3333)) as fd180_3,
         uss_esr.api$act_rpt.chk_val2('PST', uss_esr.api$act_rpt.Get_Ftr(p_at_id, l_MAtp, 3333)) as fd180_21,
         uss_esr.api$act_rpt.chk_val2('N',   uss_esr.api$act_rpt.Get_Ftr(p_at_id, l_MAtp, 3333)) as fd180_22,
         uss_esr.api$act_rpt.chk_val2('F',   uss_esr.api$act_rpt.Get_Ftr(p_at_id, l_MAtp, 3333)) as fd180_23,
         --Коментарі
         (select ListAgg(case when s.ate_atp = l_FAtp then uss_esr.api$act_rpt.UnderLine_ds(pib_1, 1)
                              when s.ate_atp = l_MAtp then uss_esr.api$act_rpt.UnderLine_ds(pib_2, 1)
                          end || ': ' || s.ate_notes, ']'
            || org2ekr (c_chr10)
            || q'[') within group (order by 1)
            from uss_esr.at_section s
           where s.ate_at = p_at_id
             and s.ate_nng = 132
             and s.ate_atp in (l_FAtp, l_MAtp)
             and s.ate_notes is not null
         ) as fd181,

         --6) зайнятість
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 3334) as fd182,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 3334) as fd182_2,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 3335) as fd183,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 3335) as fd183_2,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 3336) as fd184,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 3336) as fd184_2,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 3337) as fd185,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 3337) as fd185_2,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 3338) as fd186,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 3338) as fd186_2,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 3339) as fd187,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 3339) as fd187_2,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 3340) as fd188,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 3340) as fd188_2,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 3341) as fd189,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 3341) as fd189_2,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 3342) as fd190,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 3342) as fd190_2,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 3343) as fd191,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 3343) as fd191_2,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 3344) as fd192,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 3344) as fd192_2,
         --інше
         uss_esr.api$act_rpt.mOthers_ds(pib_1, uss_esr.api$act_rpt.Get_Ftr_Nt(p_at_id, l_FAtp, 3344),
                     pib_2, uss_esr.api$act_rpt.Get_Ftr_Nt(p_at_id, l_MAtp, 3344)) as fd193,
         --Висновок щодо впливу зайнятості  uss_ndi.V_DDN_SS_PST
         uss_esr.api$act_rpt.chk_val2('PST', uss_esr.api$act_rpt.Get_Ftr(p_at_id, l_FAtp, 3348)) as fd194_1,
         uss_esr.api$act_rpt.chk_val2('N',   uss_esr.api$act_rpt.Get_Ftr(p_at_id, l_FAtp, 3348)) as fd194_2,
         uss_esr.api$act_rpt.chk_val2('F',   uss_esr.api$act_rpt.Get_Ftr(p_at_id, l_FAtp, 3348)) as fd194_3,
         uss_esr.api$act_rpt.chk_val2('PST', uss_esr.api$act_rpt.Get_Ftr(p_at_id, l_MAtp, 3348)) as fd194_21,
         uss_esr.api$act_rpt.chk_val2('N',   uss_esr.api$act_rpt.Get_Ftr(p_at_id, l_MAtp, 3348)) as fd194_22,
         uss_esr.api$act_rpt.chk_val2('F',   uss_esr.api$act_rpt.Get_Ftr(p_at_id, l_MAtp, 3348)) as fd194_23,
         --Коментарі
         (select ListAgg(case when s.ate_atp = l_FAtp then uss_esr.api$act_rpt.UnderLine_ds(pib_1, 1)
                              when s.ate_atp = l_MAtp then uss_esr.api$act_rpt.UnderLine_ds(pib_2, 1)
                          end || ': ' || s.ate_notes, ']'
            || org2ekr (c_chr10)
            || q'[') within group (order by 1)
            from uss_esr.at_section s
           where s.ate_at = p_at_id
             and s.ate_nng = 133
             and s.ate_atp in (l_FAtp, l_MAtp)
             and s.ate_notes is not null
         ) as fd195,
         --інше
         uss_esr.api$act_rpt.mOthers_ds(pib_1, uss_esr.api$act_rpt.Get_Ftr_Nt(p_at_id, l_FAtp, 3347),
                     pib_2, uss_esr.api$act_rpt.Get_Ftr_Nt(p_at_id, l_MAtp, 3347)) as fd196,

         --7) самообслуговування
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 3349) as fd197,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 3349) as fd197_2,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 3350) as fd198,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 3350) as fd198_2,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 3351) as fd199,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 3351) as fd199_2,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 3352) as fd200,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 3352) as fd200_2,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 3353) as fd201,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 3353) as fd201_2,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 3354) as fd202,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 3354) as fd202_2,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 3355) as fd203,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 3355) as fd203_2,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 3356) as fd204,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 3356) as fd204_2,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 3357) as fd205,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 3357) as fd205_2,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 3358) as fd206,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 3358) as fd206_2,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 3359) as fd207,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 3359) as fd207_2,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_FAtp, 3360) as fd208,
         uss_esr.api$act_rpt.Get_Ftr_Chk2(p_at_id, l_MAtp, 3360) as fd208_2,
         --Коментарі
         (select ListAgg(case when s.ate_atp = l_FAtp then uss_esr.api$act_rpt.UnderLine_ds(pib_1, 1)
                              when s.ate_atp = l_MAtp then uss_esr.api$act_rpt.UnderLine_ds(pib_2, 1)
                          end || ': ' || s.ate_notes, ']'
            || org2ekr (c_chr10)
            || q'[') within group (order by 1)
            from uss_esr.at_section s
           where s.ate_at = p_at_id
             and s.ate_nng = 134
             and s.ate_atp in (l_FAtp, l_MAtp)
             and s.ate_notes is not null
         ) as fd210,
         --Висновок щодо здатності до самообслуговування  uss_ndi.V_DDN_SS_CAPABLE
         uss_esr.api$act_rpt.chk_val2('CPB', uss_esr.api$act_rpt.Get_Ftr(p_at_id, l_FAtp, 3362)) as fd209_1,
         uss_esr.api$act_rpt.chk_val2('PRT', uss_esr.api$act_rpt.Get_Ftr(p_at_id, l_FAtp, 3362)) as fd209_2,
         uss_esr.api$act_rpt.chk_val2('NOT', uss_esr.api$act_rpt.Get_Ftr(p_at_id, l_FAtp, 3362)) as fd209_3,
         uss_esr.api$act_rpt.chk_val2('CPB', uss_esr.api$act_rpt.Get_Ftr(p_at_id, l_MAtp, 3362)) as fd209_21,
         uss_esr.api$act_rpt.chk_val2('PRT', uss_esr.api$act_rpt.Get_Ftr(p_at_id, l_MAtp, 3362)) as fd209_22,
         uss_esr.api$act_rpt.chk_val2('NOT', uss_esr.api$act_rpt.Get_Ftr(p_at_id, l_MAtp, 3362)) as fd209_23
    FROM (
          select first_value(t.atp_id) over (partition by page) as l_Fatp,
                 case when first_value(t.atp_id) over (partition by page)
                   = last_value(t.atp_id) over (partition by page)
                   then null else last_value(t.atp_id) over (partition by page) end as l_Matp,
                 rn,
                 p_at_id,
                 first_value(pib) over (partition by page) as pib_1,
                 case when first_value(pib) over (partition by page)
                   = last_value(pib) over (partition by page)
                   then null else last_value(pib) over (partition by page) end as pib_2
             from (
             SELECT t.*,
                    round(t.atp_num/2) as page,
                    t.atp_num as rn,
                    atp_at as p_at_id,
                    atp_ln||' '||atp_fn||' '||atp_mn as pib
               FROM at_person t
              where t.atp_at = ]'
            || p_at_id
            || '
                and t.history_status = ''A''
              order by t.atp_num
             ) t
         )
  where mod(rn, 2) = 1');
    END;

    --#90632  ndt=804 «Акт оцінки потреб сім’ї/особи» (з висновком оцінки потреб особи) APOP
    FUNCTION BUILD_ACT_NEEDS_ASSESSMENT_S2 (p_at_id IN NUMBER)
        RETURN BLOB
    IS
        --select t.*, rowid from uss_esr.rpt_templates t where t.rt_code = 'ACT_NEEDS_ASSESSMENT';
        l_jbr_id      NUMBER;
        l_result      BLOB;

        CURSOR c_at IS
            SELECT a.at_ap,
                   a.at_pc,
                   a.at_org,
                   a.at_dt,
                   a.at_action_start_dt,
                   a.at_action_stop_dt,
                   a.at_family_info,
                   a.at_live_address,
                   a.at_case_class,
                   a.at_cu,
                   a.at_rnspm,
                   a.at_redirect_rnspm,
                   a.at_sc,
                   sc.sc_unique,
                   p.atp_id,
                   pc.pc_sc,
                   p.Atp_App_Tp,
                   a.at_main_link,
                   (SELECT COUNT (*)
                      FROM at_person z
                     WHERE z.atp_at = at_id AND z.history_status = 'A')    AS atp_cnt
              /*from uss_esr.act a, uss_esr.personalcase pc, uss_esr.At_Person p, uss_person.v_socialcard sc
             where a.at_id = p_at_id and pc.pc_id(+) = a.at_pc
               and p.atp_at = a.at_id and p.atp_sc = pc.pc_sc(+)
               and sc.sc_id(+) = a.at_sc;*/
              FROM uss_esr.act  a
                   LEFT JOIN uss_esr.personalcase pc ON (pc.pc_id = a.at_pc)
                   LEFT JOIN uss_esr.At_Person p
                       ON (p.atp_at = a.at_id AND p.atp_sc = pc.pc_sc)
                   LEFT JOIN uss_person.v_socialcard sc
                       ON (sc.sc_id = a.at_sc)
             WHERE a.at_id = p_at_id;

        c             c_at%ROWTYPE;

        --підписанти
        CURSOR c_sgn (p_tp VARCHAR2)
        IS
            SELECT --Nvl(GetCuPIB(s.ati_Cu), Tools.Getuserpib(s.ati_wu))  pib,
                   s.*
              FROM uss_esr.at_signers s
             WHERE     s.ati_at = p_at_id
                   AND s.ati_tp = p_tp
                   AND s.history_status = 'A'
                   AND s.ati_is_signed = 'T';

        r_sgn         c_sgn%ROWTYPE;

        l_FAtp        NUMBER;                                        --особа 1
        l_MAtp        NUMBER;                                        --особа 2

        l_atp_Id      NUMBER;
        l_person_os   r_Person_for_Act;

        l_str         VARCHAR2 (32000);
        l_str2        VARCHAR2 (4000);
        l_sc_unique   VARCHAR2 (50);
        l_cnt         NUMBER;
    BEGIN
        OPEN c_at;

        FETCH c_at INTO c;

        CLOSE c_at;

        --шукаємо по секції з заповненими даними двох осіб
        SELECT MIN (s.ate_atp) /*,
                 case when max(s.ate_atp) <> min(s.ate_atp) then min(s.ate_atp) end*/
          INTO l_FAtp                                               --, l_MAtp
          FROM uss_esr.at_section  s
               JOIN at_signers s ON (s.ate_atp = s.ate_atp)
         WHERE s.ate_at = p_at_id AND s.ate_nng = 128;

        rdm$rtfl_univ.initreport (p_code     => 'ACT_NEEDS_ASSESSMENT_R2',
                                  p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);


        p3_act_needs_assessment_s2 (p_at_id);
        --загальна частина акту
        bld_act_needs_assessment (p_at_id => p_at_id);

        --4. Фактори сім’ї та середовища
        --6) помешкання та його стан uss_ndi.V_DDN_SS_STS
        addparam ('F265-1',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 8272, p_Chk => 'STS'));
        addparam ('F265-2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 8272, p_Chk => 'N'));
        addparam ('F265-3',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 8272, p_Chk => 'F'));
        addparam ('F266', Get_Ftr_Chk2 (p_at_id, p_nda => 8273));
        addparam ('F267', Get_Ftr_Chk2 (p_at_id, p_nda => 8274));
        addparam ('F268', Get_Ftr_Chk2 (p_at_id, p_nda => 8275));
        addparam ('F269', Get_Ftr_Chk2 (p_at_id, p_nda => 8276));
        --addparam('F269-1',  Get_Ftr_Chk2(p_at_id, p_nda => 8280));
        addparam ('F270', Get_Ftr_Chk2 (p_at_id, p_nda => 8277));
        --addparam('F270-1',  Get_Ftr_Chk2(p_at_id, p_nda => 8282));
        --addparam('F270-2',  Get_Ftr_Chk2(p_at_id, p_nda => 8281));
        addparam ('F271', Get_Ftr_Chk2 (p_at_id, p_nda => 8278));
        addparam ('F272', Get_Ftr_Chk2 (p_at_id, p_nda => 8279));
        addparam ('F281', Get_Ftr_Chk2 (p_at_id, p_nda => 8283));
        addparam ('F281-1', Get_Ftr_Nt (p_at_id, p_nda => 8283));
        addparam ('F282', get_AtSctNt (p_at_id, p_nng => 928));    --Коментарі

        ----------------------------------------------------
        ----------------------------------------------------
        -- ВИСНОВОК
        ----------------------------------------------------
        ----------------------------------------------------
        /*SELECT MAX(s.nsj_num)
          INTO l_sc_unique
          FROM uss_esr.act a
          JOIN uss_esr.act t ON (a.at_tp = 'APOP' AND t.at_id = a.at_main_link AND t.at_tp = 'AVOP'
                           OR a.at_tp = 'AVOP' AND t.at_id = a.at_id)
          JOIN uss_esr.at_person pp ON (pp.atp_at = t.at_id AND pp.atp_app_tp = 'OS')
          JOIN uss_esr.nsp_sc_journal s ON (s.nsj_rnspm = t.at_rnspm AND s.nsj_sc = pp.atp_sc)
         WHERE a.at_id = p_at_id
           AND t.at_st NOT IN ('VR', 'VD', 'VA')
           AND (t.at_conclusion_tp = 'V2' OR t.at_conclusion_tp = 'V1' AND pp.atp_relation_tp = 'Z')
         ;*/
        /*  SELECT MAX(s.nsj_num)
            INTO l_sc_unique
            FROM uss_esr.act a
            JOIN uss_esr.act t ON (t.at_id = a.at_main_link)
            JOIN uss_esr.at_person pp ON (pp.atp_at = t.at_id AND pp.atp_app_tp IN ('OS', 'Z'))
            JOIN uss_esr.nsp_sc_journal s ON (s.nsj_rnspm = t.at_rnspm AND s.nsj_sc = pp.atp_sc)
           WHERE a.at_id = p_at_id
             AND t.at_st NOT IN ('VR', 'VD', 'VA', 'AD', 'AR')
           ;*/

        SELECT MAX (m)
          INTO l_sc_unique
          FROM (SELECT FIRST_VALUE (s.nsj_num)
                           OVER (
                               ORDER BY
                                   DECODE (pp.atp_app_tp,
                                           'Z', 1,
                                           'OS', 2,
                                           'FMS', 3,
                                           4))    AS m
                  FROM uss_esr.act  a
                       JOIN uss_esr.at_person pp
                           ON (    pp.atp_at = a.at_id
                               AND pp.atp_app_tp IN ('Z', 'OS', 'FMS'))
                       JOIN uss_esr.nsp_sc_journal s
                           ON (    s.nsj_rnspm = a.at_rnspm
                               AND s.nsj_sc = pp.atp_sc)
                 WHERE a.at_id = p_at_id
                 FETCH FIRST ROW ONLY);

        l_atp_Id :=
            NVL (
                get_AtPerson_id (p_At            => p_at_id,
                                 p_App_Tp        => 'Z',
                                 p_App_Tp_Only   => 1),
                NVL (
                    get_AtPerson_id (p_At            => p_at_id,
                                     p_App_Tp        => 'OR',
                                     p_App_Tp_Only   => 1),
                    get_AtPerson_id (p_At            => p_at_id,
                                     p_App_Tp        => 'OS',
                                     p_App_Tp_Only   => 1)));

        l_person_os := get_AtPerson (p_At => p_at_id, p_Atp => l_atp_Id);

        addparam ('s1', NVL (l_sc_unique,                     /*c.sc_unique,*/
                                          '---'));        --Соціальна картка №
        addparam ('s2', UnderLine (                /*nvl(GetScPIB(c.at_sc), */
                                   l_person_os.Pib                       /*)*/
                                                  , 2));

        --1. Загальна інформація про особу
        /*if (c.at_main_link is null) then
          l_str:= q'[
             select
                   row_number() over(order by birth_dt) as "F09",
                   pib          as F9,
                   birth_dt_str as F10,
                   Relation_Tp  as F11,
                   case when is_disabled = 'T' then 'наявна' else 'відсутня' end F12,
                   case when is_capable  = 'T' then 'дієздатний(а)'
                        when is_capable  = 'F' then 'недієздатний(а)'
                   end        as F13_old,
                   case when trunc(months_between(sysdate, t.birth_dt)/12) > 18 and
                             is_capable = 'T' then uss_esr.Api$Act_Rpt.Chk_Val2(1,1)
                        else uss_esr.Api$Act_Rpt.Chk_Val2(1,2)
                   end as F13,
                   work_place as F14,
                   case when is_adr_matching = 'T' then 'Так' end as F15,
                   case when is_adr_matching = 'F' then 'Ні'  end as F16,
                   phone        as F17,
                   Fact_Address as F18
             from table(uss_esr.Api$Act_Rpt.At_Person_for_act(:p_at_id)) t
             where Atp_App_Tp = ]' || case when c.atp_cnt > 1 then '''OS''' else '''Z''' end || '
           ';
          l_str:= regexp_replace(l_str, ':p_at_id', p_at_id, 1, 0, 'i');
        else
          l_str:= q'[
             select
                   row_number() over(order by birth_dt) as "F09",
                   pib          as F9,
                   birth_dt_str as F10,
                   Relation_Tp  as F11,
                   case when is_disabled = 'T' then 'наявна' else 'відсутня' end F12,
                   case when is_capable  = 'T' then 'дієздатний(а)'
                        when is_capable  = 'F' then 'недієздатний(а)'
                   end        as F13_old,
                   case when trunc(months_between(sysdate, t.birth_dt)/12) > 18 and
                             is_capable = 'T' then uss_esr.Api$Act_Rpt.Chk_Val2(1,1)
                        else uss_esr.Api$Act_Rpt.Chk_Val2(1,2)
                   end as F13,
                   work_place as F14,
                   case when is_adr_matching = 'T' then 'Так' end as F15,
                   case when is_adr_matching = 'F' then 'Ні'  end as F16,
                   phone        as F17,
                   Fact_Address as F18
             from table(uss_esr.Api$Act_Rpt.At_Person_for_act(:p_at_id)) t
             where Atp_Sc = :p_atp_sc
           ]';
          l_str:= regexp_replace(l_str, ':p_at_id', p_at_id, 1, 0, 'i');
          l_str:= regexp_replace(l_str, ':p_atp_sc', nvl(c.at_sc, -1), 1, 0, 'i');
        end if;*/
        l_str :=
            q'[
       select
             row_number() over(order by birth_dt) as "F09",
             pib          as F9,
             birth_dt_str as F10,
             Relation_Tp  as F11,
             case when is_disabled = 'T' then 'наявна' else 'відсутня' end F12,
             case when is_capable  = 'T' then 'дієздатний(а)'
                  when is_capable  = 'F' then 'недієздатний(а)'
             end        as F13_old,
             case when trunc(months_between(sysdate, t.birth_dt)/12) > 18 and
                       is_capable = 'T' then uss_esr.Api$Act_Rpt.Chk_Val2(1,1)
                  else uss_esr.Api$Act_Rpt.Chk_Val2(1,2)
             end as F13,
             work_place as F14,
             case when is_adr_matching = 'T' then 'Так' end as F15,
             case when is_adr_matching = 'F' then 'Ні'  end as F16,
             phone        as F17,
             Fact_Address as F18
       from table(uss_esr.Api$Act_Rpt.At_Person_for_act(:p_at_id)) t
       where t.history_status = 'A'
       order by atp_num
     ]';
        l_str :=
            REGEXP_REPLACE (l_str,
                            ':p_at_id',
                            p_at_id,
                            1,
                            0,
                            'i');
        rdm$rtfl_univ.AddDataset ('ds_os', l_str);



        --2 Наявність СЖО uss_ndi.V_DDN_EXIST_SGN
        addparam ('s3-1', chk_val2 ('EX', Get_Ftr (p_at_id, p_nda => 830)));
        addparam ('s3-2', chk_val2 ('NE', Get_Ftr (p_at_id, p_nda => 830)));
        addparam (
            's4',
            v_ddn ('uss_ndi.V_DDN_SS_CAUSES_DLC',
                   Get_Ftr_Nt (p_at_id, p_nda => 831),
                   '; '));
        --1)Наявність у особи ознак психологічної травми uss_ndi.V_DDN_EXIST_SGN
        rdm$rtfl_univ.AddDataset (
            'ds_r1',
               q'[
    SELECT uss_esr.api$act_rpt.Underline_ds(atp_ln||' '||atp_fn||' '||atp_mn, 1) as s5_pib,
           uss_esr.api$act_rpt.chk_val2('EX', f.atef_feature) as s5_1,
           uss_esr.api$act_rpt.chk_val2('NE', f.atef_feature) as s5_2
      FROM uss_esr.v_at_person t
      join uss_esr.v_at_section s on (s.ate_at = t.atp_at and s.ate_nng = 954 and s.ate_atp = t.atp_id)
      join uss_esr.v_at_section_feature f on (f.atef_ate = s.ate_id and f.atef_nda = 832)
     where t.atp_at = ]'
            || p_at_id
            || q'[
       and t.history_status = 'A'
     order by atp_num
  ]');

        /*addparam('s5-1',    chk_val2('EX',  Get_Ftr(p_at_id, p_nda => 832)));
        addparam('s5-2',    chk_val2('NE',  Get_Ftr(p_at_id, p_nda => 832)));*/

        --2) Вплив СЖО на стан задоволення потреб особи   uss_ndi.V_DDN_STSFCN_SGN
        rdm$rtfl_univ.AddDataset (
            'ds_r2',
               q'[
    SELECT uss_esr.api$act_rpt.Underline_ds(atp_ln||' '||atp_fn||' '||atp_mn, 1) as s5_pib,
           uss_esr.api$act_rpt.chk_val2('SF',  uss_esr.api$act_rpt.Get_Ftr(atp_at, p_nda => 833, p_Atp => t.atp_id)) as s6_1,
           uss_esr.api$act_rpt.chk_val2('AVG', uss_esr.api$act_rpt.Get_Ftr(atp_at, p_nda => 833, p_Atp => t.atp_id)) as s6_2,
           uss_esr.api$act_rpt.chk_val2('NSF', uss_esr.api$act_rpt.Get_Ftr(atp_at, p_nda => 833, p_Atp => t.atp_id)) as s6_3,
           uss_esr.api$act_rpt.Get_Ftr_Nt(atp_at, p_nda => 834, p_Atp => t.atp_id) as s7,
           --uss_ndi.V_DDN_ABILITY_SGN
           uss_esr.api$act_rpt.chk_val2('AB',  uss_esr.api$act_rpt.Get_Ftr(atp_at, p_nda => 835, p_Atp => t.atp_id)) as s8_1,
           uss_esr.api$act_rpt.chk_val2('NS',  uss_esr.api$act_rpt.Get_Ftr(atp_at, p_nda => 835, p_Atp => t.atp_id)) as s8_2,
           uss_esr.api$act_rpt.chk_val2('NAB', uss_esr.api$act_rpt.Get_Ftr(atp_at, p_nda => 835, p_Atp => t.atp_id)) as s8_3,
           uss_esr.api$act_rpt.Get_Ftr_Nt(atp_at, p_nda => 836, p_Atp => t.atp_id) as s9
      FROM uss_esr.v_at_person t
      join uss_esr.v_at_section s on (s.ate_at = t.atp_at and s.ate_nng = 952 and s.ate_atp = t.atp_id)
     where t.atp_at = ]'
            || p_at_id
            || q'[
       and t.history_status = 'A'
     order by atp_num
  ]');
        /*addparam('s6-1',    chk_val2('SF',  Get_Ftr(p_at_id, p_nda => 833)));
        addparam('s6-2',    chk_val2('AVG', Get_Ftr(p_at_id, p_nda => 833)));
        addparam('s6-3',    chk_val2('NSF', Get_Ftr(p_at_id, p_nda => 833)));
        addparam('s7',      Get_Ftr_Nt(p_at_id, p_nda => 834));
        --uss_ndi.V_DDN_ABILITY_SGN
        addparam('s8-1',    chk_val2('AB',  Get_Ftr(p_at_id, p_nda => 835)));
        addparam('s8-2',    chk_val2('NS',  Get_Ftr(p_at_id, p_nda => 835)));
        addparam('s8-3',    chk_val2('NAB', Get_Ftr(p_at_id, p_nda => 835)));
        addparam('s9',      Get_Ftr_Nt(p_at_id, p_nda => 836));*/

        --3) вплив факторів сім’ї та середовища   uss_ndi.V_DDN_PS_NG_SGN
        addparam ('s10-1', chk_val2 ('PS', Get_Ftr (p_at_id, p_nda => 837)));
        addparam ('s10-2', chk_val2 ('NU', Get_Ftr (p_at_id, p_nda => 837)));
        addparam ('s10-3', chk_val2 ('NG', Get_Ftr (p_at_id, p_nda => 837)));
        addparam ('s11', Get_Ftr_Nt (p_at_id, p_nda => 838));
        --4) тривалість існування проблем uss_ndi.V_DDN_DURAT_SGN
        addparam ('s12-1', chk_val2 ('SVY', Get_Ftr (p_at_id, p_nda => 839)));
        addparam ('s12-2', chk_val2 ('MY', Get_Ftr (p_at_id, p_nda => 839)));
        addparam ('s12-3', chk_val2 ('U2Y', Get_Ftr (p_at_id, p_nda => 839)));
        addparam ('s12-4', chk_val2 ('U2M', Get_Ftr (p_at_id, p_nda => 839)));
        addparam ('s12-5', chk_val2 ('U2D', Get_Ftr (p_at_id, p_nda => 839)));
        addparam ('s13', Get_Ftr_Nt (p_at_id, p_nda => 8320));

        --5) усвідомлення наявності проблем та готовність до співпраці з надавачами послуг
        rdm$rtfl_univ.AddDataset (
            'ds_r3',
               q'[
    SELECT uss_esr.api$act_rpt.Underline_ds(atp_ln||' '||atp_fn||' '||atp_mn, 1) as s5_pib,
           uss_esr.api$act_rpt.Get_Ftr_Chk2(atp_at, p_nda => 840, p_Atp => t.atp_id) as s14_1,
           uss_esr.api$act_rpt.Get_Ftr_Chk2(atp_at, p_nda => 840, p_Chk => 'F', p_Atp => t.atp_id) as s14_2,
           uss_esr.api$act_rpt.Get_Ftr_Chk2(atp_at, p_nda => 841, p_Atp => t.atp_id) as s15_1,
           uss_esr.api$act_rpt.Get_Ftr_Chk2(atp_at, p_nda => 841, p_Chk => 'F', p_Atp => t.atp_id) as s15_2,
           uss_esr.api$act_rpt.Get_Ftr_Nt(atp_at, p_nda => 842, p_Atp => t.atp_id) as s16
      FROM uss_esr.v_at_person t
      join uss_esr.v_at_section s on (s.ate_at = t.atp_at and s.ate_nng = 953 and s.ate_atp = t.atp_id)
     where t.atp_at = ]'
            || p_at_id
            || q'[
       and t.history_status = 'A'
     order by atp_num
  ]');
        /*addparam('s14-1',     Get_Ftr_Chk2(p_at_id, p_nda => 840));
        addparam('s14-2',     Get_Ftr_Chk2(p_at_id, p_nda => 840, p_Chk => 'F'));
        addparam('s15-1',     Get_Ftr_Chk2(p_at_id, p_nda => 841));
        addparam('s15-2',     Get_Ftr_Chk2(p_at_id, p_nda => 841, p_Chk => 'F'));
        addparam('s16',      Get_Ftr_Nt(p_at_id, p_nda => 842));*/

        --особа потребує надання соціальних послуг  select * from USS_NDI.v_NDI_SERVICE_TYPE t where t.nst_ap_tp = 'G' order by t.nst_id;
        --AddNstAtService(p_at_id);
        AddNstAtService2 (p_at_id, 'nst_all');

        --Інші дії
        addparam ('s18', Get_Ftr_Chk2 (p_at_id, p_nda => 843));
        addparam ('s19', Get_Ftr_Chk2 (p_at_id, p_nda => 844));

        IF Get_Ftr (p_at_id, p_nda => 844) = 'T'
        THEN                                                         --#101392
            --addparam('s20',  coalesce(Get_Ftr_Nt(p_at_id, p_nda => 844), Get_Nsp_Name(p_rnspm_id => Get_Ftr_Nt(p_at_id, p_nda => 5556)))       );
            addparam (
                's20',
                COALESCE (
                    Get_Ftr_Nt (p_at_id, p_nda => 5556),
                    uss_rnsp.api$find.Get_Nsp_Name (
                        Get_Ftr (p_at_id, p_nda => 5556)),
                    Get_Ftr_Nt (p_at_id, p_nda => 844)));
        END IF;

        addparam ('s22-1', Get_Ftr_Chk2 (p_at_id, p_nda => 845));       --Інше
        addparam ('s22-2', Get_Ftr_Nt (p_at_id, p_nda => 3696));

        --підписи
        BEGIN
            rdm$rtfl_univ.AddDataset (
                'ds_r4',
                   q'[
    SELECT uss_esr.api$act_rpt.Underline_ds(atp_ln||' '||atp_fn||' '||atp_mn, 1) as s23,
           uss_esr.api$act_rpt.get_sign_mark(atp_at, t.atp_id) as sgn_1,
           --ознайомившись із результатами оцінки, uss_ndi.V_DDN_AGRMT_SGN
           uss_esr.api$act_rpt.chk_val2('AG',  uss_esr.api$act_rpt.Get_Ftr(atp_at, p_nda => 846, p_Atp => t.atp_id)) as s24_1,
           uss_esr.api$act_rpt.chk_val2('NAG', uss_esr.api$act_rpt.Get_Ftr(atp_at, p_nda => 846, p_Atp => t.atp_id)) as s24_2,
           uss_esr.api$act_rpt.chk_val2('SO',  uss_esr.api$act_rpt.Get_Ftr(atp_at, p_nda => 846, p_Atp => t.atp_id)) as s24_3,
           uss_esr.api$act_rpt.Get_Ftr_Chk2(atp_at, p_nda => 3705, p_Atp => t.atp_id) as s25

      FROM uss_esr.v_at_person t
      join uss_esr.v_at_section s on (s.ate_at = t.atp_at and s.ate_nng = 158 and s.ate_atp = t.atp_id)
     where t.atp_at = ]'
                || p_at_id
                || q'[
       and t.history_status = 'A'
  ]');
            --3. Відмітка про ознайомлення з результатами оцінки потреб

            addparam (
                's23',
                NVL (
                    NVL (get_at_signers_pers (p_at_id, l_FAtp).pib,
                         l_person_os.pib),
                    '_______________________________'));
            addparam ('sgn_1', get_sign_mark (p_at_id, l_FAtp));

            /* --ознайомившись із результатами оцінки, uss_ndi.V_DDN_AGRMT_SGN
             addparam('s24-1',  chk_val2('AG',  Get_Ftr(p_at_id, p_nda => 846)));
             addparam('s24-2',  chk_val2('NAG', Get_Ftr(p_at_id, p_nda => 846)));
             addparam('s24-3',  chk_val2('SO',  Get_Ftr(p_at_id, p_nda => 846)));
             addparam('s25',    Get_Ftr_Chk2(p_at_id, p_nda => 3705));
             */
            SELECT LISTAGG (
                          Underline (
                              t.atp_ln || ' ' || t.atp_fn || ' ' || t.atp_mn,
                              1)
                       || ': '
                       || f.atef_notes,
                       '; '
                       ON OVERFLOW TRUNCATE '...')
                   WITHIN GROUP (ORDER BY t.atp_num)
              INTO l_str
              FROM at_person  t
                   JOIN at_section s ON (s.ate_atp = t.atp_id)
                   JOIN at_section_feature f ON (f.atef_ate = s.ate_id)
             WHERE     t.atp_at = p_at_id
                   AND t.history_status = 'A'
                   AND f.atef_nda = 847
                   AND f.atef_notes IS NOT NULL;

            addparam ('s26', l_str);
            --addparam('s26',     Get_Ftr_Nt(p_at_id, p_nda => 847));

            --4. Фахівець, який здійснює оцінку потреб
            addparam (
                's27',
                   GetCuPIB (c.at_cu)
                || NVL2 (Get_Ftr_Nt (p_at_id, p_nda => 8326),
                         ', ' || Get_Ftr_Nt (p_at_id, p_nda => 8326))); --ПІБ, посада
            addparam ('s29-1', Get_Ftr_Chk2 (p_at_id, p_nda => 7418)); --підписано КЕП
            addparam ('s29', Get_Ftr_Nt (p_at_id, p_nda => 8325));   --телефон

            --Інші спеціалісти, задіяні в оцінці потреб
            l_str :=
                q'[
      select s.atop_ln||' '||s.atop_fn||' '||s.atop_mn||', '||s.atop_position spc_1,  --ПІБ, посада
             s.atop_phone spc_2 --телефон
        from uss_esr.v_at_other_spec s
       where s.atop_at = :p_at_id --and s.atop_tp = 'OC'
         and s.history_status = 'A'
         and s.atop_Tp != 'CCM'
      ]';
            l_str :=
                REGEXP_REPLACE (l_str,
                                ':p_at_id',
                                p_at_id,
                                1,
                                0,
                                'i');
            rdm$rtfl_univ.AddDataset ('ds_spc', l_str);
        END;

        addparam ('s33', Date2Str (c.at_action_stop_dt));

        --5. Відмітки про затвердження висновку керівником
        addparam ('s34-1', chk_val2 (1, 1));
        addparam ('s34-2', chk_val2 (1, 2));
        --Uss_Ndi.v_Ddn_Case_Class
        addparam ('s35-1', chk_val2 ('SM', c.at_case_class));
        addparam ('s35-2', chk_val2 ('MD', c.at_case_class));
        addparam ('s35-3', chk_val2 ('DF', c.at_case_class));
        addparam ('s35-4', chk_val2 ('EM', c.at_case_class));

        --Керівник
        OPEN c_sgn ('PR');

        FETCH c_sgn INTO r_sgn;

        CLOSE c_sgn;

        addparam (
            's36',
            Underline (
                   Get_Ftr_Nt_Lst (p_at_id, p_nda => '8306,8307,8308')
                ||                                                 --r_sgn.pib
                   --посада
                   NVL2 (Get_Ftr_Nt (p_at_id, p_nda => 8309),
                         ', ' || Get_Ftr_Nt (p_at_id, p_nda => 8309)),
                2));
        addparam ('s36-1', Get_Ftr_Chk2 (p_at_id, p_nda => 7419)); --підписано КЕП
        addparam ('s38', Get_Ftr_Nt (p_At_Id => p_at_id, p_Nda => 8456) /*to_char(r_sgn.ati_sign_dt, 'dd.mm.yyyy')*/
                                                                       ); --#101392

        rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                         p_rpt_blob   => l_result);

        replace_ekr (l_result);

        RETURN l_result;
    END BUILD_ACT_NEEDS_ASSESSMENT_S2;

    --«Акт оцінки потреб сім’їи» (з висновком оцінки потреб особи) AVOP
    FUNCTION ACT_DOC_804_AVOP_S1 (p_at_id IN NUMBER)
        RETURN BLOB
    IS
    BEGIN
        RETURN Api$act_Rpt.Build_Act_Needs_Assessment (p_At_Id => p_At_Id);
    END;

    --«Акт оцінки потреб сім’їи» (з висновком оцінки потреб особи) AVOP
    FUNCTION ACT_DOC_804_AVOP_S2 (p_at_id IN NUMBER)
        RETURN BLOB
    IS
    BEGIN
        RETURN Api$act_Rpt.Build_Act_Needs_Assessment_S2 (p_At_Id => p_At_Id);
    END;

    --#91351 839 «Алфавітна картка отримувача соціальної послуги»
    FUNCTION BUILD_ACT_KARD_R3 (p_at_id IN NUMBER)
        RETURN BLOB
    IS
        --select t.*, rowid from uss_esr.rpt_templates t where t.rt_code = 'BUILD_ACT_KARD_R3';

        CURSOR c_at IS
            SELECT a.at_ap,
                   a.at_pc,
                   a.at_org,
                   a.at_dt,
                   a.at_action_start_dt,
                   a.at_action_stop_dt,
                   a.at_family_info,
                   a.at_live_address,
                   a.at_case_class,
                   a.at_cu,
                   a.at_rnspm,
                   sc.sc_unique,
                   p.atp_id,
                   pc.pc_sc,
                   p.Atp_App_Tp
              FROM uss_esr.act              a,
                   uss_esr.personalcase     pc,
                   uss_esr.At_Person        p,
                   uss_person.v_socialcard  sc
             WHERE     a.at_id = p_at_id
                   AND pc.pc_id = a.at_pc
                   AND p.atp_at = a.at_id
                   AND p.atp_sc = pc.pc_sc
                   AND sc.sc_id = a.at_sc;

        l_at       c_at%ROWTYPE;

        --l_atp_O  number:= get_AtPerson_id(p_at_id, 'OS'); --отримувач
        l_prs      R_Person_for_act;


        l_jbr_id   NUMBER;
        l_result   BLOB;
    BEGIN
        rdm$rtfl_univ.initreport (p_code     => 'BUILD_ACT_KARD_R3',
                                  p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);

        OPEN c_at;

        FETCH c_at INTO l_at;

        CLOSE c_at;

        --l_prs:= get_AtPerson(p_at => p_at_id, p_atp => l_atp_O);
        l_prs := get_AtPerson (p_at => p_at_id, p_atp => l_at.atp_id);

        --отримувач
        addparam ('p1', l_prs.LN);
        addparam ('p2', l_prs.Fn);
        addparam ('p3', l_prs.Mn);
        addparam ('p4', l_prs.birth_dt_str);
        addparam ('p5', Get_Ftr_Nt (p_at_id, p_nda => 3591)); --Місце народження
        addparam ('p6', l_prs.Fact_Address);
        addparam ('p7', Get_Ftr_Nt (p_at_id, p_nda => 3609));
        addparam ('p8', Get_Ftr_Nt (p_at_id, p_nda => 3610));
        addparam ('p9', Get_Ftr_Nt (p_at_id, p_nda => 3611));
        addparam ('p10', Get_Ftr_Nt (p_at_id, p_nda => 3612));
        addparam ('p19', Get_Ftr_Nt (p_at_id, p_nda => 3612));

        --результуючий blob
        rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                         p_rpt_blob   => l_result);

        replace_ekr (l_result);

        RETURN l_result;
    END;

    --#91353  844 «Картка визначення індивідуальних потреб особи/сім’ї в наданні СП натуральної допомоги»
    FUNCTION BUILD_ACT_KARD_R4 (p_at_id IN NUMBER)
        RETURN BLOB
    IS
        --select t.*, rowid from uss_esr.rpt_templates t where t.rt_code = 'BUILD_ACT_KARD_R4';

        CURSOR c_at IS
            SELECT a.at_ap,
                   a.at_pc,
                   a.at_org,
                   a.at_dt,
                   a.at_action_start_dt,
                   a.at_action_stop_dt,
                   a.at_family_info,
                   a.at_live_address,
                   a.at_case_class,
                   a.at_cu,
                   a.at_rnspm,
                   a.at_notes,
                   sc.sc_unique,
                   p.atp_id,
                   pc.pc_sc,
                   p.Atp_App_Tp,
                   lc.atlc_living_square,                        --площа житла
                   lc.atlc_holding_square,         --площа присадибної ділянки
                   lc.atlc_housing_condition,                     --Стан житла 
                   lc.atlc_residents_cnt,
                   lc.atlc_inv_cnt,
                   lc.atlc_inv_child_cnt,
                   ikis_rbm.tools.GetCuPib (at_cu)     AS cu_pib
              FROM uss_esr.act                   a,
                   uss_esr.personalcase          pc,
                   uss_esr.At_Person             p,
                   uss_person.v_socialcard       sc,
                   uss_esr.At_living_conditions  lc
             WHERE     a.at_id = p_at_id
                   AND pc.pc_id = a.at_pc
                   AND p.atp_at = a.at_id
                   AND p.atp_sc = pc.pc_sc
                   AND sc.sc_id = a.at_sc
                   AND lc.atlc_at(+) = a.at_id;

        l_at       c_at%ROWTYPE;

        l_atp_O    NUMBER := get_AtPerson_id (p_at_id, 'OS');      --отримувач
        l_atp_Z    NUMBER := get_AtPerson_id (p_at_id, 'Z');         --заявник
        l_prs_O    R_Person_for_act;
        l_prs_Z    R_Person_for_act;

        l_str      VARCHAR2 (32000);
        l_cnt      INTEGER;
        l_int      TInt;
        l_vrch     TVarchar2;
        tbl22      TRefer;

        l_jbr_id   NUMBER;
        l_result   BLOB;
    BEGIN
        rdm$rtfl_univ.initreport (p_code     => 'BUILD_ACT_KARD_R4',
                                  p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);

        OPEN c_at;

        FETCH c_at INTO l_at;

        CLOSE c_at;

        l_prs_O := get_AtPerson (p_at => p_at_id, p_atp => l_atp_O);
        l_prs_Z := get_AtPerson (p_at => p_at_id, p_atp => l_atp_Z);

        addparam ('p1', Get_Nsp_Name (p_rnspm_id => l_at.at_rnspm)); --надавач послуги
        addparam ('p2', TO_DATE (l_at.at_dt, 'dd.mm.yyyy'));

        --І. Загальні відомості

        --отримувач соціальної послуги / його законний представник / уповноважений представник сім’ї
        addparam ('p3', NULL);             --#102327 невідомо, звідки це брати

        addparam ('p4', l_prs_Z.Pib);                                --заявник
        --отримувач
        addparam ('p5', Underline (l_prs_O.Pib, 1));
        addparam ('p6', Underline (l_prs_O.birth_dt_str, 1));
        addparam (
            'p7',
            Underline (
                ROUND (MONTHS_BETWEEN (SYSDATE, l_prs_O.birth_dt) / 12),
                1));                                            --повних років
        addparam (
            'p8',
            Underline (
                   l_prs_O.at_live_address
                || CASE
                       WHEN l_prs_O.phone IS NOT NULL
                       THEN
                           ', тел. ' || l_prs_O.phone
                   END,
                1));                                  --Місце проживання, телефон
        addparam ('p10', Underline (Get_Ftr_Chk (p_at_id, p_nda => 4141), 1));
        addparam ('p11', Underline (Get_Ftr_Nt (p_at_id, p_nda => 4141), 1));

        addparam ('p12', Get_Ftr_Chk (p_at_id, p_nda => 4142));
        addparam ('p13', Underline (Get_Ftr_Nt (p_at_id, p_nda => 4142), 1));

        addparam ('p14', Get_Ftr_Chk (p_at_id, p_nda => 4143));
        addparam ('p15', Get_Ftr_Chk (p_at_id, p_nda => 4144));
        --дитина з інвалідністю
        addparam ('p16', Get_Ftr_Chk (p_at_id, p_nda => 4145));
        addparam ('p17', Underline (Get_Ftr_Nt (p_at_id, p_nda => 4145), 1));
        addparam ('p18', Get_Ftr_Chk (p_at_id, p_nda => 4146));
        addparam ('p19', Underline (Get_Ftr_Nt (p_at_id, p_nda => 4146), 1));

        addparam ('p20', Get_Ftr_Chk (p_at_id, p_nda => 4147)); --працездатна особа

        --BEGIN особа, якій завдана шкода BEGIN
        l_int :=
            TInt (4149,
                  4150,
                  4151,
                  4152,
                  4153,
                  4154,
                  4155);
        l_vrch :=
            TVarchar2 ('пожежею',
                       'стихійним лихом',
                       'катастрофою',
                       'бойовими діями',
                       'терористичним актом',
                       'збройним конфліктом',
                       'тимчасовою окупацією');
        tbl22 := CreateRef (l_int, l_vrch);

        SELECT LISTAGG (
                   CASE
                       WHEN Api$Act_Rpt.Get_Ftr (p_at_id, p_nda => t.id) = 'T'
                       THEN
                           '\ul' || t.decr || '\ul0'
                       ELSE
                           t.decr
                   END,
                   ' / ')
               WITHIN GROUP (ORDER BY ord)
          INTO l_str
          FROM TABLE (tbl22) t;

        addparam ('p21', Get_Ftr_Chk (p_at_id, p_nda => 4148));
        addparam ('p22', l_str);
        --END особа, якій завдана шкода

        --бездомна особа
        addparam ('p23', Get_Ftr_Chk (p_at_id, p_nda => 4156));
        addparam ('p24', Get_Ftr_Chk (p_at_id, p_nda => 4157));

        --біженець, особа, яка потребує додаткового захисту
        l_cnt := 0;

        SELECT LISTAGG (
                   CASE
                       WHEN Api$Act_Rpt.Get_Ftr (p_at_id, p_nda => 4158) =
                            t.dic_value
                       THEN
                           '\ul' || t.dic_name || '\ul0'
                       ELSE
                           t.dic_name
                   END,
                   ' / ')
               WITHIN GROUP (ORDER BY t.dic_srtordr)    str,
               MAX (
                   CASE
                       WHEN Api$Act_Rpt.Get_Ftr (p_at_id, p_nda => 4158) =
                            t.dic_value
                       THEN
                           '1'
                   END)                                 cnt
          INTO l_str, l_cnt
          FROM uss_ndi.v_ddn_ss_add_protect t
         WHERE t.dic_st = 'A';

        addparam ('p25', chk_val (l_cnt, 1));
        addparam ('p26', l_str);

        addparam ('p27', Get_Ftr_Chk (p_at_id, p_nda => 4159));
        addparam ('p28', Get_Ftr_Chk (p_at_id, p_nda => 4160));
        addparam ('p29', Get_Ftr_Chk (p_at_id, p_nda => 4161));
        addparam ('p30', Get_Ftr_Chk (p_at_id, p_nda => 4162));
        addparam ('p31', Get_Ftr_Chk (p_at_id, p_nda => 4163));
        addparam ('p32', Get_Ftr_Chk (p_at_id, p_nda => 4164));
        addparam ('p33', Get_Ftr_Chk (p_at_id, p_nda => 4165));

        --Відомості про членів сім’ї:
        l_str :=
            q'[
    select
           row_number() over(order by birth_dt) p33,
           pib          as p34,
           birth_dt_str as p35,
           Relation_Tp  as p36,
           case when is_disabled = 'T' then 'Так' else 'Ні' end as p37,
           case when is_disordered = 'T' then 'Так' else 'Ні' end as p38,
           /*nvl((select t1.dic_name from uss_ndi.v_ddn_capacity_tp t1 where t1.dic_value = t.is_capable),*/
					     decode(is_capable, 'T', 'Так', 'F', 'Ні')/*)*/ as p39
     from table(uss_esr.Api$Act_Rpt.At_Person_for_act(:p_at_id)) t
     order by p33
  ]';
        l_str :=
            REGEXP_REPLACE (l_str,
                            ':p_at_id',
                            p_at_id,
                            1,
                            0,
                            'i');
        rdm$rtfl_univ.AddDataset ('ds', l_str);

        --ІІ. Соціально-побутові умови проживання
        addparam (
            'p40',
            TO_CHAR (l_at.atlc_living_square,
                     'FM9999999999999990D99',
                     'NLS_NUMERIC_CHARACTERS='', '''''));
        addparam (
            'p41',
            TO_CHAR (l_at.atlc_holding_square,
                     'FM9999999999999990D99',
                     'NLS_NUMERIC_CHARACTERS='', '''''));
        addparam ('p42', l_at.atlc_housing_condition);

        addparam (
            'p42_1',
            CASE
                WHEN l_at.atlc_housing_condition = 'Z' THEN org2ekr (c_chk)
                ELSE org2ekr (c_unchk)
            END);
        addparam ('p42_2', org2ekr (c_unchk));

        addparam ('p43', NVL (TO_CHAR (l_at.atlc_residents_cnt), '---'));
        addparam ('p44', NVL (TO_CHAR (l_at.atlc_inv_cnt), '---'));
        addparam ('p45', NVL (TO_CHAR (l_at.atlc_inv_child_cnt), '---'));

        --ІІІ. Потреба отримувача в соціальній послузі натуральної допомоги
        addparam ('p46', Get_Ftr_Chk (p_at_id, p_nda => 4166));
        addparam ('p47', Get_Ftr_Chk (p_at_id, p_nda => 4167));
        addparam ('p48', Get_Ftr_Chk (p_at_id, p_nda => 4168));
        addparam ('p49', Get_Ftr_Chk (p_at_id, p_nda => 4169));
        addparam ('p50', Get_Ftr_Chk (p_at_id, p_nda => 4170));
        addparam ('p51', Get_Ftr_Chk (p_at_id, p_nda => 4171));
        addparam ('p52', Get_Ftr_Chk (p_at_id, p_nda => 4172));
        addparam ('p53', Get_Ftr_Chk (p_at_id, p_nda => 4173));
        addparam ('p54', Get_Ftr_Chk (p_at_id, p_nda => 4174));
        addparam ('p55', Get_Ftr_Chk (p_at_id, p_nda => 4175));
        addparam ('p56', Get_Ftr_Chk (p_at_id, p_nda => 4176));
        addparam ('p57', Get_Ftr_Chk (p_at_id, p_nda => 4177));
        addparam ('p58', Get_Ftr_Chk (p_at_id, p_nda => 4178));
        addparam ('p59', Get_Ftr_Chk (p_at_id, p_nda => 4179));
        addparam ('p60', Get_Ftr_Chk (p_at_id, p_nda => 4180));
        addparam ('p61', Get_Ftr_Chk (p_at_id, p_nda => 4181));
        addparam ('p62', Get_Ftr_Chk (p_at_id, p_nda => 4182));
        addparam ('p63', Get_Ftr_Chk (p_at_id, p_nda => 4183));
        addparam ('p64', Get_Ftr_Chk (p_at_id, p_nda => 4184));

        --ІV. Місце надання соціальної послуги натуральної допомоги
        addparam ('p65', Get_Ftr_Chk (p_at_id, p_nda => 4185));
        addparam ('p66', Get_Ftr_Chk (p_at_id, p_nda => 4186));

        --V. Потреба в залученні до складу мультидисциплінарної команди інших фахівців
        addparam ('p67',
                  UnderLine (Get_Ftr_Nt (p_at_id, p_nda => 4187), TRUE));

        --VІ. Висновки
        addparam ('p68', Underline (get_AtSctNt (p_at_id, p_nng => 937), 1));

        --підписи --Фахівець, який проводив оцінювання
        addparam ('p69', l_at.cu_pib /*Get_Km(p_At_Id).Fn||' '||Get_Km(p_At_Id).Ln*/
                                    );                               --#102327
        addparam (
            'p70',
            NVL2 (l_prs_Z.LN,
                  l_prs_Z.fn || ' ' || l_prs_Z.LN,
                  l_prs_O.fn || ' ' || l_prs_O.LN));                 --заявник

        AddParam ('sgn_mark',
                  api$act_rpt.get_sign_mark (p_at_id, l_prs_Z.Atp_Id, ''));

        --результуючий blob
        rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                         p_rpt_blob   => l_result);

        replace_ekr (l_result);

        RETURN l_result;
    END;

    --#92995 «Договір про надання соціальних послуг»  at_tp='TCTR' USS_ESR.Cmes$act_Tctr
    FUNCTION ACT_DOC_858_AND_IP (p_at_id IN NUMBER)
        RETURN BLOB
    IS
        CURSOR c_act IS
            /*select a.at_org, a.at_num, a.at_dt, a.At_rnspm, a.At_notes,
                   a1.at_num at_num1, a1.at_dt at_dt1
              from act a, act a1, at_links l
             where a.at_id = p_at_id
               and l.atk_link_at(+)= a.at_id and a1.at_id(+)= l.atk_at;*/
            SELECT a.at_org,
                   a.at_num,
                   a.at_dt,
                   a.At_rnspm,
                   a.At_notes,
                   a1.at_num     at_num1,
                   a1.at_dt      AS at_dt1,
                   a1.at_id      AS at_id1
              FROM uss_esr.act a, uss_esr.act a1
             WHERE     a.at_id = p_at_id
                   AND a1.at_id(+) = a.at_main_link
                   AND a1.at_tp(+) = 'PDSP';

        c          c_act%ROWTYPE;

        CURSOR c_sng2 IS
              SELECT p.atp_ln || ' ' || p.atp_fn || ' ' || p.atp_mn     pib,
                     p.atp_id,
                     p.atp_phone                                        phone,
                     p.atp_live_address,
                     p.atp_fact_address
                FROM uss_esr.at_signers s, uss_esr.at_person p
               WHERE     s.ati_at = p_at_id
                     AND p.atp_at = s.ati_at
                     AND s.history_status = 'A'
                     AND s.ati_tp = 'RC'
                     AND p.atp_sc = s.ati_sc
                     AND p.history_status = 'A'
            ORDER BY s.ati_order
               FETCH FIRST ROW ONLY;

        l_sng2     c_sng2%ROWTYPE;

        CURSOR c_srv IS
            SELECT LISTAGG ( --nst.nst_name||' - '|| #101767 виводити лише значення з Ats_ss_method (назву послуги не виводити)
                       CASE
                           WHEN s.Ats_ss_method = 'F' AND x_flag = 'T'
                           THEN
                                  'за рахунок бюджетних коштів/'
                               || Underline (
                                      'за рахунок коштів Надавача соціальних послуг недержавного сектору',
                                      1)
                           WHEN s.Ats_ss_method = 'F'
                           THEN
                                  Underline ('за рахунок бюджетних коштів',
                                             1)
                               || '/за рахунок коштів Надавача соціальних послуг недержавного сектору'
                           WHEN s.Ats_ss_method = 'C'
                           THEN
                               'за рахунок Отримувача соціальних послуг або третіх осіб'
                           WHEN s.Ats_ss_method = 'D'
                           THEN
                               'з установленням диференційованої плати залежно від доходу Отримувача соціальних'
                       END,
                       ';' || c_chr10)
                   WITHIN GROUP (ORDER BY nst.nst_name)
              FROM uss_esr.at_service          s, --uss_ndi.v_ddn_tctr_ats_st st, Uss_Ndi.v_Ddn_Ss_Method m
                   Uss_Ndi.v_Ndi_Service_Type  nst
                   LEFT JOIN
                   (SELECT uss_esr.api$act_rpt.AtDocAtrStr (p_at_id, 8455)    AS x_flag
                      FROM DUAL) d
                       ON (1 = 1)
             WHERE     s.ats_at = p_at_id
                   AND s.history_status = 'A'
                   AND s.ats_st IN ('PP',
                                    'SG',
                                    'P',
                                    'R')
                   AND nst.nst_id = s.ats_nst;

        CURSOR c_srv2 IS
            SELECT LISTAGG ( --nst.nst_name|| #101767 назву послуги не виводити
                          Atp.Dic_Name
                       || CASE
                              WHEN s.ats_ss_address_tp = 'S'
                              THEN
                                  NVL2 (
                                      s.ats_rnspa,
                                         ' - '
                                      || uss_rnsp.api$find.get_address_name (
                                             s.ats_rnspa),
                                      NULL)
                              ELSE
                                  NVL2 (s.Ats_Ss_Address,
                                        ' - ' || s.Ats_Ss_Address,
                                        NULL)
                          END,
                       ';' || c_Chr10)                                      --
                   WITHIN GROUP (ORDER BY Nst.Nst_Name)        AS Str,
                   COUNT (*)                                   Cnt,
                   SUM (s.Ats_Tarif_Sum)                       Tarif_Sum,
                   SUM (s.Ats_Act_Sum)                         Act_Sum,
                   MAX (DECODE (s.Ats_Ss_Method, 'F', 'F'))    Is_f
              FROM Uss_Esr.At_Service          s, --uss_ndi.v_ddn_tctr_ats_st st, Uss_Ndi.v_Ddn_Ss_Method m
                   Uss_Ndi.v_Ndi_Service_Type  Nst,
                   Uss_Ndi.v_Ddn_Rnsp_Adr_Tp   Atp
             WHERE     s.Ats_At = p_At_Id
                   AND s.History_Status = 'A'
                   AND s.Ats_St IN ('PP',
                                    'SG',
                                    'P',
                                    'R')
                   AND Nst.Nst_Id = s.Ats_Nst
                   AND Atp.Dic_Value(+) = s.Ats_Ss_Address_Tp;

        srv2       c_srv2%ROWTYPE;

        l_str      VARCHAR2 (3200);
        l_val      VARCHAR2 (1000);

        l_jbr_id   NUMBER;
        l_result   BLOB;
    BEGIN
        rdm$rtfl_univ.initreport (p_code     => 'ACT_DOC_858_AND_IP',
                                  p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);

        ------------------------------------
        OPEN c_act;

        FETCH c_act INTO c;

        CLOSE c_act;

        OPEN c_sng2;

        FETCH c_sng2 INTO l_sng2;

        CLOSE c_sng2;

        AddParam ('at_id', p_at_id);
        AddParam ('p1', AtDocAtrStr (p_at_id, 3592));
        AddParam ('p2', Date2Str (c.at_dt));
        AddParam ('p3', Get_Nsp_Name (p_rnspm_id => c.At_rnspm)); --надавач соцпослуг
        AddParam (
            'p5',
            AtDocAtrStr (p_at_id, 3691) || ' ' || AtDocAtrStr (p_at_id, 2820)); --в особі - ПІБ
        --назва та реквізити установчого документа
        AddParam (
            'p6',
               AtDocAtrStr (p_at_id, 3614)
            || NVL2 (AtDocAtrStr (p_at_id, 3615),
                     ' № ' || AtDocAtrStr (p_at_id, 3615),
                     NULL));

        AddParam ('p8', l_sng2.pib);                        --ПІБ представника
        AddParam (
            'p9',
            NVL2 (AtDocAtrStr (p_at_id, 2823),
                  'що діє на підставі ' || AtDocAtrStr (p_at_id, 2823)));                --діє на підставі документа

        --II. Умови надання соціальних послуг та їх вартість
        AddParam ('p10', c.at_num1);
        AddParam ('p11', AtDocAtrDt (c.at_id1, 2934)              /*c.at_dt1*/
                                                    );
        AddParam ('p12', tools.GetOrgName (c.at_org));

        --2. Надавач соціальних послуг надає соціальні послуги
        OPEN c_srv;

        FETCH c_srv INTO l_str;

        CLOSE c_srv;

        AddParam ('p13', NVL2 (l_str, l_str || '.'));

        OPEN c_srv2;

        FETCH c_srv2 INTO srv2;

        CLOSE c_srv2;

        AddParam ('p14', NVL2 (srv2.str, srv2.str || '.'));

        AddParam ('p16',
                  CASE
                      WHEN srv2.is_f = 'F'
                      THEN
                          Underline ('-----------', 1) --#103046 якщо послуга надається безоплатно (в Ats_ss_method значення F)
                      WHEN srv2.tarif_sum > 0
                      THEN
                             srv2.tarif_sum
                          || ' '
                          || '('
                          || tools.sum_to_text (p_sum           => srv2.tarif_sum,
                                                p_is_cop        => 'F',
                                                p_is_currency   => 'F',
                                                p_cop_as_text   => 'F')
                          || ')'
                      ELSE
                          '____________________________'
                  END);
        AddParam ('p17',
                  CASE
                      WHEN srv2.is_f = 'F'
                      THEN
                          Underline ('-----------', 1)
                      WHEN srv2.act_sum > 0
                      THEN
                             srv2.act_sum
                          || ' '
                          || '('
                          || tools.sum_to_text (p_sum           => srv2.act_sum,
                                                p_is_cop        => 'F',
                                                p_is_currency   => 'F',
                                                p_cop_as_text   => 'F')
                          || ')'
                      ELSE
                          '____________________________'
                  END);
        AddParam ('p18', NVL2 (c.At_notes, 'Вид розрахунку ' || c.At_notes));

        --III. Права та обов'язки Надавача соціальних послуг

        l_str :=
            q'[
  select row_number() over(order by nst.nst_name) sp1, nst.nst_code sp2, nst.nst_name sp3
    from uss_esr.v_at_service s, Uss_Ndi.v_Ndi_Service_Type nst
   where s.ats_at = :p_at_id and s.history_status = 'A'
     and s.ats_st in ('PP', 'SG', 'P', 'R')
     and nst.nst_id = s.ats_nst
  order by sp1
  ]';
        l_str :=
            REGEXP_REPLACE (l_str,
                            ':p_at_id',
                            p_at_id,
                            1,
                            0,
                            'i');
        rdm$rtfl_univ.AddDataset ('sp', l_str);           -- соціальні послуги

        --IX. Місцезнаходження (місце проживання/перебування) та реквізити Сторін
        --надавач соціальних послуг
        AddParam ('sgn1', Get_Nsp_Name (p_rnspm_id => c.At_rnspm));
        AddParam ('sgn2', AtDocAtrStr (p_at_id, 3593));
        AddParam ('sgn3', AtDocAtrStr (p_at_id, 3594));
        AddParam ('sgn4', AtDocAtrStr (p_at_id, 3595));
        AddParam ('sgn5', AtDocAtrStr (p_at_id, 3596));
        AddParam ('sgn6', AtDocAtrStr (p_at_id, 2820));
        --Отримувач соціальних послуг
        AddParam ('sgn21', l_sng2.pib);

        -- документ, що посвідчує особу
        SELECT MAX (t.ndt_name)
          INTO l_val
          FROM uss_ndi.v_Ndi_Document_Type t
         WHERE t.ndt_id =
               NVL (AtDocAtrId (p_at_id, 3616), AtDocAtrStr (p_at_id, 3616));

        AddParam ('sgn22', l_val /*v_ddn('Uss_Ndi.v_Ndi_Document_Type', AtDocAtrStr(p_at_id, 3616))*/
                                 || ' ' || AtDocAtrStr (p_at_id, 3617));
        AddParam ('sgn23', l_sng2.atp_live_address);
        AddParam ('sgn24', l_sng2.atp_fact_address);

        SELECT MAX (i.sco_numident)
          INTO l_str
          FROM act t JOIN uss_person.v_sc_info i ON (i.sco_id = t.at_sc)
         WHERE t.at_id = p_at_id;

        AddParam ('sgn25', NVL (AtDocAtrStr (p_at_id, 3599), l_str));
        AddParam ('sgn26', l_sng2.phone);
        AddParam ('sgn27', l_sng2.pib);

        AddParam ('sgn_mark', get_sign_mark (p_at_id, l_sng2.atp_id, ''));
        ------------------------------------
        --додатки по індівідуальних планах
        --select * from Uss_Ndi.v_Ndi_At_Print_Config

        /*  обробка договору з причепленими IP - відключено 12.03.2024
        declare
          --співставлення акту інд.плану з процедурою виконання по ndt документа
          cursor cur(p_ndt number) is
           select a1.at_id
             from uss_esr.act a0, uss_esr.act a1, uss_esr.at_document d
            where a0.at_id = p_at_id
              and a1.at_ap = a0.at_ap and a1.at_tp = 'IP'
              and d.atd_at = a1.at_id and d.history_status = 'A'
              and d.atd_ndt = p_ndt;
          l_at_id number;
        begin
          for c in
          (select distinct t.napc_ndt, t.napc_form_make_prc from Uss_Ndi.v_Ndi_At_Print_Config t
            where t.napc_at_tp = 'IP'
            order by t.napc_form_make_prc
          )
          loop
            l_at_id:= null;
            open cur(p_ndt => c.napc_ndt); fetch cur into l_at_id; close cur;

            --lb:= ACT_IP_DOC_871_R1(p_at_id => p_at_id, p_bild_doc => 0);
            --lb:= ACT_DOC_846_R1(p_at_id => p_at_id, p_bild_doc => 0);
            --exit;

            --dbms_output.put_line(c.napc_form_make_prc);
            if upper(c.napc_form_make_prc) not like '%BUILD_STUB%' then
              execute immediate 'declare lb blob; begin lb:= '||c.napc_form_make_prc||'('||nvl(l_at_id, 0)||', 0); end;';
            end if;
          end loop;
        end;
        */
        ------------------------------------
        rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                         p_rpt_blob   => l_result);
        replace_ekr (l_result);

        RETURN l_result;
    END;

    PROCEDURE AddDatasetIPGlobal (p_at_id NUMBER, p_DsGlobal VARCHAR2)
    IS
        CURSOR cur IS
            SELECT atip_id
              FROM At_individual_plan atip
             WHERE atip.atip_at = p_at_id AND atip.history_status = 'A';

        l_id    NUMBER;
        l_str   VARCHAR2 (500);
    BEGIN
        OPEN cur;

        FETCH cur INTO l_id;

        CLOSE cur;

        --для перевірки коректності будування ВСІХ ІР актів
        IF C_TEST = 2
        THEN
            l_id := 1;
        END IF;

        l_str :=
               'select '
            || p_at_id
            || ' at_id from dual'
            || CASE WHEN l_id IS NULL THEN ' where 1=2' END;

        rdm$rtfl_univ.AddDataset (p_DsGlobal, l_str);
    END;

    --#92990 002.0 Індивідуальний план надання СП консультування
    --p_bild_doc = 1 - окремий бланк інд.плана, інакше - це кусок, котрий буде у сводному звіті
    FUNCTION ACT_IP_DOC_846_R1 (p_at_id IN NUMBER, p_bild_doc NUMBER:= 1)
        RETURN BLOB
    IS
        C_NST   CONSTANT NUMBER := 402; --по цьому відбираємо потрібну послугу для документа

        CURSOR c_act IS
            SELECT a.at_org,
                   a.at_num,
                   a.At_action_start_dt,
                   a.At_action_stop_dt
              FROM act a
             WHERE a.at_id = p_at_id;

        c                c_act%ROWTYPE;

        CURSOR c_sng2 IS
              SELECT p.atp_ln || ' ' || p.atp_fn || ' ' || p.atp_mn     pib,
                     p.atp_id,
                     p.atp_phone                                        phone,
                     p.atp_live_address,
                     p.atp_fact_address,
                     SYSDATE                                 /*s.ati_sign_dt*/
                                                                        dt
                FROM uss_esr.at_signers s, uss_esr.at_person p
               WHERE     s.ati_at = p_at_id
                     AND s.history_status = 'A'
                     AND s.ati_tp = 'RC'
                     AND p.atp_sc = s.ati_sc
                     AND p.history_status = 'A'
            ORDER BY s.ati_order
               FETCH FIRST ROW ONLY;

        l_sng2           c_sng2%ROWTYPE;

        l_atp_O          NUMBER := get_AtPerson_id (p_at_id, 'OS'); --отримувач
        l_prs_O          R_Person_for_act := get_AtPerson (p_at_id, l_atp_O);

        l_str            VARCHAR2 (3200);

        l_jbr_id         NUMBER;
        l_result         BLOB;
    BEGIN
        IF p_bild_doc = 1
        THEN
            rdm$rtfl_univ.initreport (p_code     => 'ACT_IP_DOC_846_R1',
                                      p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);
        ELSE
            --костиль: якщо тільки план(p_bild_doc = 1), то бланк створюється в любому випадку, інакше тільки, якщо є дані
            AddDatasetIPGlobal (p_at_id, 'ds846_global');
        END IF;

        ------------------------------------
        OPEN c_act;

        FETCH c_act INTO c;

        CLOSE c_act;

        OPEN c_sng2;

        FETCH c_sng2 INTO l_sng2;

        CLOSE c_sng2;

        AddParam ('p846_1', l_prs_O.pib);
        AddParam ('p846_2', TO_CHAR (c.at_action_start_dt, 'dd.mm.yyyy'));
        AddParam ('p846_3', TO_CHAR (c.at_action_stop_dt, 'dd.mm.yyyy'));
        --Вид консультування
        l_str :=
            q'[
    select atip.atip_at,
           nvl(a.nsa_name, ATIP_NSA_HAND_NAME) as c1,
           atip.atip_place as c2,
           atip.atip_qnt||' '||Pr.Dic_Name as c3,
           (select listagg(s.atop_ln||' '||s.atop_fn||' '||s.atop_mn, Api$Act_Rpt.cnst_par) within group(order by s.atop_order, s.atop_ln)
              from uss_esr.at_other_spec s
             where s.atop_at = atip.atip_at and s.history_status = 'A'
               and s.atop_atip = atip.atip_id
           )                as c4,
           atip.atip_desc   AS c5

      from
           (select * from uss_ndi.v_ndi_service_type t where t.nst_code in ('002.0')) nst,
           uss_ndi.v_ndi_nst_activities a,
           uss_esr.At_individual_plan atip,
           Uss_Ndi.v_Ddn_Atip_Period Pr
     where atip.atip_nst = nst.nst_id
       and atip.atip_nsa = a.nsa_id(+)
       and atip.history_status = 'A'
       and Pr.Dic_Value(+)= atip.Atip_Period
       and atip.atip_at = :p_at_id
    order by atip_order, a.nsa_order
  ]';
        l_str :=
            REGEXP_REPLACE (l_str,
                            ':p_at_id',
                            p_at_id,
                            1,
                            0,
                            'i');
        rdm$rtfl_univ.AddDataset ('ds846_1', l_str);

        --Суб’єкти, залучені до надання соціальної послуги
        l_str :=
            q'[
    select distinct ip.atip_at at_id, s.atop_ln||' '||s.atop_fn||' '||s.atop_mn pib, s.atop_phone phone
      from uss_esr.v_at_other_spec s,
           uss_esr.v_At_individual_plan ip
     where ip.atip_at = :p_at_id and ip.atip_nst = :p_nst and ip.history_status = 'A'
       and s.atop_at = ip.atip_at and s.atop_tp IN ('OC', 'CCM', 'MC')
       and s.atop_atip = ip.atip_id
       and s.history_status = 'A'
  ]';
        l_str :=
            REGEXP_REPLACE (l_str,
                            ':p_at_id',
                            p_at_id,
                            1,
                            0,
                            'i');
        l_str :=
            REGEXP_REPLACE (l_str,
                            ':p_nst',
                            C_NST,
                            1,
                            0,
                            'i');

        rdm$rtfl_univ.AddDataset ('ds846', l_str);

        AddParam ('sgn846_1', Underline (l_sng2.pib, 1));
        AddParam ('sgn846_dt',
                  NVL (TO_CHAR (l_sng2.dt, 'dd.mm.yyyy'), c_date_empty));
        AddParam (
            'sgn_mark',
            get_sign_mark (p_at_id, l_sng2.atp_id, '_______________________'));

        ------------------------------------
        IF p_bild_doc = 1
        THEN
            rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                             p_rpt_blob   => l_result);
            replace_ekr (l_result);
        END IF;

        RETURN l_result;
    END;

    --#94480 ІНДИВІДУАЛЬНИЙ ПЛАН надання соціальної послуги натуральної допомоги
    FUNCTION ACT_IP_DOC_847_R1 (p_at_id IN NUMBER, p_bild_doc NUMBER:= 1)
        RETURN BLOB
    IS
        CURSOR c_act IS
            SELECT ikis_rbm.tools.GetCuPib (at_cu)    AS nad_pib,
                   (SELECT FIRST_VALUE (
                               t.atp_ln || ' ' || t.atp_fn || ' ' || t.atp_mn)
                               OVER (
                                   ORDER BY
                                       DECODE (t.atp_app_tp,
                                               'Z', 1,
                                               'OR', 2,
                                               'AF', 3,
                                               'AG', 4,
                                               'OS', 5,
                                               6))
                      FROM at_person t
                     WHERE t.atp_at = p_at_id AND t.history_status = 'A'
                     FETCH FIRST ROW ONLY)            AS otr_pib
              FROM act a
             WHERE a.at_id = p_at_id;

        c          c_act%ROWTYPE;

        CURSOR c_p IS
            SELECT atip.atip_id
              FROM At_individual_plan            atip,
                   uss_ndi.v_ndi_service_type    nst,
                   uss_ndi.v_ndi_nst_activities  nsa
             WHERE     atip.atip_at = p_at_id
                   AND atip.history_status = 'A'
                   AND nst.nst_code IN ('019.0')
                   AND nst.nst_id = atip.atip_nst
                   AND nsa.nsa_id = atip.atip_nsa;

        p          c_p%ROWTYPE;

        l_atp_O    NUMBER := get_AtPerson_id (p_at_id, 'OS');      --отримувач
        l_prs_O    R_Person_for_act := get_AtPerson (p_at_id, l_atp_O);

        l_str      VARCHAR2 (3200);

        l_jbr_id   NUMBER;
        l_result   BLOB;
    BEGIN
        IF p_bild_doc = 1
        THEN
            rdm$rtfl_univ.initreport (p_code     => 'ACT_IP_DOC_847_R1',
                                      p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);
        ELSE
            --костиль: якщо тільки план(p_bild_doc = 1), то бланк створюється в любому випадку, інакше тільки, якщо є дані
            AddDatasetIPGlobal (p_at_id, 'ds847_global');
        END IF;

        ------------------------------------
        OPEN c_act;

        FETCH c_act INTO c;

        CLOSE c_act;

        OPEN c_p;

        FETCH c_p INTO p;

        CLOSE c_p;

        AddParam ('847p1', l_prs_O.pib);
        AddParam ('847p2', Get_Ftr_Nt (p_at_id, p_nda => 8322));   --Категорія
        AddParam (
            '847p3',
            CASE
                WHEN l_prs_O.is_disordered = 'T' THEN 'Наявні'
                ELSE 'Відсутні'
            END);

        l_str :=
            q'[
    select atip.atip_at,
           nvl(a.nsa_name, ATIP_NSA_HAND_NAME) as c1,
           atip.atip_place as c2,
           atip.atip_resources as c3,
           atip.atip_qnt||' '||Pr.Dic_Name as c4,
           (select listagg( INITCAP(LOWER(s.atop_ln)) || ' ' || INITCAP(LOWER(s.atop_fn)) || ' ' || INITCAP(LOWER(s.atop_mn)), Api$Act_Rpt.cnst_par) within group(order by s.atop_order, s.atop_ln)
              from uss_esr.at_other_spec s where s.atop_at = atip.atip_at and s.history_status = 'A'
               and s.atop_atip = atip.atip_id
           )                as c5
      from
           (select * from uss_ndi.v_ndi_service_type t where t.nst_code in ('019.0')) nst,
           uss_ndi.v_ndi_nst_activities a,
           uss_esr.At_individual_plan atip,
           Uss_Ndi.v_Ddn_Atip_Period Pr
     where atip.atip_nst = nst.nst_id
       and atip.atip_nsa = a.nsa_id(+)
       and atip.history_status = 'A'
       and Pr.Dic_Value(+)= atip.Atip_Period
       and atip.atip_at = :p_at_id
    order by atip_order, a.nsa_order
  ]';
        l_str :=
            REGEXP_REPLACE (l_str,
                            ':p_at_id',
                            p_at_id,
                            1,
                            0,
                            'i');

        rdm$rtfl_univ.AddDataset ('ds847_1', l_str);

        AddParam ('847p4', Get_Ftr_Nt (p_At_Id => p_at_id, p_Nda => 8589) /*c.at_notes*/
                                                                         );

        AddParam ('nad_pib', UnderLine (c.nad_pib, 1));
        AddParam ('otr_pib', UnderLine (c.otr_pib, 1));

        ------------------------------------
        IF p_bild_doc = 1
        THEN
            rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                             p_rpt_blob   => l_result);
            replace_ekr (l_result);
        END IF;

        RETURN l_result;
    END;

    -- IC #94111
    -- 848 - Створення друкованої форми індивідуального плану для послуги 003.0 (Посередництво)
    FUNCTION ACT_IP_DOC_848_R1 (p_at_id IN NUMBER, p_bild_doc NUMBER:= 1)
        RETURN BLOB
    IS
        CURSOR c_act IS
            SELECT a.at_sc,
                   a.At_rnspm,
                   a.at_cu,
                   a.at_wu,
                   ap.ap_reg_dt
              FROM act a, appeal ap
             WHERE a.at_id = p_at_id AND ap.ap_id(+) = a.at_ap;

        c          c_act%ROWTYPE;

        p          Api$Act_Rpt.R_Person_for_act;                   --отримувач

        l_str      VARCHAR2 (3200);

        l_jbr_id   NUMBER;
        l_result   BLOB;
    BEGIN
        IF p_bild_doc = 1
        THEN
            rdm$rtfl_univ.initreport (p_code     => 'ACT_IP_DOC_848_R1',
                                      p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);
        ELSE
            --костиль: якщо тільки план(p_bild_doc = 1), то бланк створюється в любому випадку, інакше тільки, якщо є дані
            AddDatasetIPGlobal (p_at_id, 'ds848_global');
        END IF;

        ------------------------------------
        OPEN c_act;

        FETCH c_act INTO c;

        CLOSE c_act;

        p :=
            Api$Act_Rpt.get_AtPerson (p_at_id,
                                      get_AtPersonSc_id (p_at_id, c.at_sc));

        AddParam ('848p1', NVL (UnderLine (p.pib, 2), LPAD ('_', 49, '_')));
        AddParam (
            '848p2',
            NVL (
                UnderLine (
                    TO_CHAR (
                        TRUNC (MONTHS_BETWEEN (SYSDATE, p.birth_dt) / 12),
                        'FM990'),
                    2),
                '_____'));
        AddParam ('848p3', NVL (UnderLine (Gender (p.sex), 2), '_______'));
        AddParam (
            '848p4',
            NVL (
                UnderLine (
                       v_ddn ('uss_ndi.V_DDN_SS_MARITAL_SPCF',
                              Api$Act_Rpt.Get_Ftr (p_at_id, p_nda => 4041))
                    || ', '
                    || Api$Act_Rpt.Get_Ftr_Nt (p_at_id, p_nda => 4041),
                    2),
                '________'));                                  --Сімейний стан
        AddParam (
            '848p5',
            NVL (
                UnderLine (Api$Act_Rpt.Get_Ftr_Nt (p_at_id, p_nda => 4042), 2),
                '________'));                               --Мова спілкування
        AddParam (
            '848p6',
            NVL (
                UnderLine (
                       v_ddn ('uss_ndi.V_DDN_SCY_GROUP',
                              Get_Ftr (p_at_id, p_nda => 4043))
                    || ', '
                    || Api$Act_Rpt.Get_Ftr_Nt (p_at_id, p_nda => 4043),
                    2),
                '________'));                                   --Інвалідність
        AddParam ('848p7', UnderLine (Get_Ftr_Nt (p_at_id, p_nda => 4044), 1)); --Додаткова інформація
        AddParam (
            '848p8',
            NVL (UnderLine (TO_CHAR (c.ap_reg_dt, 'dd.mm.yyyy'), 2),
                 c_date_empty));                              --Дата звернення

        l_str :=
            q'[
    select nvl(a.nsa_name, atip_nsa_hand_name)  as c1,
           atip.atip_resources as c2,
           atip.atip_qnt||' '||Pr.Dic_Name as c3,
           (select listagg(s.atop_ln||' '||s.atop_fn||' '||s.atop_mn, Api$Act_Rpt.cnst_par) within group(order by s.atop_order, s.atop_ln)
              from uss_esr.at_other_spec s where s.atop_at = atip.atip_at and s.history_status = 'A'
               --and (s.atop_atip is null or s.atop_atip = atip.atip_id)
               and s.atop_atip = atip.atip_id
           )                as c4

      from uss_ndi.v_ndi_service_type nst
           left join uss_esr.At_individual_plan atip    on atip.atip_nst = nst.nst_id
                                                            and atip.history_status = 'A'
                                                            and atip.atip_at = :p_at_id
           left join uss_ndi.v_ndi_nst_activities a     on a.nsa_id = atip.atip_nsa
           left join Uss_Ndi.v_Ddn_Atip_Period Pr            on Pr.Dic_Value = atip.Atip_Period
      where nst.nst_code in ('003.0')
    order by atip_order, a.nsa_order
  ]';
        l_str :=
            REGEXP_REPLACE (l_str,
                            ':p_at_id',
                            p_at_id,
                            1,
                            0,
                            'i');
        rdm$rtfl_univ.AddDataset ('848ds2', l_str);

        AddParam (
            '848str1',
               Api$Act_Rpt.Get_Ftr_Nt (p_at_id, p_nda => 4045)
            || ', '
            || Api$Act_Rpt.Get_Ftr_Nt (p_at_id, p_nda => 8732)); --Моніторинг виконання індивідуального плану
        AddParam ('848str2',
                  Underline (Api$act.Get_At_Spec_Name (c.at_wu, c.at_cu), 1));
        AddParam ('848str3', Underline (p.pib, 1));
        AddParam ('sgn_mark', get_sign_mark (p_at_id, p.Atp_Id, ''));

        ------------------------------------
        IF p_bild_doc = 1
        THEN
            rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                             p_rpt_blob   => l_result);
            replace_ekr (l_result);
        END IF;

        RETURN l_result;
    END ACT_IP_DOC_848_R1;

    --#94143 План соц.супроводу сім'ї/особи у СЖО
    FUNCTION ACT_IP_DOC_857_R1 (p_at_id IN NUMBER, p_bild_doc NUMBER:= 1)
        RETURN BLOB
    IS
        CURSOR c_act IS
            SELECT a.at_sc,
                   a.at_dt,
                   a.at_ap,
                   a.At_rnspm,
                   a.at_cu,
                   a.at_wu,
                   a.At_case_class,
                   a.at_notes,
                   sc.sc_unique
              FROM act a, uss_person.v_socialcard sc
             WHERE a.at_id = p_at_id AND sc.sc_id = a.at_sc;

        c             c_act%ROWTYPE;

        p             Api$Act_Rpt.R_Person_for_act;                --отримувач

        p1            Api$Act_Rpt.R_Person_for_act;                   --батько
        p2            Api$Act_Rpt.R_Person_for_act;                     --мати
        p3            Api$Act_Rpt.R_Person_for_act;                   --дитина

        l_str         VARCHAR2 (32000);
        l_FM          BOOLEAN;               --ознака сім'ї(true)/особи(false)

        l_jbr_id      NUMBER;
        l_result      BLOB;
        l_sc_unique   VARCHAR2 (50);
    BEGIN
        IF p_bild_doc = 1
        THEN
            rdm$rtfl_univ.initreport (p_code     => 'ACT_IP_DOC_857_R1',
                                      p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);
        ELSE
            --костиль: якщо тільки план(p_bild_doc = 1), то бланк створюється в любому випадку, інакше тільки, якщо є дані
            AddDatasetIPGlobal (p_at_id, 'ds857_global');
        END IF;

        ------------------------------------
        OPEN c_act;

        FETCH c_act INTO c;

        CLOSE c_act;

        p :=
            Api$Act_Rpt.get_AtPerson (p_at_id,
                                      get_AtPersonSc_id (p_at_id, c.at_sc));
        l_FM := uss_esr.Api$act_Rpt.Get_Ap_Doc_Atr_Str (c.at_ap, 1895) = 'FM'; --ознака сім'ї

        /*--AT_CONCLUSION_TP='V1'- сім'я чи AT_CONCLUSION_TP='V2' -особа
       SELECT nvl(MAX(CASE t.at_conclusion_tp WHEN 'V2' THEN c.sc_unique END), '---')
          INTO l_sc_unique
          FROM uss_esr.act a,  uss_esr.act t
         WHERE a.at_id = p_at_id
           AND t.at_id = a.at_main_link
           AND t.at_tp = 'AVOP'
           AND t.at_st NOT IN ('VR', 'VD', 'VA');*/
        SELECT MAX (m)
          INTO l_sc_unique
          FROM (SELECT FIRST_VALUE (s.nsj_num)
                           OVER (
                               ORDER BY
                                   DECODE (pp.atp_app_tp,
                                           'Z', 1,
                                           'OS', 2,
                                           'FMS', 3,
                                           4))    AS m
                  FROM uss_esr.act  a
                       JOIN uss_esr.act t
                           ON (t.at_id = a.at_main_link AND t.at_tp = 'AVOP')
                       JOIN uss_esr.at_person pp
                           ON (    pp.atp_at = t.at_id
                               AND pp.atp_app_tp IN ('Z', 'OS', 'FMS'))
                       JOIN uss_esr.nsp_sc_journal s
                           ON (    s.nsj_rnspm = t.at_rnspm
                               AND s.nsj_sc = pp.atp_sc)
                 WHERE a.at_id = p_at_id
                 --AND t.at_st NOT IN ('VR', 'VD', 'VA')
                 FETCH FIRST ROW ONLY)-- AND (t.at_conclusion_tp = 'V2' OR t.at_conclusion_tp = 'V1' AND pp.atp_relation_tp = 'Z')
                                      ;

        --AddParam('857.1', CASE WHEN NOT l_FM THEN c.sc_unique ELSE '---' END); --Соціальна картка
        AddParam ('857.1', NVL (l_sc_unique, '---'));       --Соціальна картка

        /*--#100112 якщо у звернені сім’я, виводити лише прізвище заявника
        IF l_FM THEN
          l_str:= p.Ln;
        ELSE
          l_str:= p.pib;
        END IF;*/
        l_str := p.pib;                                              --#101291
        AddParam ('857.2', l_str);

        --Випадок Uss_Ndi.v_Ddn_Case_Class
        AddParam ('857.3-1', chk_val2 ('SM', c.at_case_class));
        AddParam ('857.3-2', chk_val2 ('MD', c.at_case_class));
        AddParam ('857.3-3', chk_val2 ('DF', c.at_case_class));
        AddParam ('857.3-4', chk_val2 ('EM', c.at_case_class));

        --Види послуг
        --AddNstAtService(p_at_id => p_at_id, p_param_nst =>'857nst');
        AddNstAtService2 (p_at_id, '857nst_all');

        --Основні цілі соціального супроводу сім’ї/особи, спрямованої на подолання СЖО*
        AddParam ('857t4.1', Get_Ftr_Chk2 (p_at_id, p_nda => 2546));
        AddParam ('857t4.2', Get_Ftr_Chk2 (p_at_id, p_nda => 2547));
        AddParam ('857t4.3', Get_Ftr_Chk2 (p_at_id, p_nda => 2548));
        AddParam ('857t4.4', Get_Ftr_Chk2 (p_at_id, p_nda => 2549));
        AddParam ('857t4.5', Get_Ftr_Chk2 (p_at_id, p_nda => 2552));
        AddParam ('857t4.6', Get_Ftr_Chk2 (p_at_id, p_nda => 2554));
        AddParam ('857t4.7', Get_Ftr_Chk2 (p_at_id, p_nda => 2555));
        AddParam ('857t4.8', Get_Ftr_Chk2 (p_at_id, p_nda => 2545));
        AddParam ('857t4.9', Get_Ftr_Chk2 (p_at_id, p_nda => 2550));
        AddParam ('857t4.10', Get_Ftr_Chk2 (p_at_id, p_nda => 2551));
        AddParam ('857t4.11', Get_Ftr_Chk2 (p_at_id, p_nda => 2553));
        AddParam ('857t4.12', Get_Ftr_Chk2 (p_at_id, p_nda => 2556));
        AddParam ('857t4.13', Get_Ftr_Chk2 (p_at_id, p_nda => 2557));
        AddParam ('857t4.14', Get_Ftr_Chk2 (p_at_id, p_nda => 2558));
        AddParam ('857t4.15', Get_Ftr_Chk2 (p_at_id, p_nda => 2559));
        AddParam ('857t4.16', Get_Ftr_Chk2 (p_at_id, p_nda => 2690));
        AddParam ('857t4.17', Get_Ftr_Chk2 (p_at_id, p_nda => 2691));
        AddParam ('857t4.18', Get_Ftr_Chk2 (p_at_id, p_nda => 2692));
        AddParam ('857t4.19', Get_Ftr_Chk2 (p_at_id, p_nda => 2693));
        AddParam ('857t4.20', Get_Ftr_Chk2 (p_at_id, p_nda => 2694));
        AddParam ('857t4.21', Get_Ftr_Chk2 (p_at_id, p_nda => 2695));
        AddParam ('857t4.22', Get_Ftr_Chk2 (p_at_id, p_nda => 2696));
        AddParam ('857t4.23', Get_Ftr_Chk2 (p_at_id, p_nda => 2697));
        AddParam ('857t4.24', Get_Ftr_Chk2 (p_at_id, p_nda => 2698));
        AddParam ('857t4.25', Get_Ftr_Chk2 (p_at_id, p_nda => 2699));
        AddParam ('857t4.26', Get_Ftr_Chk2 (p_at_id, p_nda => 2700));
        AddParam ('857t4.27', Get_Ftr_Chk2 (p_at_id, p_nda => 2701));
        AddParam ('857t4.28', Get_Ftr_Chk2 (p_at_id, p_nda => 2702));
        AddParam ('857t4.29', Get_Ftr_Chk2 (p_at_id, p_nda => 2703));
        AddParam ('857t4.30', Get_Ftr_Chk2 (p_at_id, p_nda => 2704));
        AddParam ('857t4.31', Get_Ftr_Chk2 (p_at_id, p_nda => 2705));
        AddParam ('857t4.32', Get_Ftr_Chk2 (p_at_id, p_nda => 2706));
        AddParam ('857t4.33', Get_Ftr_Chk2 (p_at_id, p_nda => 2707));
        AddParam ('857t4.34', Get_Ftr_Chk2 (p_at_id, p_nda => 2708));
        AddParam ('857t4.35', Get_Ftr_Chk2 (p_at_id, p_nda => 2709));
        AddParam ('857t4.36', Get_Ftr_Chk2 (p_at_id, p_nda => 2710));
        AddParam ('857t4.37', Get_Ftr_Chk2 (p_at_id, p_nda => 2711));
        AddParam ('857t4.38', Get_Ftr_Chk2 (p_at_id, p_nda => 2712));
        AddParam ('857t4.39', Get_Ftr_Chk2 (p_at_id, p_nda => 2713));
        AddParam ('857t4.40', Get_Ftr_Chk2 (p_at_id, p_nda => 2714));
        AddParam ('857t4.41', Get_Ftr_Chk2 (p_at_id, p_nda => 2715));
        AddParam ('857t4.42', Get_Ftr_Chk2 (p_at_id, p_nda => 2716));
        AddParam ('857t4.43-1', Get_Ftr_Chk2 (p_at_id, p_nda => 2717));
        AddParam ('857t4.43-2', Get_Ftr_Nt (p_at_id, p_nda => 2717));

        --1. Назва послуги...
        AddParam ('857.nst_subj', Get_Nsp_Name (p_rnspm_id => c.at_rnspm)); --надавач

        l_str := q'[
    select
           row_number() over(order by nst_order) as rn,
           t.*
      from
       (
        select distinct
               nst.nst_id, --ключве поле
               nst.nst_name as nst_name, nst.nst_order
          from
               uss_ndi.v_ndi_service_type nst,
               uss_ndi.v_ndi_nst_activities a,
               uss_esr.At_individual_plan atip
         where 1=1--nst.nst_code in ('007.0', '010.1')
           and atip.atip_nst = nst.nst_id
           and atip.atip_nsa = a.nsa_id(+)
           and atip.history_status = 'A'
           and atip.atip_at = :p_at_id
       ) t
     order by rn
  ]';
        l_str :=
            REGEXP_REPLACE (l_str,
                            ':p_at_id',
                            p_at_id,
                            1,
                            0,
                            'i');
        rdm$rtfl_univ.AddDataset ('857ds_all', l_str);

        l_str :=
            q'[
    select
           nst.nst_id, --ключве поле
           row_number() over(partition by nst.nst_id order by atip_order, a.nsa_order) as c1,
           atip.atip_exprections  as c2,
           case when a.nsa_id is null then atip.ATIP_NSA_HAND_NAME else a.nsa_name end as c3,
           Api$Act_Rpt.get_atip_term(atip.atip_id) as c4,   --строк
           (select listagg(s.atop_ln||' '||s.atop_fn||' '||s.atop_mn, ', '/*Api$Act_Rpt.cnst_par*/) within group(order by s.atop_order, s.atop_ln)
              from uss_esr.at_other_spec s where s.atop_at = atip.atip_at and s.history_status = 'A'
               and s.atop_atip = atip.atip_id
           )                      as c5,
           atip.atip_desc as c6
      from
           uss_ndi.v_ndi_service_type nst,
           uss_ndi.v_ndi_nst_activities a,
           uss_esr.At_individual_plan atip,
           Uss_Ndi.v_Ddn_Atip_Period Pr
     where atip.atip_nst = nst.nst_id
       and atip.atip_nsa = a.nsa_id(+)
       and atip.history_status = 'A'
       and Pr.Dic_Value(+)= atip.Atip_Period
       and atip.atip_at = :p_at_id
    order by atip_order, a.nsa_order
  ]';
        l_str :=
            REGEXP_REPLACE (l_str,
                            ':p_at_id',
                            p_at_id,
                            1,
                            0,
                            'i');
        rdm$rtfl_univ.AddDataset ('857ds_nst', l_str);

        rdm$rtfl_univ.AddRelation (Pmaster        => '857ds_all',
                                   Pmasterfield   => 'nst_id',
                                   Pdetail        => '857ds_nst',
                                   Pdetailfield   => 'nst_id');

        --Спеціалісти, залучені до реалізації плану
        l_str :=
            q'[
    select distinct s.atop_ln||' '||s.atop_fn||' '||s.atop_mn as c1,  --ПІБ
           s.atop_position as c2, --посада
           s.atop_phone    as c3, --телефон
           s.atop_notes    as c4
      from uss_esr.at_other_spec s
     where s.atop_at = :p_at_id
       --and s.atop_tp = 'OC' --#100112 в таблицю «Спеціалісти, залучені до реалізації плану» додавати і кейс-менеджера.
       and s.history_status = 'A'
       and s.atop_tp != 'Z'
     order by s.atop_ln||' '||s.atop_fn||' '||s.atop_mn
    ]';
        l_str :=
            REGEXP_REPLACE (l_str,
                            ':p_at_id',
                            p_at_id,
                            1,
                            0,
                            'i');
        rdm$rtfl_univ.AddDataset ('857ds3', l_str);

        --Я отримав(ла) план соціального супроводу
        --батько
        SELECT MAX (s.ate_atp)
          INTO p1.atp_id
          FROM uss_esr.at_section s
         WHERE s.ate_at = p_at_id AND s.ate_nng = 96;

        p1 := get_AtPerson (p_at_id, p1.atp_id); --get_at_signers_pers(p_at_id, p1.atp_id);

        AddParam ('857sgn1.1',
                  Get_Ftr_Chk2 (p_at_id, p_Atp => p1.Atp_Id, p_nda => 2718));
        AddParam ('857sgn1.2',
                  Get_Ftr_Chk2 (p_at_id,
                                p_Atp   => p1.Atp_Id,
                                p_nda   => 2718,
                                p_chk   => 'F'));
        AddParam ('857sgn1.3', p1.pib);
        AddParam ('sgn_1', get_sign_mark (p_at_id, p1.Atp_Id, ''));

        --#101291 без дат AddParam('857sgn1.4', to_char(get_at_signers(p_at_id, p1.atp_id).ati_sign_dt, 'dd.mm.yyyy'));
        --мати
        SELECT MAX (s.ate_atp)
          INTO p2.atp_id
          FROM uss_esr.at_section s
         WHERE s.ate_at = p_at_id AND s.ate_nng = 98;

        p2 := get_AtPerson (p_at_id, p2.atp_id); --get_at_signers_pers(p_at_id, p2.atp_id);

        AddParam ('857sgn2.1',
                  Get_Ftr_Chk2 (p_at_id, p_Atp => p2.Atp_Id, p_nda => 2719));
        AddParam ('857sgn2.2',
                  Get_Ftr_Chk2 (p_at_id,
                                p_Atp   => p2.Atp_Id,
                                p_nda   => 2719,
                                p_chk   => 'F'));
        AddParam ('857sgn2.3', p2.pib);
        AddParam ('sgn_2', get_sign_mark (p_at_id, p2.Atp_Id, ''));

        --#101291 без дат AddParam('857sgn2.4', to_char(get_at_signers(p_at_id, p2.atp_id).ati_sign_dt, 'dd.mm.yyyy'));
        --дитина
        SELECT MAX (s.ate_atp)
          INTO p3.atp_id
          FROM uss_esr.at_section s
         WHERE s.ate_at = p_at_id AND s.ate_nng = 99;

        p3 := get_AtPerson (p_at_id, p3.atp_id); --get_at_signers_pers(p_at_id, p3.atp_id);

        rdm$rtfl_univ.AddDataset (
            '857sgn3',
               'select * from dual where '''
            || Get_Ftr_Chk (p_At_Id => p_at_id, p_Nda => 8414)
            || ''' = ''T''  ');

        AddParam ('857sgn3.1',
                  Get_Ftr_Chk2 (p_at_id, p_Atp => p3.Atp_Id, p_nda => 2720));
        AddParam ('857sgn3.2',
                  Get_Ftr_Chk2 (p_at_id,
                                p_Atp   => p3.Atp_Id,
                                p_nda   => 2720,
                                p_chk   => 'F'));
        AddParam ('857sgn3.3', p3.pib);
        AddParam ('sgn_3', get_sign_mark (p_at_id, p3.Atp_Id, ''));
        AddParam (
            '857sgn3.5',
            CASE
                WHEN p3.atp_id IS NOT NULL
                THEN
                    CASE
                        WHEN Get_Ftr (p_At_Id => p_at_id, p_Nda => 8414) = 'T'
                        THEN
                            UnderLine ('дитина', 1) || '/особа'
                        ELSE
                            'дитина/' || UnderLine ('особа', 1)
                    END
                ELSE
                    'дитина/особа'
            END);
        --#101291 без дат AddParam('857sgn3.4', to_char(get_at_signers(p_at_id, p3.atp_id).ati_sign_dt, 'dd.mm.yyyy'));

        AddParam ('857.15', Get_Section_Notes (p_at_id, 935)); --c.at_notes); --Коментарі
        AddParam ('857sgn4', GetCuPIB (c.at_cu) /*Get_Other_Spec_Km(p_At_Id).Pib*/
                                               ); --GetCuPIB(c.at_cu)); --Фахівець, який здійснює соціальний супровід
        AddParam ('857.16', Date2Str (SYSDATE                      /*c.at_dt*/
                                             ));

        ------------------------------------
        IF p_bild_doc = 1
        THEN
            rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                             p_rpt_blob   => l_result);
            replace_ekr (l_result);
        END IF;

        RETURN l_result;
    END ACT_IP_DOC_857_R1;

    -- IC #94112
    -- 865 - Створення друкованої форми індивідуального плану для послуги 004.0 (Представництво інтересів)
    FUNCTION ACT_IP_DOC_865_R1 (p_at_id IN NUMBER, p_bild_doc NUMBER:= 1)
        RETURN BLOB
    IS
        CURSOR c_act IS
            SELECT a.at_sc,
                   a.At_rnspm,
                   a.at_dt,
                   a.at_cu,
                   a.at_wu,
                   ap.ap_reg_dt
              FROM act a, appeal ap
             WHERE a.at_id = p_at_id AND ap.ap_id(+) = a.at_ap;

        c          c_act%ROWTYPE;

        p          Api$Act_Rpt.R_Person_for_act;                   --отримувач

        l_str      VARCHAR2 (3200);

        l_jbr_id   NUMBER;
        l_result   BLOB;
    BEGIN
        IF p_bild_doc = 1
        THEN
            rdm$rtfl_univ.initreport (p_code     => 'ACT_IP_DOC_865_R1',
                                      p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);
        ELSE
            --костиль: якщо тільки план(p_bild_doc = 1), то бланк створюється в любому випадку, інакше тільки, якщо є дані
            AddDatasetIPGlobal (p_at_id, 'ds865_global');
        END IF;

        ------------------------------------
        OPEN c_act;

        FETCH c_act INTO c;

        CLOSE c_act;

        p :=
            Api$Act_Rpt.get_AtPerson (p_at_id,
                                      get_AtPersonSc_id (p_at_id, c.at_sc));

        AddParam ('865p1', NVL (p.pib, LPAD ('_', 49, '_')));
        AddParam ('865p2', TRUNC (MONTHS_BETWEEN (c.at_dt, p.birth_dt) / 12));
        AddParam ('865p3', NVL (Gender (p.sex), '________'));
        AddParam (
            '865p4',
            NVL (
                v_ddn ('uss_ndi.V_DDN_SS_MARITAL_SPCF',
                       Api$Act_Rpt.Get_Ftr (p_at_id, p_nda => 4046)),
                LPAD ('_', 19, '_')));                         --Сімейний стан
        AddParam ('865p5', Api$Act_Rpt.Get_Ftr_Nt (p_at_id, p_nda => 1671)); --Ступінь індивідуальної потреби
        AddParam ('865p6',
                  NVL (TO_CHAR (c.ap_reg_dt, 'dd.mm.yyyy'), c_date_empty)); --Дата звернення
        AddParam (
            '865p7',
            NVL (get_signers_wucu_pib (p_at_id => p_at_id, p_ati_tp => 'PR') /*Get_Nsp_Name(p_rnspm_id => c.At_rnspm)*/
                                                                            ,
                 LPAD ('_', 25, '_')));           --Надавач соціальної послуги
        AddParam (
            '865p8',
            NVL (Api$Act_Rpt.Get_Ftr_Nt (p_at_id, p_nda => 1672),
                 LPAD ('_', 21, '_')));   --Потреба в залученні інших фахівців

        l_str :=
            q'[
    select atip.atip_at,
           a.nsa_name       as c1,
           nvl(atip.atip_place, ' ')  as c2,
           atip.atip_resources as c3,
           atip.atip_qnt||' '||Pr.Dic_Name||' '||Api$Act_Rpt.get_atip_term(atip.atip_id) as c4,
           (select listagg(s.atop_ln||' '||s.atop_fn||' '||s.atop_mn, Api$Act_Rpt.cnst_par) within group(order by s.atop_order, s.atop_ln)
              from uss_esr.at_other_spec s where s.atop_at = atip.atip_at and s.history_status = 'A'
               --and (s.atop_atip is null or s.atop_atip = atip.atip_id)
               and s.atop_atip = atip.atip_id
           )                as c5

      from uss_ndi.v_ndi_service_type nst
           join uss_esr.At_individual_plan atip  on atip.atip_nst = nst.nst_id
                                                    and atip.history_status = 'A'
                                                    and atip.atip_at = :p_at_id
           left join uss_ndi.v_ndi_nst_activities a     on a.nsa_id = atip.atip_nsa
           left join Uss_Ndi.v_Ddn_Atip_Period Pr            on Pr.Dic_Value = atip.Atip_Period
      where nst.nst_code in ('004.0')
    order by atip_order, a.nsa_order]';

        l_str :=
            REGEXP_REPLACE (l_str,
                            ':p_at_id',
                            p_at_id,
                            1,
                            0,
                            'i');

        rdm$rtfl_univ.AddDataset ('865ds1', l_str);

        AddParam ('865str1', Api$Act_Rpt.Get_Ftr_Nt (p_at_id, p_nda => 4047)); --Моніторинг виконання індивідуального плану
        AddParam ('865str2', Api$act.Get_At_Spec_Name (c.at_wu, c.at_cu));
        AddParam ('865str3', p.pib);

        AddParam ('sgn_mark',
                  get_sign_mark (p_At_id, p.Atp_Id, '_________________'));

        ------------------------------------
        IF p_bild_doc = 1
        THEN
            rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                             p_rpt_blob   => l_result);
            replace_ekr (l_result);
        END IF;

        RETURN l_result;
    END ACT_IP_DOC_865_R1;

    --#94139 ІНДИВІДУАЛЬНИЙ ПЛАН надання соціальної послуги надання притулку бездомним особам
    FUNCTION ACT_IP_DOC_867_R1 (p_at_id IN NUMBER, p_bild_doc NUMBER:= 1)
        RETURN BLOB
    IS
        CURSOR c_act IS
            SELECT a.at_sc,
                   a.At_rnspm,
                   a.at_cu,
                   a.at_wu,
                   ap.ap_reg_dt
              FROM act a, appeal ap
             WHERE a.at_id = p_at_id AND ap.ap_id(+) = a.at_ap;

        c          c_act%ROWTYPE;

        CURSOR c_ip IS
            SELECT atip.atip_id
              FROM At_individual_plan            atip,
                   uss_ndi.v_ndi_service_type    nst,
                   uss_ndi.v_ndi_nst_activities  nsa
             WHERE     atip.atip_at = p_at_id
                   AND atip.history_status = 'A'
                   AND nst.nst_code IN ('005.0')
                   AND nst.nst_id = atip.atip_nst
                   AND nsa.nsa_id = atip.atip_nsa;

        ip         c_ip%ROWTYPE;

        p          R_Person_for_act;                               --отримувач

        l_str      VARCHAR2 (4000);

        l_jbr_id   NUMBER;
        l_result   BLOB;
    BEGIN
        IF p_bild_doc = 1
        THEN
            rdm$rtfl_univ.initreport (p_code     => 'ACT_IP_DOC_867_R1',
                                      p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);
        ELSE
            --костиль: якщо тільки план(p_bild_doc = 1), то бланк створюється в любому випадку, інакше тільки, якщо є дані
            AddDatasetIPGlobal (p_at_id, 'ds867_global');
        END IF;

        ------------------------------------
        OPEN c_act;

        FETCH c_act INTO c;

        CLOSE c_act;

        OPEN c_ip;

        FETCH c_ip INTO ip;

        CLOSE c_ip;

        p := get_AtPerson (p_at_id, get_AtPersonSc_id (p_at_id, c.at_sc));

        AddParam ('867p1', p.pib);
        AddParam (
            '867p2',
            Underline (TRUNC (MONTHS_BETWEEN (SYSDATE, p.birth_dt) / 12), 1));
        AddParam ('867p3', Underline (Gender (p.sex), 1));
        AddParam (
            '867p4',
            Underline (
                v_ddn ('uss_ndi.V_DDN_SS_MARITAL_SPCF',
                       Get_Ftr (p_at_id, p_nda => 1663)),
                1));                                           --Сімейний стан
        AddParam ('867p5', Underline (Get_Ftr_Nt (p_at_id, p_nda => 1671), 1)); --Ступінь індивідуальної потреби
        AddParam ('867p6', TO_CHAR (c.ap_reg_dt, 'dd.mm.yyyy')); --Дата звернення

        SELECT LISTAGG (
                   DISTINCT s.atop_ln || ' ' || s.atop_fn || ' ' || s.atop_mn,
                   ', '
                   ON OVERFLOW TRUNCATE '...')
               WITHIN GROUP (ORDER BY s.atop_ln)
          INTO l_str
          FROM uss_esr.at_other_spec s
         WHERE     s.atop_at = p_at_id
               AND s.atop_tp IN ('MC', 'CCM')
               AND s.History_Status = 'A';

        AddParam ('867p7', NVL (Underline (l_str /*Get_Nsp_Name(p_rnspm_id => c.At_rnspm)*/
                                                , 2), '-------')); --Надавач соціальної послуги
        AddParam ('867p8', Underline (Get_Ftr_Nt (p_at_id, p_nda => 1672), 1)); --Потреба в залученні інших фахівців

        l_str :=
            q'[
    select atip.atip_at,
           nst.nst_name     as c1,
           nvl(a.nsa_name, atip_nsa_hand_name) as c2,
           atip.atip_resources as c3,
           atip.atip_qnt||' '||Pr.Dic_Name||' '||Api$Act_Rpt.get_atip_term(atip.atip_id) as c4,
           (select listagg(s.atop_ln||' '||s.atop_fn||' '||s.atop_mn, Api$Act_Rpt.cnst_par) within group(order by s.atop_order, s.atop_ln)
              from uss_esr.at_other_spec s where s.atop_at = atip.atip_at and s.history_status = 'A'
               --and (s.atop_atip is null or s.atop_atip = atip.atip_id)
               and s.atop_atip = atip.atip_id
           )                as c5

      from
           (select * from uss_ndi.v_ndi_service_type t where t.nst_code in ('005.0')) nst,
           uss_ndi.v_ndi_nst_activities a,
           uss_esr.At_individual_plan atip,
           Uss_Ndi.v_Ddn_Atip_Period Pr
     where atip.atip_nst = nst.nst_id
       and atip.atip_nsa = a.nsa_id(+)
       and atip.history_status = 'A'
       and Pr.Dic_Value(+)= atip.Atip_Period
       and atip.atip_at = :p_at_id
    order by atip_order, a.nsa_order
  ]';
        l_str :=
            REGEXP_REPLACE (l_str,
                            ':p_at_id',
                            p_at_id,
                            1,
                            0,
                            'i');

        rdm$rtfl_univ.AddDataset ('867ds', l_str);

        AddParam ('867p9', Get_Ftr_Nt (p_at_id, p_nda => 1716)); --Моніторинг виконання індивідуального плану

        AddParam ('867sng1',
                  Underline (Api$act.Get_At_Spec_Name (c.at_wu, c.at_cu), 1));
        AddParam ('867sng2', Underline (p.pib, 1));
        AddParam ('sgn_mark', get_sign_mark (p_at_id, p.Atp_Id, ''));

        ------------------------------------
        IF p_bild_doc = 1
        THEN
            rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                             p_rpt_blob   => l_result);
            replace_ekr (l_result);
        END IF;

        RETURN l_result;
    END;

    -- #94333 ІНДИВІДУАЛЬНИЙ ПЛАН надання соціальної послуги стаціонарного догляду
    FUNCTION ACT_IP_DOC_870_R1 (p_at_id IN NUMBER, p_bild_doc NUMBER:= 1)
        RETURN BLOB
    IS
        CURSOR c_act IS
            SELECT a.at_sc,
                   a.at_dt,
                   a.At_rnspm,
                   a.at_cu,
                   a.at_wu,
                   ap.ap_reg_dt
              FROM act a, appeal ap
             WHERE a.at_id = p_at_id AND ap.ap_id(+) = a.at_ap;

        c          c_act%ROWTYPE;

        p          R_Person_for_act;                               --отримувач

        l_str      VARCHAR2 (3200);

        l_jbr_id   NUMBER;
        l_result   BLOB;
    BEGIN
        IF p_bild_doc = 1
        THEN
            rdm$rtfl_univ.initreport (p_code     => 'ACT_IP_DOC_870_R1',
                                      p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);
        ELSE
            --костиль: якщо тільки план(p_bild_doc = 1), то бланк створюється в любому випадку, інакше тільки, якщо є дані
            AddDatasetIPGlobal (p_at_id, 'ds.870_global');
        END IF;

        ------------------------------------
        OPEN c_act;

        FETCH c_act INTO c;

        CLOSE c_act;

        p := get_AtPerson (p_at_id, get_AtPersonSc_id (p_at_id, c.at_sc));

        AddParam ('870.pib', p.pib);
        AddParam ('870.age',
                  TRUNC (MONTHS_BETWEEN (SYSDATE, p.birth_dt) / 12));
        AddParam ('870.gender', Gender (p.sex));
        AddParam (
            '870.fam_st',
            v_ddn ('uss_ndi.V_DDN_SS_MARITAL_SPCF',
                   Get_Ftr (p_at_id, p_nda => 2791, p_nng => 108))); -- Сімейний стан
        AddParam ('870.language',
                  Get_Ftr_Nt (p_at_id, p_nda => 2792, p_nng => 108)); -- Мова спілкування
        AddParam ('870.invalid', p.Atp_Disable_Record); -- Інвалідність, група
        AddParam ('870.stupin',
                  Get_Ftr_Nt (p_at_id, p_nda => 2793, p_nng => 108)); -- Ступінь індивідуальної потреби в наданні соціальної послуги з паліативного догляду
        AddParam ('870.dod_info',
                  Get_Ftr_Nt (p_at_id, p_nda => 2794, p_nng => 108)); -- Додаткова інформація про отримувача соціальної послуги (за наявності)
        AddParam ('870.ap_reg_dt', TO_CHAR (c.ap_reg_dt, 'dd.mm.yyyy')); -- Дата звернення
        AddParam ('870.rnspm', Api$act.Get_At_Spec_Name (c.at_wu, c.at_cu)); -- Прізвище, ім’я, по батькові надавача соціальної послуги
        AddParam ('870.other_spec', GetOtherSpec (p_at_id, 'OC')); -- Інформація щодо необхідності в залученні додаткових фахівців
        AddParam ('870.monitoring',
                  Get_Ftr_Nt (p_at_id, p_nda => 2795, p_nng => 108)); -- Моніторинг / поточне оцінювання результатів, перегляд індивідуального плану (дата проведення, підпис)

        l_str :=
            q'[
    select a.nsa_name as c1,
           atip.atip_desc as c2,
           atip.atip_resources as c3,
           atip.atip_qnt||' '||Pr.Dic_Name||' '||Api$Act_Rpt.get_atip_term(atip.atip_id) as c4,
           (select listagg(s.atop_ln||' '||s.atop_fn||' '||s.atop_mn, Api$Act_Rpt.cnst_par) within group(order by s.atop_order, s.atop_ln)
              from uss_esr.at_other_spec s where s.atop_at = atip.atip_at and s.history_status = 'A'
               and s.atop_atip = atip.atip_id
           )                as c5

      from uss_esr.At_individual_plan atip
      join uss_ndi.v_ndi_nst_activities a on (a.nsa_id = atip.atip_nsa)
      left join Uss_Ndi.v_Ddn_Atip_Period Pr on (pr.dic_value = atip.atip_period)
     where atip.history_status = 'A'
       and atip.atip_at = :p_at_id
    order by atip_order, a.nsa_order
  ]';
        l_str :=
            REGEXP_REPLACE (l_str,
                            ':p_at_id',
                            p_at_id,
                            1,
                            0,
                            'i');

        rdm$rtfl_univ.AddDataset ('870.ds', l_str);

        ------------------------------------
        IF p_bild_doc = 1
        THEN
            rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                             p_rpt_blob   => l_result);
            replace_ekr (l_result);
        END IF;

        RETURN l_result;
    END ACT_IP_DOC_870_R1;

    --#94141 ІНДИВІДУАЛЬНИЙ ПЛАН соціального захисту дитини, яка опинилась у СЖО, дитини-сироти та дитини, позбавленої батьківського піклування
    FUNCTION ACT_IP_DOC_871_R1 (p_at_id IN NUMBER, p_bild_doc NUMBER:= 1)
        RETURN BLOB
    IS
        CURSOR c_act IS
            SELECT a.at_org,
                   a.at_num,
                   a.At_action_start_dt,
                   a.At_action_stop_dt,
                   a.at_live_address
              FROM act a
             WHERE a.at_id = p_at_id;

        c          c_act%ROWTYPE;

        CURSOR c_p IS
            SELECT atip.atip_id
              FROM At_individual_plan            atip,
                   uss_ndi.v_ndi_service_type    nst,
                   uss_ndi.v_ndi_nst_activities  nsa
             WHERE     atip.atip_at = p_at_id
                   AND atip.history_status = 'A'
                   AND nst.nst_code IN ('007.0', '010.2')
                   AND nst.nst_id = atip.atip_nst
                   AND nsa.nsa_id = atip.atip_nsa;

        p          c_p%ROWTYPE;

        l_atp_O    NUMBER := get_AtPerson_id (p_at_id, 'OS');      --отримувач
        l_prs_O    R_Person_for_act := get_AtPerson (p_at_id, l_atp_O);

        l_str      VARCHAR2 (3200);

        l_jbr_id   NUMBER;
        l_result   BLOB;
    BEGIN
        IF p_bild_doc = 1
        THEN
            rdm$rtfl_univ.initreport (p_code     => 'ACT_IP_DOC_871_R1',
                                      p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);
        ELSE
            --костиль: якщо тільки план(p_bild_doc = 1), то бланк створюється в любому випадку, інакше тільки, якщо є дані
            AddDatasetIPGlobal (p_at_id, 'ds871_global');
        END IF;

        ------------------------------------
        OPEN c_act;

        FETCH c_act INTO c;

        CLOSE c_act;

        OPEN c_p;

        FETCH c_p INTO p;

        CLOSE c_p;

        AddParam ('871p1', TO_CHAR (c.at_action_start_dt, 'dd.mm.yyyy'));
        AddParam ('871p2', TO_CHAR (c.at_action_stop_dt, 'dd.mm.yyyy'));
        AddParam ('871p3', l_prs_O.LN);
        AddParam ('871p4', l_prs_O.fn);
        AddParam ('871p5', l_prs_O.mn);
        AddParam ('871p6', l_prs_O.birth_dt_str);
        AddParam ('871p7',
                  TRUNC (MONTHS_BETWEEN (SYSDATE, l_prs_O.birth_dt) / 12));
        AddParam ('871p8', Get_Ftr_Nt (p_at_id, p_nda => 4457));    -- Область
        AddParam ('871p9', Get_Ftr_Nt (p_at_id, p_nda => 4458));       --Район
        AddParam ('871p10', Get_Ftr_Nt (p_at_id, p_nda => 4459));      --Місто
        AddParam ('871p11', c.at_live_address);

        l_str :=
            q'[
    select atip.atip_at at_id,
           nsg.nsag_name  as c1,
           atip.atip_desc as c2,
           a.nsa_name     as c3,
           Api$act.Get_At_Spec_Name(null, atip.atip_cu) as c4, --Виконавець
           (select listagg(s.atop_ln||' '||s.atop_fn||' '||s.atop_mn, Api$Act_Rpt.cnst_par) within group(order by s.atop_order, s.atop_ln)
              from uss_esr.at_other_spec s where s.atop_at = atip.atip_at and s.history_status = 'A'
               --and (s.atop_atip is null or s.atop_atip = atip.atip_id)
               and s.atop_atip = atip.atip_id
           ) c5, -- Залучений спеціаліст
           Api$Act_Rpt.get_atip_term(atip.atip_id) as c6,
           atip.atip_st     as c7

      from
           (select * from uss_ndi.v_ndi_service_type t where t.nst_code in ('007.0', '010.2')) nst,
           uss_ndi.v_Ndi_nsa_group nsg,
           uss_ndi.v_ndi_nst_activities a,
           uss_esr.At_individual_plan atip
     where nsg.nsag_nst = nst.nst_id
       and a.nsa_nsag = nsg.nsag_id
       and atip.atip_nsa = a.nsa_id(+)
       and atip.history_status = 'A'
       and atip.atip_at = :p_at_id
    order by nsg.nsag_order
  ]';
        l_str :=
            REGEXP_REPLACE (l_str,
                            ':p_at_id',
                            p_at_id,
                            1,
                            0,
                            'i');

        rdm$rtfl_univ.AddDataset ('871ds', l_str);


        --Перегляд індивідуального плану
        AddParam ('871p12',
                  NVL (Get_Ftr_Nt (p_at_id, p_nda => 4460), c_date_empty));
        AddParam ('871p13',
                  NVL (Get_Ftr_Nt (p_at_id, p_nda => 4461), c_date_empty));

        ------------------------------------
        IF p_bild_doc = 1
        THEN
            rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                             p_rpt_blob   => l_result);
            replace_ekr (l_result);
        END IF;

        RETURN l_result;
    END;

    -- #94144 Індивідуальний план надання соціальної послуги підтриманого проживання осіб
    --        похилого віку та осіб з інвалідністю
    FUNCTION ACT_IP_DOC_873_R1 (p_at_id IN NUMBER, p_bild_doc NUMBER:= 1)
        RETURN BLOB
    IS
        CURSOR c_act IS
            SELECT a.at_sc,
                   a.at_dt,
                   a.At_rnspm,
                   a.at_cu,
                   a.at_wu,
                   ap.ap_reg_dt
              FROM act a, appeal ap
             WHERE a.at_id = p_at_id AND ap.ap_id(+) = a.at_ap;

        c          c_act%ROWTYPE;

        p          R_Person_for_act;                               --отримувач

        l_str      VARCHAR2 (3200);

        l_jbr_id   NUMBER;
        l_result   BLOB;
    BEGIN
        IF p_bild_doc = 1
        THEN
            rdm$rtfl_univ.initreport (p_code     => 'ACT_IP_DOC_873_R1',
                                      p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);
        ELSE
            --костиль: якщо тільки план(p_bild_doc = 1), то бланк створюється в любому випадку, інакше тільки, якщо є дані
            AddDatasetIPGlobal (p_at_id, 'ds873_global');
        END IF;

        ------------------------------------
        OPEN c_act;

        FETCH c_act INTO c;

        CLOSE c_act;

        p := get_AtPerson (p_at_id, get_AtPersonSc_id (p_at_id, c.at_sc));

        AddParam ('873.pib', p.pib);
        AddParam ('873.age',
                  TRUNC (MONTHS_BETWEEN (SYSDATE, p.birth_dt) / 12));
        AddParam ('873.gender', Gender (p.sex));
        AddParam (
            '873.fam_tp',
            v_ddn ('uss_ndi.V_DDN_SS_MARITAL_SPCF',
                   Get_Ftr (p_at_id, p_nda => 4048, p_nng => 427))); -- Сімейний стан
        AddParam ('873.stupin',
                  Get_Ftr_Nt (p_at_id, p_nda => 4049, p_nng => 427)); -- ступінь індивідуальної потреби у наданні соціальної послуги
        AddParam ('873.ap_reg_dt', TO_CHAR (c.ap_reg_dt, 'dd.mm.yyyy')); --Дата звернення
        AddParam ('873.rnspm', Api$act.Get_At_Spec_Name (c.at_wu, c.at_cu)); -- Надавач соціальної послуги, відповідальний за організацію та надання соціальної послуги
        AddParam ('873.other_spec', GetOtherSpec (p_at_id, 'OC')); -- Потреба у залученні інших фахівців, підприємств, установ, організацій, закладів незалежно від форми власності
        AddParam ('873.monitoring',
                  Get_Ftr_Nt (p_at_id, p_nda => 4050, p_nng => 427)); -- Моніторинг виконання індивідуального плану/поточне оцінювання результатів, перегляд індивідуального плану (дата проведення, підпис)

        l_str :=
            q'[
    select case when rownum = 1 then 'Підтримане проживання' end as c1,
           t.*
      from (select a.nsa_name as c2,
                   atip.atip_resources as c3,
                   atip.atip_qnt||' '||Pr.Dic_Name||' '||Api$Act_Rpt.get_atip_term(atip.atip_id) as c4,
                   (select listagg(s.atop_ln||' '||s.atop_fn||' '||s.atop_mn, Api$Act_Rpt.cnst_par) within group(order by s.atop_order, s.atop_ln)
                      from uss_esr.at_other_spec s where s.atop_at = atip.atip_at and s.history_status = 'A'
                       and s.atop_atip = atip.atip_id
                   )                as c5

              from uss_esr.At_individual_plan atip
              join uss_ndi.v_ndi_nst_activities a on (a.nsa_id = atip.atip_nsa)
              left join Uss_Ndi.v_Ddn_Atip_Period Pr on (pr.dic_value = atip.atip_period)
             where atip.history_status = 'A'
               and atip.atip_at = :p_at_id
            order by atip_order, a.nsa_order
           ) t
  ]';
        l_str :=
            REGEXP_REPLACE (l_str,
                            ':p_at_id',
                            p_at_id,
                            1,
                            0,
                            'i');

        rdm$rtfl_univ.AddDataset ('873.ds', l_str);

        AddParam ('873.pib_sender',
                  Api$act.Get_At_Spec_Name (c.at_wu, c.at_cu));
        AddParam ('873.pib_receiver', p.pib);
        AddParam ('sgn_mark', get_sign_mark (p_at_id, p.Atp_Id, ''));

        ------------------------------------
        IF p_bild_doc = 1
        THEN
            rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                             p_rpt_blob   => l_result);
            replace_ekr (l_result);
        END IF;

        RETURN l_result;
    END ACT_IP_DOC_873_R1;

    -- #94145 Індивідуальний план надання соціальної послуги підтриманого проживання бездомних осіб
    FUNCTION ACT_IP_DOC_874_R1 (p_at_id IN NUMBER, p_bild_doc NUMBER:= 1)
        RETURN BLOB
    IS
        CURSOR c_act IS
            SELECT a.at_sc,
                   a.at_dt,
                   a.At_rnspm,
                   a.at_cu,
                   a.at_wu,
                   ap.ap_reg_dt,
                   uss_rnsp.api$find.Get_Nsp_Name (a.at_rnspm)    AS rnspm_name
              FROM act a, appeal ap
             WHERE a.at_id = p_at_id AND ap.ap_id(+) = a.at_ap;

        c          c_act%ROWTYPE;

        p          R_Person_for_act;                               --отримувач

        l_str      VARCHAR2 (3200);

        l_jbr_id   NUMBER;
        l_result   BLOB;
    BEGIN
        IF p_bild_doc = 1
        THEN
            rdm$rtfl_univ.initreport (p_code     => 'ACT_IP_DOC_874_R1',
                                      p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);
        ELSE
            --костиль: якщо тільки план(p_bild_doc = 1), то бланк створюється в любому випадку, інакше тільки, якщо є дані
            AddDatasetIPGlobal (p_at_id, 'ds.874_global');
        END IF;

        ------------------------------------
        OPEN c_act;

        FETCH c_act INTO c;

        CLOSE c_act;

        p := get_AtPerson (p_at_id, get_AtPersonSc_id (p_at_id, c.at_sc));

        AddParam ('874.pib', p.pib);
        AddParam ('874.age',
                  TRUNC (MONTHS_BETWEEN (SYSDATE, p.birth_dt) / 12));
        AddParam ('874.gender', Gender (p.sex));
        AddParam (
            '874.fam_st',
               v_ddn ('uss_ndi.V_DDN_SS_MARITAL_SPCF',
                      Get_Ftr (p_at_id, p_nda => 2782))
            || ', '
            || Get_Ftr_Nt (p_at_id, p_nda => 2782));          -- Сімейний стан
        AddParam ('874.stupin',
                  Get_Ftr_Nt (p_at_id, p_nda => 2783, p_nng => 100)); -- Ступінь індивідуальної потреби у наданні соціальної послуги
        AddParam ('874.ap_reg_dt', TO_CHAR (c.ap_reg_dt, 'dd.mm.yyyy')); --Дата звернення
        AddParam ('874.rnspm', c.rnspm_name /*Api$act.Get_At_Spec_Name(c.at_wu, c.at_cu)*/
                                           );    -- Надавач соціальної послуги
        AddParam ('874.other_spec', GetOtherSpec (p_at_id, 'OC', 1)); -- Потреба в залученні інших фахівців
        AddParam ('874.monitoring',
                  Get_Ftr_Nt (p_at_id, p_nda => 2784, p_nng => 100)); -- Моніторинг виконання індивідуального плану/поточне оцінювання результатів, перегляд індивідуального плану (дата проведення, підпис)

        l_str :=
            q'[
    select case when rownum = 1 then 'Підтримане проживання' end as c1,
           t.*
      from (select nvl(a.nsa_name, ATIP_NSA_HAND_NAME) as c2,
                   atip.atip_resources as c3,
                   atip.atip_qnt||' '||Pr.Dic_Name||' '||Api$Act_Rpt.get_atip_term(atip.atip_id) as c4,
                   (select listagg(s.atop_ln||' '||s.atop_fn||' '||s.atop_mn, Api$Act_Rpt.cnst_par) within group(order by s.atop_order, s.atop_ln)
                      from uss_esr.at_other_spec s where s.atop_at = atip.atip_at and s.history_status = 'A'
                       and s.atop_atip = atip.atip_id
                   )                as c5

              from uss_esr.At_individual_plan atip
              left join uss_ndi.v_ndi_nst_activities a on (a.nsa_id = atip.atip_nsa)
              left join Uss_Ndi.v_Ddn_Atip_Period Pr on (pr.dic_value = atip.atip_period)
             where atip.history_status = 'A'
               and atip.atip_at = :p_at_id
            order by atip_order, a.nsa_order
           ) t
  ]';
        l_str :=
            REGEXP_REPLACE (l_str,
                            ':p_at_id',
                            p_at_id,
                            1,
                            0,
                            'i');

        rdm$rtfl_univ.AddDataset ('874.ds', l_str);

        AddParam ('874.pib_sender',
                  Api$act.Get_At_Spec_Name (c.at_wu, c.at_cu));
        AddParam ('874.pib_receiver', p.pib);
        AddParam ('sgn_mark',
                  get_sign_mark (p_at_id, p.Atp_Id, '__________________'));

        ------------------------------------
        IF p_bild_doc = 1
        THEN
            rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                             p_rpt_blob   => l_result);
            replace_ekr (l_result);
        END IF;

        RETURN l_result;
    END ACT_IP_DOC_874_R1;

    -- IC #94329
    -- 876 - Створення друкованої форми «План соціального супроводження прийомної сім'ї, дитячого будинку сімейного типу» для послуги 010.2
    FUNCTION ACT_IP_DOC_876_R1 (p_at_id IN NUMBER, p_bild_doc NUMBER:= 1)
        RETURN BLOB
    IS
        --план під документ ACT_DOC_875_R1
        p_d_pib    VARCHAR2 (30) := LPAD ('_', 30, '_');

        CURSOR c_act IS
            SELECT a.at_sc,
                   a.at_dt,
                   a.at_ap,
                   a.At_rnspm,
                   a.at_cu,
                   a.at_wu,
                   ap.ap_reg_dt,
                   (SELECT MIN (atc_start_dt)
                      FROM at_calendar c
                     WHERE atc_at = a.at_id)    AS start_dt,
                   (SELECT MAX (atc_stop_dt)
                      FROM at_calendar c
                     WHERE atc_at = a.at_id)    AS stop_dt
              FROM act a, appeal ap
             WHERE a.at_id = p_at_id AND ap.ap_id(+) = a.at_ap;

        c          c_act%ROWTYPE;

        --p   Api$Act_Rpt.R_Person_for_act; --дитина
        p1         Api$Act_Rpt.R_Person_for_act;                      --батько
        p2         Api$Act_Rpt.R_Person_for_act;                        --мвти

        l_str      VARCHAR2 (3200);
        l_cnt      NUMBER;

        l_jbr_id   NUMBER;
        l_result   BLOB;
    BEGIN
        IF p_bild_doc = 1
        THEN
            rdm$rtfl_univ.initreport (p_code     => 'ACT_IP_DOC_876_R1',
                                      p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);
        ELSE
            --костиль: якщо тільки план(p_bild_doc = 1), то бланк створюється в любому випадку, інакше тільки, якщо є дані
            AddDatasetIPGlobal (p_at_id, 'ds876_global');
        END IF;

        ------------------------------------
        OPEN c_act;

        FETCH c_act INTO c;

        CLOSE c_act;

        --p := Api$Act_Rpt.get_AtPerson(p_at_id, get_AtPersonSc_id(p_at_id, c.at_sc));
        p1 :=
            Api$Act_Rpt.get_AtPerson (
                p_at_id,
                Get_Father_Mother (p_at_id => p_at_id, p_tp => 1));
        p2 :=
            Api$Act_Rpt.get_AtPerson (
                p_at_id,
                Get_Father_Mother (p_at_id => p_at_id, p_tp => 2));

        -- ПЛАН на період
        AddParam ('876p1',
                  NVL (Date2Str (c.start_dt), c_date_empty) || ' р.');     -- з
        AddParam ('876p2', NVL (Date2Str (c.stop_dt), c_date_empty) || ' р.');  -- по

        l_str := q'[
    select
           row_number() over(order by atip_order, a.nsa_order) as c1,
           atip.atip_desc         as c2,
           a.nsa_name             as c3,
           Api$Act_Rpt.get_atip_term(atip.atip_id) as c4,   --строк
           atip.atip_exprections  as c5 --Результат
      from
           uss_ndi.v_ndi_service_type nst,
           uss_ndi.v_ndi_nst_activities a,
           uss_esr.At_individual_plan atip,
           Uss_Ndi.v_Ddn_Atip_Period Pr
     where atip.atip_nst = nst.nst_id
       and atip.atip_nsa = a.nsa_id(+)
       and atip.history_status = 'A'
       and Pr.Dic_Value(+)= atip.Atip_Period
       and atip.atip_at = :p_at_id
    order by atip_order, a.nsa_order
   ]';

        l_str :=
            REGEXP_REPLACE (l_str,
                            ':p_at_id',
                            p_at_id,
                            1,
                            0,
                            'i');
        rdm$rtfl_univ.AddDataset ('876ds1', l_str);

        l_str := q'[
  select 1 from dual where 1=2
  ]';

        rdm$rtfl_univ.AddDataset ('876ds2', l_str);

        AddParam ('876p3',
                  NVL (Api$act.Get_At_Spec_Name (c.at_wu, c.at_cu), p_d_pib)); -- Підготував
        AddParam ('876p33', Date2Str (c.at_dt));            -- Підготував дата

        AddParam ('876p4', NVL (p1.pib, p_d_pib)); -- Прийомний батько/батько-вихователь
        AddParam ('876p5', NVL (p2.pib, p_d_pib)); -- Прийомна мати/мати-вихователька
        AddParam ('876p6',
                  NVL (Get_Ftr_Nt (p_at_id, p_nda => 5855), c_date_empty)); -- Дата наступного перегляду плану соціального супроводження
        AddParam ('876p7',
                  NVL (Get_Ftr_Nt (p_at_id, p_nda => 5856), c_date_empty)); -- Дата коригування плану соціального супроводження

        AddParam ('sgn_mark_1', get_sign_mark (p_at_id, p1.Atp_Id, ''));
        AddParam ('sgn_mark_2', get_sign_mark (p_at_id, p2.Atp_Id, ''));

        SELECT CASE
                   WHEN NVL (Get_Ftr (p_At_Id => p_at_id, p_Nda => 5856),
                             Get_Ftr_Nt (p_At_Id => p_at_id, p_Nda => 5856))
                            IS NOT NULL
                   THEN
                       1
                   ELSE
                       0
               END
          INTO l_cnt
          FROM DUAL;

        IF (l_cnt = 1)
        THEN
            AddParam ('sgn_mark_1.2', get_sign_mark (p_at_id, p1.Atp_Id, ''));
            AddParam ('sgn_mark_2.2', get_sign_mark (p_at_id, p2.Atp_Id, ''));
        END IF;

        ------------------------------------
        IF p_bild_doc = 1
        THEN
            rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                             p_rpt_blob   => l_result);
            replace_ekr (l_result);
        END IF;

        RETURN l_result;
    END ACT_IP_DOC_876_R1;

    -- #94330 Індивідуальний план надання соціальної послуги соціального супроводу при працевлаштуванні та на робочому місці
    FUNCTION ACT_IP_DOC_878_R1 (p_at_id IN NUMBER, p_bild_doc NUMBER:= 1)
        RETURN BLOB
    IS
        CURSOR c_act IS
            SELECT a.at_sc,
                   a.at_dt,
                   a.At_rnspm,
                   a.at_cu,
                   a.at_wu,
                   ap.ap_reg_dt
              FROM act a, appeal ap
             WHERE a.at_id = p_at_id AND ap.ap_id(+) = a.at_ap;

        c          c_act%ROWTYPE;

        p          R_Person_for_act;                               --отримувач

        l_str      VARCHAR2 (3200);

        l_jbr_id   NUMBER;
        l_result   BLOB;
    BEGIN
        IF p_bild_doc = 1
        THEN
            rdm$rtfl_univ.initreport (p_code     => 'ACT_IP_DOC_878_R1',
                                      p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);
        ELSE
            --костиль: якщо тільки план(p_bild_doc = 1), то бланк створюється в любому випадку, інакше тільки, якщо є дані
            AddDatasetIPGlobal (p_at_id, 'ds.878_global');
        END IF;

        ------------------------------------
        OPEN c_act;

        FETCH c_act INTO c;

        CLOSE c_act;

        p := get_AtPerson (p_at_id, get_AtPersonSc_id (p_at_id, c.at_sc));

        AddParam ('878.pib', p.pib);
        AddParam ('878.age',
                  TRUNC (MONTHS_BETWEEN (SYSDATE, p.birth_dt) / 12));
        AddParam ('878.gender', Gender (p.sex));
        AddParam (
            '878.fam_st',
            v_ddn ('uss_ndi.V_DDN_SS_MARITAL_SPCF',
                   Get_Ftr (p_at_id, p_nda => 2785, p_nng => 101))); -- Сімейний стан
        AddParam ('878.prof',
                  Get_Ftr_Nt (p_at_id, p_nda => 2786, p_nng => 101)); -- Професія / спеціальність
        AddParam ('878.education',
                  Get_Ftr_Nt (p_at_id, p_nda => 2787, p_nng => 101)); -- Освіта
        AddParam ('878.invalid', p.Atp_Disable_Record); -- Інвалідність, група
        AddParam ('878.potreba',
                  Get_Ftr_Nt (p_at_id, p_nda => 2788, p_nng => 101)); -- Індивідуальні потреби у наданні соціальної послуги
        AddParam ('878.dod_info',
                  Get_Ftr_Nt (p_at_id, p_nda => 2789, p_nng => 101)); -- Додаткова інформація про отримувача соціальної послуги
        AddParam ('878.ap_reg_dt', TO_CHAR (c.ap_reg_dt, 'dd.mm.yyyy')); -- Дата звернення
        AddParam ('878.rnspm', Api$act.Get_At_Spec_Name (c.at_wu, c.at_cu)); -- Прізвище, ім’я, по батькові надавача соціальної послуги
        AddParam ('878.other_spec', GetOtherSpec (p_at_id, 'OC')); -- Інформація щодо необхідності в залученні додаткових фахівців
        AddParam ('878.monitoring',
                  Get_Ftr_Nt (p_at_id, p_nda => 2790, p_nng => 101)); -- Моніторинг / поточне оцінювання результатів, перегляд індивідуального плану (дата проведення, підпис)

        l_str :=
            q'[
    select to_char(atc_start_dt, 'DD.MM.YYYY') || ' ' || to_char(atc_stop_dt, 'DD.MM.YYYY') as c1,
           case when nsa_can_ind = 'T' then 'Індивідуальне' when nsa_can_group = 'T' then 'Групове' end as c2,
           a.nsa_name as c3,
           nvl(to_char(hs.hs_dt, 'DD.MM.YYYY'), atc_km_notes) as c4,
           null as c5,
           r.atr_result as c6,
           null as c7,
           atip_desc as c8
      from uss_esr.At_individual_plan atip
      join uss_ndi.v_ndi_nst_activities a on (a.nsa_id = atip.atip_nsa)
      join uss_esr.v_at_calendar c on (c.atc_atip = atip_id)
      left join uss_esr.v_histsession hs on (hs.hs_id = atc_hs_km_ok)
      left join uss_esr.v_at_results r on (r.atr_atip = atip_id)
     where atip.history_status = 'A'
       and c.history_status = 'A'
       and atip.atip_at = :p_at_id
    order by atip_order, a.nsa_order
  ]';
        l_str :=
            REGEXP_REPLACE (l_str,
                            ':p_at_id',
                            p_at_id,
                            1,
                            0,
                            'i');

        rdm$rtfl_univ.AddDataset ('878.ds', l_str);
        AddParam (
            'sgn_mark',
            api$act_rpt.get_sign_mark (p_at_id,
                                       p.atp_id,
                                       '____________________'));

        ------------------------------------
        IF p_bild_doc = 1
        THEN
            rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                             p_rpt_blob   => l_result);
            replace_ekr (l_result);
        END IF;

        RETURN l_result;
    END ACT_IP_DOC_878_R1;

    -- #94331 ІНДИВІДУАЛЬНИЙ ПЛАН надання соціальної послуги соціальної адаптації
    FUNCTION ACT_IP_DOC_883_R1 (p_at_id IN NUMBER, p_bild_doc NUMBER:= 1)
        RETURN BLOB
    IS
        CURSOR c_act IS
            SELECT a.at_sc,
                   a.at_dt,
                   a.At_rnspm,
                   a.at_cu,
                   a.at_wu,
                   ap.ap_reg_dt
              FROM act a, appeal ap
             WHERE a.at_id = p_at_id AND ap.ap_id(+) = a.at_ap;

        c          c_act%ROWTYPE;

        p          R_Person_for_act;                               --отримувач

        l_str      VARCHAR2 (4000);

        l_jbr_id   NUMBER;
        l_result   BLOB;
    BEGIN
        IF p_bild_doc = 1
        THEN
            rdm$rtfl_univ.initreport (p_code     => 'ACT_IP_DOC_883_R1',
                                      p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);
        ELSE
            --костиль: якщо тільки план(p_bild_doc = 1), то бланк створюється в любому випадку, інакше тільки, якщо є дані
            AddDatasetIPGlobal (p_at_id, 'ds883_global');
        END IF;

        ------------------------------------
        OPEN c_act;

        FETCH c_act INTO c;

        CLOSE c_act;

        p := get_AtPerson (p_at_id, get_AtPersonSc_id (p_at_id, c.at_sc));

        AddParam ('883.pib', p.pib);
        AddParam (
            '883.old',
            Underline (
                TRUNC (MONTHS_BETWEEN (SYSDATE, p.birth_dt) / 12) || ' p.',
                1));
        AddParam (
            '883.gender',
            Underline (NVL (Gender (p.sex), get_gender_sc (p.Atp_Sc)), 1));
        AddParam (
            '883.fam_tp',
            Underline (
                   v_ddn ('uss_ndi.V_DDN_SS_MARITAL_STT',
                          Get_Ftr (p_at_id, p_nda => 5562, p_nng => 388))
                || ' '
                || Get_Ftr_Nt (p_at_id, p_nda => 5562, p_nng => 388),
                1));                                          -- Сімейний стан
        AddParam (
            '883.spec',
            NVL (
                Underline (Get_Ftr_Nt (p_at_id, p_nda => 5563, p_nng => 388),
                           2),
                '-------'));                         -- Професія/спеціальність
        AddParam ('883.inv',
                  NVL (Underline (p.atp_disable_record, 2), '-------')); -- Інвалідність, група
        AddParam (
            '883.potreba',
            Underline (Get_Ftr_Nt (p_at_id, p_nda => 5564, p_nng => 388), 1)); -- Індивідуальні потреби у наданні соціальної послуги
        AddParam (
            '883.dodat',
            NVL (
                Underline (Get_Ftr_Nt (p_at_id, p_nda => 5565, p_nng => 388),
                           2),
                '-------')); -- Додаткова інформація про отримувача соціальної послуги
        AddParam ('883.ap_reg_dt', TO_CHAR (c.ap_reg_dt, 'dd.mm.yyyy')); --Дата звернення

        SELECT LISTAGG (
                   DISTINCT s.atop_ln || ' ' || s.atop_fn || ' ' || s.atop_mn,
                   ', '
                   ON OVERFLOW TRUNCATE '...')
               WITHIN GROUP (ORDER BY s.atop_ln)
          INTO l_str
          FROM uss_esr.at_other_spec s
         WHERE     s.atop_at = p_at_id
               AND s.atop_tp IN ('MC', 'CCM')
               AND s.History_Status = 'A';

        AddParam ('883.other_spec_m', NVL (Underline (l_str /*Api$act.Get_At_Spec_Name(c.at_wu, c.at_cu)*/
                                                           , 2), '-------')); -- Надавач соціальної послуги
        AddParam (
            '883.other_spec_o',
            NVL (Underline (GetOtherSpecDist (p_at_id, 'OC'), 2), '-------')); -- Потреба в залученні інших фахівців
        AddParam (
            '883.monitoring',
            Underline (Get_Ftr_Nt (p_at_id, p_nda => 5566, p_nng => 388), 1)); -- Моніторинг виконання індивідуального плану/поточне оцінювання результатів, перегляд індивідуального плану (дата проведення, підпис)

        l_str :=
            q'[
    select
           atip.atip_exprections as c1,
           nvl(a.nsa_name, atip_nsa_hand_name ) as c2,
           atip.atip_resources as c3,
           atip.atip_qnt||' '||Pr.Dic_Name||' '||Api$Act_Rpt.get_atip_term(atip.atip_id) as c4,
           (select listagg(s.atop_ln||' '||s.atop_fn||' '||s.atop_mn, Api$Act_Rpt.cnst_par) within group(order by s.atop_order, s.atop_ln)
              from uss_esr.at_other_spec s where s.atop_at = atip.atip_at and s.history_status = 'A'
               and s.atop_atip = atip.atip_id
           )                as c5

      from uss_esr.At_individual_plan atip
      left join uss_ndi.v_ndi_nst_activities a on (a.nsa_id = atip.atip_nsa)
      left join Uss_Ndi.v_Ddn_Atip_Period Pr on (pr.dic_value = atip.atip_period)
     where atip.history_status = 'A'
       and atip.atip_at = :p_at_id
    order by atip_order, a.nsa_order
  ]';
        l_str :=
            REGEXP_REPLACE (l_str,
                            ':p_at_id',
                            p_at_id,
                            1,
                            0,
                            'i');

        rdm$rtfl_univ.AddDataset ('883.ds', l_str);

        AddParam ('883.pib_sender',
                  UnderLine (Api$act.Get_At_Spec_Name (c.at_wu, c.at_cu), 1));
        AddParam ('883.pib_receiver', UnderLine (p.pib, 1));

        AddParam ('sgn_mark',
                  api$act_rpt.get_sign_mark (p_at_id, p.Atp_Id, ''));

        ------------------------------------
        IF p_bild_doc = 1
        THEN
            rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                             p_rpt_blob   => l_result);
            replace_ekr (l_result);
        END IF;

        RETURN l_result;
    END ACT_IP_DOC_883_R1;

    -- #94078 ІНДИВІДУАЛЬНИЙ ПЛАН надання соціальної послуги догляду та виховання дітей в умовах, наближених до сімейних
    FUNCTION ACT_IP_DOC_884_R1 (p_at_id IN NUMBER, p_bild_doc NUMBER:= 1)
        RETURN BLOB
    IS
        CURSOR c_act IS
            SELECT a.at_sc,
                   a.at_dt,
                   a.At_rnspm,
                   a.at_cu,
                   a.at_wu,
                   ap.ap_reg_dt
              FROM act a, appeal ap
             WHERE a.at_id = p_at_id AND ap.ap_id(+) = a.at_ap;

        c          c_act%ROWTYPE;

        p          R_Person_for_act;                               --отримувач

        l_str      VARCHAR2 (3200);

        l_jbr_id   NUMBER;
        l_result   BLOB;
    BEGIN
        IF p_bild_doc = 1
        THEN
            rdm$rtfl_univ.initreport (p_code     => 'ACT_IP_DOC_884_R1',
                                      p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);
        ELSE
            --костиль: якщо тільки план(p_bild_doc = 1), то бланк створюється в любому випадку, інакше тільки, якщо є дані
            AddDatasetIPGlobal (p_at_id, 'ds884_global');
        END IF;

        ------------------------------------
        OPEN c_act;

        FETCH c_act INTO c;

        CLOSE c_act;

        p := get_AtPerson (p_at_id, get_AtPersonSc_id (p_at_id, c.at_sc));

        AddParam ('884.pib', p.pib);
        AddParam ('884.age',
                  TRUNC (MONTHS_BETWEEN (SYSDATE, p.birth_dt) / 12));
        AddParam ('884.gender', Gender (p.sex));
        AddParam ('884.at_dt', TO_CHAR (c.at_dt, 'DD.MM.YYYY'));
        AddParam ('884.monitoring',
                  Get_Ftr_Nt (p_at_id, p_nda => 4054, p_nng => 429)); -- Моніторинг виконання індивідуального плану/поточне оцінювання результатів, перегляд індивідуального плану (дата проведення, підпис)

        l_str :=
            q'[
    select a.nsa_name as c1,
           atip.atip_exprections as c2,
           atip.atip_resources as c3,
           atip.atip_qnt||' '||Pr.Dic_Name||' '||Api$Act_Rpt.get_atip_term(atip.atip_id) as c4,
           atip.atip_desc as c5
      from uss_esr.At_individual_plan atip
      join uss_ndi.v_ndi_nst_activities a on (a.nsa_id = atip.atip_nsa)
      left join Uss_Ndi.v_Ddn_Atip_Period Pr on (pr.dic_value = atip.atip_period)
     where atip.history_status = 'A'
       and atip.atip_at = :p_at_id
    order by atip_order, a.nsa_order
  ]';
        l_str :=
            REGEXP_REPLACE (l_str,
                            ':p_at_id',
                            p_at_id,
                            1,
                            0,
                            'i');

        rdm$rtfl_univ.AddDataset ('884.ds', l_str);

        AddParam ('884.pib_sender',
                  Api$act.Get_At_Spec_Name (c.at_wu, c.at_cu));
        AddParam (
            '884.pib_predstavnuk',
               Get_Ftr_Nt (p_at_id, p_nda => 4055, p_nng => 429)
            || ' '
            || Get_Ftr_Nt (p_at_id, p_nda => 4056, p_nng => 429)
            || ' '
            || Get_Ftr_Nt (p_at_id, p_nda => 4057, p_nng => 429));

        ------------------------------------
        IF p_bild_doc = 1
        THEN
            rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                             p_rpt_blob   => l_result);
            replace_ekr (l_result);
        END IF;

        RETURN l_result;
    END ACT_IP_DOC_884_R1;

    -- #94334 ІНДИВІДУАЛЬНИЙ ПЛАН надання соціальної послуги денного догляду
    FUNCTION ACT_IP_DOC_892_R1 (p_at_id IN NUMBER, p_bild_doc NUMBER:= 1)
        RETURN BLOB
    IS
        CURSOR c_act IS
            SELECT a.at_sc,
                   a.at_dt,
                   a.At_rnspm,
                   a.at_cu,
                   a.at_wu,
                   ap.ap_reg_dt,
                   ikis_rbm.tools.GetCuPib (a.at_cu)    cu_pib,
                   (SELECT FIRST_VALUE (
                               t.atp_ln || ' ' || t.atp_fn || ' ' || t.atp_mn)
                               OVER (
                                   ORDER BY
                                       DECODE (t.atp_app_tp,
                                               'Z', 1,
                                               'OR', 2,
                                               'AF', 3,
                                               'AG', 4,
                                               'OS', 5,
                                               6))
                      FROM at_person t
                     WHERE t.atp_at = p_at_id AND t.history_status = 'A'
                     FETCH FIRST ROW ONLY)              AS otr_pib
              FROM act a, appeal ap
             WHERE a.at_id = p_at_id AND ap.ap_id(+) = a.at_ap;

        c          c_act%ROWTYPE;

        p          R_Person_for_act;                               --отримувач

        l_str      VARCHAR2 (3200);

        l_jbr_id   NUMBER;
        l_result   BLOB;
    BEGIN
        IF p_bild_doc = 1
        THEN
            rdm$rtfl_univ.initreport (p_code     => 'ACT_IP_DOC_892_R1',
                                      p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);
        ELSE
            --костиль: якщо тільки план(p_bild_doc = 1), то бланк створюється в любому випадку, інакше тільки, якщо є дані
            AddDatasetIPGlobal (p_at_id, 'ds.892_global');
        END IF;

        ------------------------------------
        OPEN c_act;

        FETCH c_act INTO c;

        CLOSE c_act;

        p := get_AtPerson (p_at_id, get_AtPersonSc_id (p_at_id, c.at_sc));

        AddParam ('892.pib', Underline (p.pib, 1));
        AddParam (
            '892.age',
            Underline (TRUNC (MONTHS_BETWEEN (SYSDATE, p.birth_dt) / 12), 1));
        AddParam (
            '892.gender',
            Underline (NVL (Gender (p.sex), get_gender_sc (p.Atp_Sc)), 1));
        AddParam (
            '892.fam_st',
            Underline (
                   v_ddn ('uss_ndi.V_DDN_SS_MARITAL_SPCF',
                          Get_Ftr (p_at_id, p_nda => 2796, p_nng => 66))
                || ', '
                || Get_Ftr_Nt (p_at_id, p_nda => 2796, p_nng => 66),
                1));                                          -- Сімейний стан
        AddParam (
            '892.language',
            Underline (Get_Ftr_Nt (p_at_id, p_nda => 2797, p_nng => 66), 1)); -- Мова спілкування
        AddParam (
            '892.invalid',
            CASE
                WHEN p.Is_Disabled = 'T'
                THEN
                    Underline ('так ' || p.Atp_Disable_Record, 1)
                ELSE
                    '-------'
            END);                                       -- Інвалідність, група

        AddParam (
            '892.stupin',
            Underline (Get_Ftr_Nt (p_at_id, p_nda => 2798, p_nng => 66), 1)); -- Ступінь індивідуальної потреби в наданні соціальної послуги з паліативного догляду
        AddParam (
            '892.dod_info',
            Underline (Get_Ftr_Nt (p_at_id, p_nda => 2799, p_nng => 66), 1)); -- Додаткова інформація про отримувача соціальної послуги (за наявності)
        AddParam ('892.ap_reg_dt',
                  Underline (TO_CHAR (c.ap_reg_dt, 'dd.mm.yyyy'), 1)); -- Дата звернення

        SELECT LISTAGG (
                   DISTINCT s.atop_ln || ' ' || s.atop_fn || ' ' || s.atop_mn,
                   ', '
                   ON OVERFLOW TRUNCATE '...')
               WITHIN GROUP (ORDER BY s.atop_ln)
          INTO l_str
          FROM uss_esr.at_other_spec s
         WHERE     s.atop_at = p_at_id
               AND s.atop_tp IN ('MC', 'CCM')
               AND s.History_Status = 'A';

        AddParam ('892.rnspm', NVL (Underline (l_str /*Get_Nsp_Name(p_rnspm_id => c.At_rnspm)*/
                                                    , 2), '-------')); -- Прізвище, ім’я, по батькові надавача соціальної послуги

        SELECT LISTAGG (
                   DISTINCT s.atop_ln || ' ' || s.atop_fn || ' ' || s.atop_mn,
                   ', '
                   ON OVERFLOW TRUNCATE '...')
               WITHIN GROUP (ORDER BY s.atop_ln)
          INTO l_str
          FROM uss_esr.at_other_spec s
         WHERE     s.atop_at = p_at_id
               AND s.atop_tp IN ('OC')
               AND s.History_Status = 'A';

        AddParam ('892.other_info', NVL (Underline (l_str, 2), '-------') /*GetOtherSpec(p_at_id, 'OC')*/
                                                                         ); -- Інформація щодо необхідності в залученні додаткових фахівців
        AddParam ('892.monitoring',
                  Get_Ftr_Nt (p_at_id, p_nda => 2800, p_nng => 66)); -- Моніторинг / поточне оцінювання результатів, перегляд індивідуального плану (дата проведення, підпис)

        l_str :=
            q'[
    select case when rownum = 1 then 'Денний догляд' end as c1,
           t.*
      from (select nvl(a.nsa_name, atip_nsa_hand_name) as c2,
                   atip.atip_resources as c3,
                   atip.atip_qnt||' '||Pr.Dic_Name||' '||Api$Act_Rpt.get_atip_term(atip.atip_id) as c4,
                   (select listagg(s.atop_ln||' '||s.atop_fn||' '||s.atop_mn, Api$Act_Rpt.cnst_par) within group(order by s.atop_order, s.atop_ln)
                      from uss_esr.at_other_spec s where s.atop_at = atip.atip_at and s.history_status = 'A'
                       and s.atop_atip = atip.atip_id
                   )                as c5

              from uss_esr.At_individual_plan atip
              left join uss_ndi.v_ndi_nst_activities a on (a.nsa_id = atip.atip_nsa)
              left join Uss_Ndi.v_Ddn_Atip_Period Pr on (pr.dic_value = atip.atip_period)
             where atip.history_status = 'A'
               and atip.atip_at = :p_at_id
            order by atip_order, a.nsa_order
           ) t
  ]';
        l_str :=
            REGEXP_REPLACE (l_str,
                            ':p_at_id',
                            p_at_id,
                            1,
                            0,
                            'i');

        rdm$rtfl_univ.AddDataset ('892.ds', l_str);

        AddParam ('sgn_mark',
                  api$act_rpt.get_sign_mark (p_at_id, p.Atp_Id, ''));
        AddParam ('sgn_n', c.cu_pib);
        AddParam ('sgn_o', c.otr_pib);

        ------------------------------------
        IF p_bild_doc = 1
        THEN
            rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                             p_rpt_blob   => l_result);
            replace_ekr (l_result);
        END IF;

        RETURN l_result;
    END ACT_IP_DOC_892_R1;

    --#94998  017.3-893-Інд.план надання СП Соц.-психолог. реабілітація наркотики_психотропи
    FUNCTION ACT_IP_DOC_893_R1 (p_at_id IN NUMBER, p_bild_doc NUMBER:= 1)
        RETURN BLOB
    IS
        CURSOR c_act IS
            SELECT a.at_sc,
                   a.at_dt,
                   a.At_rnspm,
                   a.at_cu,
                   a.at_wu,
                   ap.ap_reg_dt
              FROM act a, appeal ap
             WHERE a.at_id = p_at_id AND ap.ap_id(+) = a.at_ap;

        c          c_act%ROWTYPE;

        p          R_Person_for_act;                               --отримувач

        l_str      VARCHAR2 (3200);

        l_jbr_id   NUMBER;
        l_result   BLOB;

        --для заповнення таблиці 2:
        --p_tp=1-Частота вживання
        --p_tp=2-Спосіб вживання
        --p_tp=3-Алкогольні напої/Частота вживання
        PROCEDURE AddFtrT2 (p_tp               INTEGER,
                            p_Param_Name_lst   VARCHAR2,
                            p_nda              NUMBER)
        IS
            l_ftr              at_section_feature.atef_feature%TYPE;

            l_Param_Name_lst   VARCHAR2 (1000);
            l_val_lst          VARCHAR2 (1000); --значення довідника для кожної колонки таблиці 2
            Result             VARCHAR2 (1000);
        BEGIN
            l_Param_Name_lst :=
                   CHR (39)
                || REPLACE (p_Param_Name_lst,
                            ',',
                            CHR (39) || ',' || CHR (39))
                || CHR (39);
            l_ftr := Get_Ftr (p_at_id => p_at_id, p_nda => p_nda); --значення фічі

            CASE p_tp
                WHEN 1
                THEN                                        --Частота вживання
                    l_val_lst := '';
                WHEN 2
                THEN                                         --Спосіб вживання
                    l_val_lst := '';
                WHEN 3
                THEN                       --Алкогольні напої/Частота вживання
                    l_val_lst := '';
                WHEN 4
                THEN                        --Алкогольні напої/Спосіб вживання
                    l_val_lst := '';
                ELSE
                    Raise_application_error (
                        -20000,
                        'ACT_IP_DOC_893_R1/AddFtrT2(): невірний тип p_tp');
            END CASE;

            FOR c
                IN (SELECT Param_Name, val
                      FROM (SELECT ROWNUM                                   rn,
                                   CAST (COLUMN_VALUE AS VARCHAR2 (100))    Param_Name
                              FROM XMLTABLE (l_Param_Name_lst)) t1,
                           (SELECT ROWNUM                                   rn,
                                   CAST (COLUMN_VALUE AS VARCHAR2 (100))    val
                              FROM XMLTABLE (l_val_lst)
                             WHERE l_val_lst IS NOT NULL) t2
                     WHERE t2.rn(+) = t1.rn)
            LOOP
                IF l_ftr = c.val
                THEN                                          --ставлю галочку
                    Result := org2ekr (c_chk);
                ELSE
                    Result := org2ekr (c_unchk);
                END IF;

                AddParam (c.Param_Name, Result);
            END LOOP;
        END AddFtrT2;

        FUNCTION AddFtrT2IsNotNull (p_nda NUMBER)
            RETURN VARCHAR2
        IS
            l_res   at_section_feature.atef_feature%TYPE;
        BEGIN
            l_res := Get_Ftr (p_at_id => p_at_id, p_nda => p_nda);

            IF l_res IS NOT NULL
            THEN
                RETURN org2ekr (c_chk);
            ELSE
                RETURN org2ekr (c_unchk);
            END IF;
        END;
    BEGIN
        IF p_bild_doc = 1
        THEN
            rdm$rtfl_univ.initreport (p_code     => 'ACT_IP_DOC_893_R1',
                                      p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);
        ELSE
            --костиль: якщо тільки план(p_bild_doc = 1), то бланк створюється в любому випадку, інакше тільки, якщо є дані
            AddDatasetIPGlobal (p_at_id, 'ds893_global');
        END IF;

        ------------------------------------
        OPEN c_act;

        FETCH c_act INTO c;

        CLOSE c_act;

        p := get_AtPerson (p_at_id, get_AtPersonSc_id (p_at_id, c.at_sc));

        --I. Загальні відомості про отримувача соціальної послуги
        AddParam (
            '893.1',
            NVL (Get_Ftr (p_at_id, p_nda => 7285),
                 TO_CHAR (c.at_dt, 'dd.mm.yyyy')));          --дата заповнення
        AddParam ('893.2', p.pib || ' ' || p.Birth_Dt_Str);
        AddParam ('893.4-1', Get_Ftr_Chk2 (p_at_id, p_nda => 7286)); --повнолітня особа
        AddParam ('893.4-2',
                  chk_val2 (NVL (Get_Ftr (p_at_id, p_nda => 7286), 'F'), 'F'));
        AddParam ('893.5', p.Live_Address || ' ' || p.Phone);
        AddParam (
            '893.6',
            v_ddn ('uss_ndi.V_DDN_SCY_GROUP',
                   Get_Ftr (p_at_id, p_nda => 7287)));          --Інвалідність
        AddParam ('893.7', Get_Ftr (p_at_id, p_nda => 7288)); --хронічне захворювання
        AddParam ('893.8', Get_Ftr (p_at_id, p_nda => 7393)); --додаткова інформація
        AddParam (
            '893.9',
            v_ddn ('uss_ndi.V_DDN_SS_MARITAL_SPCF',
                   Get_Ftr (p_at_id, p_nda => 7289)));         --Сімейний стан
        AddParam ('893.10', Get_Ftr (p_at_id, p_nda => 7290)); --наявність дитини
        AddParam ('893.11', Get_Ftr (p_at_id, p_nda => 7291));        --освіта
        AddParam ('893.12', Get_Ftr (p_at_id, p_nda => 7292));
        AddParam ('893.13', Get_Ftr (p_at_id, p_nda => 7293));
        AddParam ('893.14', Get_Ftr (p_at_id, p_nda => 7294));
        AddParam ('893.15', Get_Ftr (p_at_id, p_nda => 7295));
        AddParam ('893.16', Get_Ftr (p_at_id, p_nda => 7296));
        AddParam ('893.17', Get_Ftr (p_at_id, p_nda => 7297));
        AddParam ('893.18', Get_Ftr (p_at_id, p_nda => 7298));
        AddParam ('893.19', Get_Ftr (p_at_id, p_nda => 7299));
        AddParam ('893.20', Get_Ftr (p_at_id, p_nda => 7300));

        --ІІ. Загальні відомості щодо вживання
        --Наркотичні засоби та їх аналоги
        --Частота вживання                                                        --Спосіб вживання
        AddFtrT2 (1, '893s1.1.1,893s1.1.2,893s1.1.3,893s1.1.4', p_nda => 7301);
        AddFtrT2 (2, '893s1.1.5,893s1.1.6,893s1.1.7,893s1.1.8', p_nda => 7302);
        AddFtrT2 (1, '893s1.2.1,893s1.2.2,893s1.2.3,893s1.2.4', p_nda => 7303);
        AddFtrT2 (2, '893s1.2.5,893s1.2.6,893s1.2.7,893s1.2.8', p_nda => 7304);
        AddFtrT2 (1, '893s1.3.1,893s1.3.2,893s1.3.3,893s1.3.4', p_nda => 7305);
        AddFtrT2 (2, '893s1.3.5,893s1.3.6,893s1.3.7,893s1.3.8', p_nda => 7306);
        AddFtrT2 (1, '893s1.4.1,893s1.4.2,893s1.4.3,893s1.4.4', p_nda => 7307);
        AddFtrT2 (2, '893s1.4.5,893s1.4.6,893s1.4.7,893s1.4.8', p_nda => 7308);
        AddFtrT2 (1, '893s1.5.1,893s1.5.2,893s1.5.3,893s1.5.4', p_nda => 7309);
        AddFtrT2 (2, '893s1.5.5,893s1.5.6,893s1.5.7,893s1.5.8', p_nda => 7310);
        AddFtrT2 (1, '893s1.6.1,893s1.6.2,893s1.6.3,893s1.6.4', p_nda => 7311);
        AddFtrT2 (2, '893s1.6.5,893s1.6.6,893s1.6.7,893s1.6.8', p_nda => 7312);
        AddFtrT2 (1, '893s1.7.1,893s1.7.2,893s1.7.3,893s1.7.4', p_nda => 7313);
        AddFtrT2 (2, '893s1.7.5,893s1.7.6,893s1.7.7,893s1.7.8', p_nda => 7314);
        AddFtrT2 (1, '893s1.8.1,893s1.8.2,893s1.8.3,893s1.8.4', p_nda => 7315);
        AddFtrT2 (2, '893s1.8.5,893s1.8.6,893s1.8.7,893s1.8.8', p_nda => 7316);
        AddFtrT2 (1, '893s1.9.1,893s1.9.2,893s1.9.3,893s1.9.4', p_nda => 7317);
        AddFtrT2 (2, '893s1.9.5,893s1.9.6,893s1.9.7,893s1.9.8', p_nda => 7318);
        AddFtrT2 (1,
                  '893s1.10.1,893s1.10.2,893s1.10.3,893s1.10.4',
                  p_nda   => 7319);
        AddFtrT2 (2,
                  '893s1.10.5,893s1.10.6,893s1.10.7,893s1.10.8',
                  p_nda   => 7320);
        AddFtrT2 (1,
                  '893s1.11.1,893s1.11.2,893s1.11.3,893s1.11.4',
                  p_nda   => 7321);
        AddFtrT2 (2,
                  '893s1.11.5,893s1.11.6,893s1.11.7,893s1.11.8',
                  p_nda   => 7322);
        AddFtrT2 (1,
                  '893s1.12.1,893s1.12.2,893s1.12.3,893s1.12.4',
                  p_nda   => 7323);
        AddFtrT2 (2,
                  '893s1.12.5,893s1.12.6,893s1.12.7,893s1.12.8',
                  p_nda   => 7324);
        AddFtrT2 (1,
                  '893s1.13.1,893s1.13.2,893s1.13.3,893s1.13.4',
                  p_nda   => 7325);
        AddFtrT2 (2,
                  '893s1.13.5,893s1.13.6,893s1.13.7,893s1.13.8',
                  p_nda   => 7326);
        AddFtrT2 (1,
                  '893s1.14.1,893s1.14.2,893s1.14.3,893s1.14.4',
                  p_nda   => 7327);
        AddFtrT2 (2,
                  '893s1.14.5,893s1.14.6,893s1.14.7,893s1.14.8',
                  p_nda   => 7328);
        AddFtrT2 (1,
                  '893s1.15.1,893s1.15.2,893s1.15.3,893s1.15.4',
                  p_nda   => 7329);
        AddFtrT2 (2,
                  '893s1.15.5,893s1.15.6,893s1.15.7,893s1.15.8',
                  p_nda   => 7330);
        AddFtrT2 (1,
                  '893s1.16.1,893s1.16.2,893s1.16.3,893s1.16.4',
                  p_nda   => 7331);
        AddFtrT2 (2,
                  '893s1.16.5,893s1.16.6,893s1.16.7,893s1.16.8',
                  p_nda   => 7332);
        AddFtrT2 (1,
                  '893s1.17.1,893s1.17.2,893s1.17.3,893s1.17.4',
                  p_nda   => 7333);
        AddFtrT2 (2,
                  '893s1.17.5,893s1.17.6,893s1.17.7,893s1.17.8',
                  p_nda   => 7334);
        AddFtrT2 (1,
                  '893s1.18.1,893s1.18.2,893s1.18.3,893s1.18.4',
                  p_nda   => 7335);
        AddFtrT2 (2,
                  '893s1.18.5,893s1.18.6,893s1.18.7,893s1.18.8',
                  p_nda   => 7336);
        AddFtrT2 (1,
                  '893s1.19.1,893s1.19.2,893s1.19.3,893s1.19.4',
                  p_nda   => 7337);
        AddFtrT2 (2,
                  '893s1.19.5,893s1.19.6,893s1.19.7,893s1.19.8',
                  p_nda   => 7338);
        AddFtrT2 (1,
                  '893s1.20.1,893s1.20.2,893s1.20.3,893s1.20.4',
                  p_nda   => 7339);
        AddFtrT2 (2,
                  '893s1.20.5,893s1.20.6,893s1.20.7,893s1.20.8',
                  p_nda   => 7340);
        AddFtrT2 (1,
                  '893s1.21.1,893s1.21.2,893s1.21.3,893s1.21.4',
                  p_nda   => 7341);
        AddFtrT2 (2,
                  '893s1.21.5,893s1.21.6,893s1.21.7,893s1.21.8',
                  p_nda   => 7342);
        AddFtrT2 (1,
                  '893s1.22.1,893s1.22.2,893s1.22.3,893s1.22.4',
                  p_nda   => 7343);
        AddFtrT2 (2,
                  '893s1.22.5,893s1.22.6,893s1.22.7,893s1.22.8',
                  p_nda   => 7344);
        AddFtrT2 (1,
                  '893s1.23.1,893s1.23.2,893s1.23.3,893s1.23.4',
                  p_nda   => 7345);
        AddFtrT2 (2,
                  '893s1.23.5,893s1.23.6,893s1.23.7,893s1.23.8',
                  p_nda   => 7346);
        AddFtrT2 (1,
                  '893s1.24.1,893s1.24.2,893s1.24.3,893s1.24.4',
                  p_nda   => 7347);
        AddFtrT2 (2,
                  '893s1.24.5,893s1.24.6,893s1.24.7,893s1.24.8',
                  p_nda   => 7348);
        AddFtrT2 (1,
                  '893s1.25.1,893s1.25.2,893s1.25.3,893s1.25.4',
                  p_nda   => 7349);
        AddFtrT2 (2,
                  '893s1.25.5,893s1.25.6,893s1.25.7,893s1.25.8',
                  p_nda   => 7350);
        AddFtrT2 (1,
                  '893s1.26.1,893s1.26.2,893s1.26.3,893s1.26.4',
                  p_nda   => 7351);
        AddFtrT2 (2,
                  '893s1.26.5,893s1.26.6,893s1.26.7,893s1.26.8',
                  p_nda   => 7352);
        AddFtrT2 (1,
                  '893s1.27.1,893s1.27.2,893s1.27.3,893s1.27.4',
                  p_nda   => 7353);
        AddFtrT2 (2,
                  '893s1.27.5,893s1.27.6,893s1.27.7,893s1.27.8',
                  p_nda   => 7354);
        AddFtrT2 (1,
                  '893s1.28.1,893s1.28.2,893s1.28.3,893s1.28.4',
                  p_nda   => 7355);
        AddFtrT2 (2,
                  '893s1.28.5,893s1.28.6,893s1.28.7,893s1.28.8',
                  p_nda   => 7356);
        --Психотропні речовини та їх аналоги
        AddFtrT2 (1, '893s2.1.1,893s2.1.2,893s2.1.3,893s2.1.4', p_nda => 7357);
        AddFtrT2 (2, '893s2.1.5,893s2.1.6,893s2.1.7,893s2.1.8', p_nda => 7358);
        AddFtrT2 (1, '893s2.2.1,893s2.2.2,893s2.2.3,893s2.2.4', p_nda => 7359);
        AddFtrT2 (2, '893s2.2.5,893s2.2.6,893s2.2.7,893s2.2.8', p_nda => 7360);
        AddFtrT2 (1, '893s2.3.1,893s2.3.2,893s2.3.3,893s2.3.4', p_nda => 7361);
        AddFtrT2 (2, '893s2.3.5,893s2.3.6,893s2.3.7,893s2.3.8', p_nda => 7362);
        AddFtrT2 (1, '893s2.4.1,893s2.4.2,893s2.4.3,893s2.4.4', p_nda => 7363);
        AddFtrT2 (2, '893s2.4.5,893s2.4.6,893s2.4.7,893s2.4.8', p_nda => 7364);
        AddFtrT2 (1, '893s2.5.1,893s2.5.2,893s2.5.3,893s2.5.4', p_nda => 7365);
        AddFtrT2 (2, '893s2.5.5,893s2.5.6,893s2.5.7,893s2.5.8', p_nda => 7366);
        AddFtrT2 (1, '893s2.6.1,893s2.6.2,893s2.6.3,893s2.6.4', p_nda => 7367);
        AddFtrT2 (2, '893s2.6.5,893s2.6.6,893s2.6.7,893s2.6.8', p_nda => 7368);
        AddFtrT2 (1, '893s2.7.1,893s2.7.2,893s2.7.3,893s2.7.4', p_nda => 7369);
        AddFtrT2 (2, '893s2.7.5,893s2.7.6,893s2.7.7,893s2.7.8', p_nda => 7370);
        AddFtrT2 (1, '893s2.8.1,893s2.8.2,893s2.8.3,893s2.8.4', p_nda => 7371);
        AddFtrT2 (2, '893s2.8.5,893s2.8.6,893s2.8.7,893s2.8.8', p_nda => 7372);
        AddFtrT2 (1, '893s2.9.1,893s2.9.2,893s2.9.3,893s2.9.4', p_nda => 7373);
        AddFtrT2 (2, '893s2.9.5,893s2.9.6,893s2.9.7,893s2.9.8', p_nda => 7374);
        AddFtrT2 (1,
                  '893s2.10.1,893s2.10.2,893s2.10.3,893s2.10.4',
                  p_nda   => 7375);
        AddFtrT2 (2,
                  '893s2.10.5,893s2.10.6,893s2.10.7,893s2.10.8',
                  p_nda   => 7376);
        AddFtrT2 (1,
                  '893s2.11.1,893s2.11.2,893s2.11.3,893s2.11.4',
                  p_nda   => 7377);
        AddFtrT2 (2,
                  '893s2.11.5,893s2.11.6,893s2.11.7,893s2.11.8',
                  p_nda   => 7378);
        AddFtrT2 (1,
                  '893s2.12.1,893s2.12.2,893s2.12.3,893s2.12.4',
                  p_nda   => 7379);
        AddFtrT2 (2,
                  '893s2.12.5,893s2.12.6,893s2.12.7,893s2.12.8',
                  p_nda   => 7380);
        AddFtrT2 (1,
                  '893s2.13.1,893s2.13.2,893s2.13.3,893s2.13.4',
                  p_nda   => 7381);
        AddFtrT2 (2,
                  '893s2.13.5,893s2.13.6,893s2.13.7,893s2.13.8',
                  p_nda   => 7382);
        AddFtrT2 (1,
                  '893s2.14.1,893s2.14.2,893s2.14.3,893s2.14.4',
                  p_nda   => 7383);
        AddFtrT2 (2,
                  '893s2.14.5,893s2.14.6,893s2.14.7,893s2.14.8',
                  p_nda   => 7384);
        --Алкогольні напої
        /*--варіант 1 для заповнення "Спосіб вживання" по аналізу лівої частини
        AddFtrT2(3, '893s3.1.2,893s3.1.3,893s3.1.4', p_nda => 7385); AddParam('893s3.1.5',   AddFtrT2IsNotNull(p_nda => 7385));
        AddFtrT2(3, '893s3.2.2,893s3.2.3,893s3.2.4', p_nda => 7387); AddParam('893s3.2.5',   AddFtrT2IsNotNull(p_nda => 7387));
        AddFtrT2(3, '893s3.3.2,893s3.3.3,893s3.3.4', p_nda => 7389); AddParam('893s3.3.5',   AddFtrT2IsNotNull(p_nda => 7389));*/

        --варіант 2 для заповнення "Спосіб вживання" чекбоксам
        AddFtrT2 (3, '893s3.1.2,893s3.1.3,893s3.1.4', p_nda => 7385);
        AddParam ('893s3.1.5', Get_Ftr_Chk2 (p_at_id, p_nda => 7386));
        AddParam ('893s3.1.7', Get_Ftr_Chk2 (p_at_id, p_nda => 7394));
        AddParam ('893s3.1.8', Get_Ftr_Chk2 (p_at_id, p_nda => 7395));

        AddFtrT2 (3, '893s3.2.2,893s3.2.3,893s3.2.4', p_nda => 7387);
        AddParam ('893s3.2.5', Get_Ftr_Chk2 (p_at_id, p_nda => 7388));
        AddParam ('893s3.2.7', Get_Ftr_Chk2 (p_at_id, p_nda => 7396));
        AddParam ('893s3.2.8', Get_Ftr_Chk2 (p_at_id, p_nda => 7397));

        AddFtrT2 (3, '893s3.3.2,893s3.3.3,893s3.3.4', p_nda => 7389);
        AddParam ('893s3.3.5', Get_Ftr_Chk2 (p_at_id, p_nda => 7390));
        AddParam ('893s3.3.7', Get_Ftr_Chk2 (p_at_id, p_nda => 7398));
        AddParam ('893s3.3.8', Get_Ftr_Chk2 (p_at_id, p_nda => 7399));

        --ІІІ. Потреби отримувача соціальної послуги
        AddParam ('893.3.1', Get_Ftr (p_at_id, p_nda => 7391));
        AddParam ('893.3.2', Get_Ftr (p_at_id, p_nda => 7392));

        --V. Перелік заходів, що становлять зміст соціальної послуги
        l_str :=
            q'[
    select
           a.nsa_name       as c1,
           atip.atip_qnt||' '||Pr.Dic_Name||' '||Api$Act_Rpt.get_atip_term(atip.atip_id) as c2, --Періодичність
           (select listagg(s.atop_ln||' '||s.atop_fn||' '||s.atop_mn, Api$Act_Rpt.cnst_par) within group(order by s.atop_order, s.atop_ln)
              from uss_esr.at_other_spec s where s.atop_at = atip.atip_at and s.history_status = 'A'
               and s.atop_atip = atip.atip_id
           )                as c3,
           atip.atip_desc   as c4 --Моніторинг виконання індивідуального плану

      from
           (select * from uss_ndi.v_ndi_service_type t where t.nst_code in ('017.3')) nst,
           uss_ndi.v_ndi_nst_activities a,
           uss_esr.At_individual_plan atip,
           Uss_Ndi.v_Ddn_Atip_Period Pr
     where atip.atip_nst = nst.nst_id
       and atip.atip_nsa = a.nsa_id(+)
       and atip.history_status = 'A'
       and Pr.Dic_Value(+)= atip.Atip_Period
       and atip.atip_at = :p_at_id
    order by atip_order, a.nsa_order
  ]';
        l_str :=
            REGEXP_REPLACE (l_str,
                            ':p_at_id',
                            p_at_id,
                            1,
                            0,
                            'i');
        rdm$rtfl_univ.AddDataset ('893ds', l_str);

        --Працівник надавача соціальної послуги
        l_str :=
            q'[
    select null c1, uss_esr.Api$act_Rpt.Get_IPr(uss_esr.Api$act_Rpt.Getcupib(p_Cu_Id => :p_cu_id)) c2
      from dual
  ]';

        l_str := replace_null (l_str, ':p_cu_id', c.at_cu);
        rdm$rtfl_univ.AddDataset ('893ds_sgn', l_str);

        AddParam ('893sgn2', Get_IPr (p.pib));
        AddParam (
            'sgn_mark',
            api$act_rpt.get_sign_mark (p_at_id,
                                       p.Atp_Id,
                                       '_________________'));

        ------------------------------------
        IF p_bild_doc = 1
        THEN
            rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                             p_rpt_blob   => l_result);
            replace_ekr (l_result);
        END IF;

        RETURN l_result;
    END ACT_IP_DOC_893_R1;

    -- #94335 ІНДИВІДУАЛЬНИЙ ПЛАН надання соціальної послуги Паліативний догляд
    FUNCTION ACT_IP_DOC_894_R1 (p_at_id IN NUMBER, p_bild_doc NUMBER:= 1)
        RETURN BLOB
    IS
        CURSOR c_act IS
            SELECT a.at_sc,
                   a.at_dt,
                   a.At_rnspm,
                   a.at_cu,
                   a.at_wu,
                   ap.ap_reg_dt
              FROM act a, appeal ap
             WHERE a.at_id = p_at_id AND ap.ap_id(+) = a.at_ap;

        c          c_act%ROWTYPE;

        p          R_Person_for_act;                               --отримувач

        l_str      VARCHAR2 (3200);

        l_jbr_id   NUMBER;
        l_result   BLOB;
    BEGIN
        IF p_bild_doc = 1
        THEN
            rdm$rtfl_univ.initreport (p_code     => 'ACT_IP_DOC_894_R1',
                                      p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);
        ELSE
            --костиль: якщо тільки план(p_bild_doc = 1), то бланк створюється в любому випадку, інакше тільки, якщо є дані
            AddDatasetIPGlobal (p_at_id, 'ds894_global');
        END IF;

        ------------------------------------
        OPEN c_act;

        FETCH c_act INTO c;

        CLOSE c_act;

        p := get_AtPerson (p_at_id, get_AtPersonSc_id (p_at_id, c.at_sc));

        AddParam ('894.pib', p.pib);
        AddParam ('894.age',
                  TRUNC (MONTHS_BETWEEN (SYSDATE, p.birth_dt) / 12));
        AddParam ('894.gender', Gender (p.sex));
        AddParam (
            '894.fam_st',
            v_ddn ('uss_ndi.V_DDN_SS_MARITAL_SPCF',
                   Get_Ftr (p_at_id, p_nda => 2801, p_nng => 448))); -- Сімейний стан
        AddParam ('894.language',
                  Get_Ftr_Nt (p_at_id, p_nda => 2802, p_nng => 448)); -- Мова спілкування
        AddParam ('894.religion',
                  Get_Ftr_Nt (p_at_id, p_nda => 2803, p_nng => 448)); -- Конфесійна приналежність
        AddParam ('894.invalid', p.Atp_Disable_Record); -- Інвалідність, група
        AddParam ('894.stupin',
                  Get_Ftr_Nt (p_at_id, p_nda => 2804, p_nng => 448)); -- Ступінь індивідуальної потреби в наданні соціальної послуги з паліативного догляду
        AddParam ('894.ap_reg_dt', TO_CHAR (c.ap_reg_dt, 'dd.mm.yyyy')); -- Дата звернення
        AddParam ('894.rnspm', Api$act.Get_At_Spec_Name (c.at_wu, c.at_cu)); -- Прізвище, ім’я, по батькові надавача соціальної послуги
        AddParam ('894.other_spec', GetOtherSpec (p_at_id, 'OC')); -- Інформація щодо необхідності в залученні додаткових фахівців
        AddParam ('894.monitoring',
                  Get_Ftr_Nt (p_at_id, p_nda => 2805, p_nng => 448)); -- Моніторинг / поточне оцінювання результатів, перегляд індивідуального плану (дата проведення, підпис)

        l_str :=
            q'[
    select case when rownum = 1 then 'Паліативний догляд' end as c1,
           t.*
      from (select a.nsa_name as c2,
                   atip.atip_resources as c3,
                   atip.atip_qnt||' '||Pr.Dic_Name||' '||Api$Act_Rpt.get_atip_term(atip.atip_id) as c4,
                   (select listagg(s.atop_ln||' '||s.atop_fn||' '||s.atop_mn, Api$Act_Rpt.cnst_par) within group(order by s.atop_order, s.atop_ln)
                      from uss_esr.at_other_spec s where s.atop_at = atip.atip_at and s.history_status = 'A'
                       and s.atop_atip = atip.atip_id
                   )                as c5

              from uss_esr.At_individual_plan atip
              join uss_ndi.v_ndi_nst_activities a on (a.nsa_id = atip.atip_nsa)
              left join Uss_Ndi.v_Ddn_Atip_Period Pr on (pr.dic_value = atip.atip_period)
             where atip.history_status = 'A'
               and atip.atip_at = :p_at_id
            order by atip_order, a.nsa_order
           ) t
  ]';
        l_str :=
            REGEXP_REPLACE (l_str,
                            ':p_at_id',
                            p_at_id,
                            1,
                            0,
                            'i');

        rdm$rtfl_univ.AddDataset ('894.ds', l_str);

        AddParam ('sgn_mark', '______________________'); --api$act_rpt.get_sign_mark(p_at_id, p.Atp_Id, '______________________'));

        ------------------------------------
        IF p_bild_doc = 1
        THEN
            rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                             p_rpt_blob   => l_result);
            replace_ekr (l_result);
        END IF;

        RETURN l_result;
    END ACT_IP_DOC_894_R1;

    -- #95002 ІНДИВІДУАЛЬНИЙ ПЛАН надання соціальної послуги перекладу жестовою мовою
    FUNCTION ACT_IP_DOC_895_R1 (p_at_id IN NUMBER, p_bild_doc NUMBER:= 1)
        RETURN BLOB
    IS
        CURSOR c_act IS
            SELECT a.at_sc,
                   a.At_rnspm,
                   a.at_cu,
                   a.at_wu,
                   ap.ap_reg_dt
              FROM act a, appeal ap
             WHERE a.at_id = p_at_id AND ap.ap_id(+) = a.at_ap;

        c          c_act%ROWTYPE;

        p          R_Person_for_act;                               --отримувач

        l_str      VARCHAR2 (3200);

        l_jbr_id   NUMBER;
        l_result   BLOB;
    BEGIN
        IF p_bild_doc = 1
        THEN
            rdm$rtfl_univ.initreport (p_code     => 'ACT_IP_DOC_895_R1',
                                      p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);
        ELSE
            --костиль: якщо тільки план(p_bild_doc = 1), то бланк створюється в любому випадку, інакше тільки, якщо є дані
            AddDatasetIPGlobal (p_at_id, 'ds895_global');
        END IF;

        ------------------------------------
        OPEN c_act;

        FETCH c_act INTO c;

        CLOSE c_act;

        p := get_AtPerson (p_at_id, get_AtPersonSc_id (p_at_id, c.at_sc));

        AddParam ('895p1', p.pib);
        AddParam ('895p2', TRUNC (MONTHS_BETWEEN (SYSDATE, p.birth_dt) / 12)); --Вік
        AddParam ('895p3', Gender (p.sex));                            --Стать
        AddParam (
            '895p4',
            v_ddn ('uss_ndi.V_DDN_SS_MARITAL_SPCF',
                   Get_Ftr (p_at_id, p_nda => 7424)));         --Сімейний стан
        AddParam ('895p5', Get_Ftr_Nt (p_at_id, p_nda => 7425)); --Мова спілкування
        AddParam (
            '895p6',
            v_ddn ('uss_ndi.V_DDN_SCY_GROUP',
                   Get_Ftr (p_at_id, p_nda => 7426)));          --Інвалідність
        AddParam ('895p7', Get_Ftr_Nt (p_at_id, p_nda => 7427)); --Ступінь індивідуальної потреби
        AddParam ('895p8', Get_Ftr_Nt (p_at_id, p_nda => 7428)); --Додаткова інформація
        AddParam ('895p9', TO_CHAR (c.ap_reg_dt, 'dd.mm.yyyy')); --Дата звернення

        l_str :=
            q'[
    select
           nst.nst_name     as c1,
           a.nsa_name       as c2,
           case when a.nsa_can_group = 'T' then 'Груповий'
                when a.nsa_can_ind   = 'T' then 'Індивідуальний'
           end              as c3,
           atip.atip_desc   as c4, --Форма перекладу
           atip.atip_resources as c5,
           atip.atip_qnt||' '||Pr.Dic_Name||' '||Api$Act_Rpt.get_atip_term(atip.atip_id) as c6,
           (select listagg(s.atop_ln||' '||s.atop_fn||' '||s.atop_mn, Api$Act_Rpt.cnst_par) within group(order by s.atop_order, s.atop_ln)
              from uss_esr.at_other_spec s where s.atop_at = atip.atip_at and s.history_status = 'A'
               --and (s.atop_atip is null or s.atop_atip = atip.atip_id)
               and s.atop_atip = atip.atip_id
           )                as c7

      from
           (select * from uss_ndi.v_ndi_service_type t where t.nst_code in ('022.0')) nst,
           uss_ndi.v_ndi_nst_activities a,
           uss_esr.At_individual_plan atip,
           Uss_Ndi.v_Ddn_Atip_Period Pr
     where atip.atip_nst = nst.nst_id
       and atip.atip_nsa = a.nsa_id(+)
       and atip.history_status = 'A'
       and Pr.Dic_Value(+)= atip.Atip_Period
       and atip.atip_at = :p_at_id
    order by atip_order, a.nsa_order
  ]';
        l_str :=
            REGEXP_REPLACE (l_str,
                            ':p_at_id',
                            p_at_id,
                            1,
                            0,
                            'i');

        rdm$rtfl_univ.AddDataset ('ds895', l_str);
        AddParam ('895p10', Get_Ftr_Nt (p_at_id, p_nda => 7429)); --Моніторинг / поточне оцінювання результатів

        ------------------------------------
        IF p_bild_doc = 1
        THEN
            rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                             p_rpt_blob   => l_result);
            replace_ekr (l_result);
        END IF;

        RETURN l_result;
    END ACT_IP_DOC_895_R1;

    --#94997 017.1-897-Інд.план надання СП соц.реабілітації для осіб з інтелект. та псих. порушеннями
    FUNCTION ACT_IP_DOC_897_R1 (p_at_id IN NUMBER, p_bild_doc NUMBER:= 1)
        RETURN BLOB
    IS
        CURSOR c_act IS
            SELECT a.at_sc,
                   a.At_rnspm,
                   a.at_cu,
                   a.at_wu,
                   ap.ap_reg_dt
              FROM act a, appeal ap
             WHERE a.at_id = p_at_id AND ap.ap_id(+) = a.at_ap;

        c          c_act%ROWTYPE;

        p          R_Person_for_act;                               --отримувач
        p1         R_Person_for_act;                  --представник отримувача
        p2         R_Person_for_act; --підписант: отримувач/представник отримувача

        l_str      VARCHAR2 (3200);

        l_jbr_id   NUMBER;
        l_result   BLOB;
    BEGIN
        IF p_bild_doc = 1
        THEN
            rdm$rtfl_univ.initreport (p_code     => 'ACT_IP_DOC_897_R1',
                                      p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);
        ELSE
            --костиль: якщо тільки план(p_bild_doc = 1), то бланк створюється в любому випадку, інакше тільки, якщо є дані
            AddDatasetIPGlobal (p_at_id, 'ds897_global');
        END IF;

        ------------------------------------
        OPEN c_act;

        FETCH c_act INTO c;

        CLOSE c_act;

        p := get_AtPerson (p_at_id, get_AtPersonSc_id (p_at_id, c.at_sc));
        p1 := get_AtPerson (p_at_id, get_AtPerson_id (p_at_id, 'OR'));
        --для підписанта шукаємо спершу отримувача, а потім - представника
        p2 :=
            CASE
                WHEN get_at_signers_pers (p_at_id, p.Atp_Id).Atp_Id
                         IS NOT NULL
                THEN
                    get_at_signers_pers (p_at_id, p.Atp_Id)
                ELSE
                    get_at_signers_pers (p_at_id, p1.Atp_Id)
            END;

        AddParam ('897.1', p.pib);
        AddParam ('897.2', TRUNC (MONTHS_BETWEEN (SYSDATE, p.birth_dt) / 12)); --Вік
        AddParam ('897.3', Gender (p.sex));                            --Стать
        AddParam (
            '897.4',
            v_ddn ('uss_ndi.V_DDN_SS_MARITAL_SPCF',
                   Get_Ftr (p_at_id, p_nda => 7270)));         --Сімейний стан
        AddParam ('897.5', Get_Ftr_Nt (p_at_id, p_nda => 7271)); --Ступінь індивідуальної потреби

        AddParam ('897.6', p1.Pib); --представник (за наявності) отримувача соціальної послуги
        AddParam (
            '897.7',
               NVL2 (p1.Phone, 'тел.' || p1.Phone || ' ')
            || NVL2 (p1.Email, 'email ' || p1.Email));    --Контактні дані законного представника (за наявності)
        AddParam ('897.8', TO_CHAR (c.ap_reg_dt, 'dd.mm.yyyy')); --Дата звернення

        AddParam ('897.9', Get_Ftr_Nt (p_at_id, p_nda => 7272)); --Надавач соціальної послуги соціальної реабілітації (П.І.Б.)
        AddParam ('897.10', Get_Ftr_Nt (p_at_id, p_nda => 7273)); --Потреба у залученні інших фахівців

        l_str :=
            q'[
    select
           nst.nst_name     as c1,
           a.nsa_name       as c2,
           atip.atip_resources as c3,
           atip.atip_qnt||' '||Pr.Dic_Name||' '||Api$Act_Rpt.get_atip_term(atip.atip_id) as c4,
           (select listagg(s.atop_ln||' '||s.atop_fn||' '||s.atop_mn, Api$Act_Rpt.cnst_par) within group(order by s.atop_order, s.atop_ln)
              from uss_esr.at_other_spec s where s.atop_at = atip.atip_at and s.history_status = 'A'
               and s.atop_atip = atip.atip_id
           )                as c5

      from
           (select * from uss_ndi.v_ndi_service_type t where t.nst_code in ('017.1')) nst,
           uss_ndi.v_ndi_nst_activities a,
           uss_esr.At_individual_plan atip,
           Uss_Ndi.v_Ddn_Atip_Period Pr
     where atip.atip_nst = nst.nst_id
       and atip.atip_nsa = a.nsa_id(+)
       and atip.history_status = 'A'
       and Pr.Dic_Value(+)= atip.Atip_Period
       and atip.atip_at = :p_at_id
    order by a.nsa_order
  ]';
        l_str :=
            REGEXP_REPLACE (l_str,
                            ':p_at_id',
                            p_at_id,
                            1,
                            0,
                            'i');

        rdm$rtfl_univ.AddDataset ('897ds', l_str);

        AddParam ('897.11', Get_Ftr_Nt (p_at_id, p_nda => 7274)); --Моніторинг виконання індивідуального плану

        AddParam ('897sgn1', Api$act.Get_At_Spec_Name (c.at_wu, c.at_cu));
        AddParam ('897sgn2', p2.pib);

        AddParam (
            'sgn_mark',
            api$act_rpt.get_sign_mark (p_at_id,
                                       p2.Atp_Id,
                                       '_________________'));

        ------------------------------------
        IF p_bild_doc = 1
        THEN
            rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                             p_rpt_blob   => l_result);
            replace_ekr (l_result);
        END IF;

        RETURN l_result;
    END ACT_IP_DOC_897_R1;

    --#94999 ІНДИВІДУАЛЬНИЙ ПЛАН надання соціальної послуги тимчасового відпочинку для батьків або осіб, які їх замінюють 018.1
    FUNCTION ACT_IP_DOC_899_R1 (p_at_id IN NUMBER, p_bild_doc NUMBER:= 1)
        RETURN BLOB
    IS
        CURSOR c_act IS
            SELECT a.at_sc,
                   a.At_rnspm,
                   a.at_cu,
                   a.at_wu,
                   ap.ap_reg_dt
              FROM act a, appeal ap
             WHERE a.at_id = p_at_id AND ap.ap_id(+) = a.at_ap;

        c          c_act%ROWTYPE;

        p          R_Person_for_act;                               --отримувач

        l_str      VARCHAR2 (3200);

        l_jbr_id   NUMBER;
        l_result   BLOB;
    BEGIN
        IF p_bild_doc = 1
        THEN
            rdm$rtfl_univ.initreport (p_code     => 'ACT_IP_DOC_899_R1',
                                      p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);
        ELSE
            --костиль: якщо тільки план(p_bild_doc = 1), то бланк створюється в любому випадку, інакше тільки, якщо є дані
            AddDatasetIPGlobal (p_at_id, 'ds899_global');
        END IF;

        ------------------------------------
        OPEN c_act;

        FETCH c_act INTO c;

        CLOSE c_act;

        p := get_AtPerson (p_at_id, get_AtPersonSc_id (p_at_id, c.at_sc));

        AddParam ('899.1', Get_Ftr_Nt (p_at_id, p_nda => 5532));        --мати
        AddParam ('899.2', Get_Ftr_Nt (p_at_id, p_nda => 5533));      --батько
        AddParam ('899.3', Get_Ftr_Nt (p_at_id, p_nda => 5534)); --інші законні представники
        --Інформація про дитину
        AddParam ('899.4', Get_Ftr_Nt (p_at_id, p_nda => 5535));
        AddParam ('899.5', Get_Ftr_Nt (p_at_id, p_nda => 5536));
        AddParam ('899.6', Gender (Get_Ftr_Nt (p_at_id, p_nda => 5537))); --Стать

        AddParam ('899.7',
                  NVL (TO_CHAR (c.ap_reg_dt, 'dd.mm.yyyy'), c_date_empty));
        AddParam ('899.8', Api$act.Get_At_Spec_Name (c.at_wu, c.at_cu)); --відповідальний за організацію та надання соціальної послуги
        AddParam ('899.9', Get_Ftr_Nt (p_at_id, p_nda => 5538)); --Потреба у залученні інших фахівців

        l_str :=
            q'[
    select atip.atip_at,
           nst.nst_name     as c1,
           a.nsa_name       as c2,
           atip.atip_resources as c3,
           atip.atip_qnt||' '||Pr.Dic_Name||' '||Api$Act_Rpt.get_atip_term(atip.atip_id) as c4,
           (select listagg(s.atop_ln||' '||s.atop_fn||' '||s.atop_mn, Api$Act_Rpt.cnst_par) within group(order by s.atop_order, s.atop_ln)
              from uss_esr.at_other_spec s where s.atop_at = atip.atip_at and s.history_status = 'A'
               and s.atop_atip = atip.atip_id
           )                as c5

      from
           (select * from uss_ndi.v_ndi_service_type t where t.nst_code in ('018.1')) nst,
           uss_ndi.v_ndi_nst_activities a,
           uss_esr.At_individual_plan atip,
           Uss_Ndi.v_Ddn_Atip_Period Pr
     where atip.atip_nst = nst.nst_id
       and atip.atip_nsa = a.nsa_id(+)
       and atip.history_status = 'A'
       and Pr.Dic_Value(+)= atip.Atip_Period
       and atip.atip_at = :p_at_id
    order by atip_order, a.nsa_order
  ]';
        l_str :=
            REGEXP_REPLACE (l_str,
                            ':p_at_id',
                            p_at_id,
                            1,
                            0,
                            'i');

        rdm$rtfl_univ.AddDataset ('899ds', l_str);

        AddParam ('899.10', Get_Ftr_Nt (p_at_id, p_nda => 5539)); --Моніторинг виконання індивідуального плану

        AddParam ('899sgn1', Api$act.Get_At_Spec_Name (c.at_wu, c.at_cu));
        AddParam ('899sgn2', p.pib);

        AddParam (
            'sgn_mark',
            api$act_rpt.get_sign_mark (p_at_id,
                                       p.Atp_Id,
                                       '_________________'));

        ------------------------------------
        IF p_bild_doc = 1
        THEN
            rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                             p_rpt_blob   => l_result);
            replace_ekr (l_result);
        END IF;

        RETURN l_result;
    END ACT_IP_DOC_899_R1;

    --#95000 ІНДИВІДУАЛЬНИЙ ПЛАН надання соціальної послуги супроводу під час інклюзивного навчання
    FUNCTION ACT_IP_DOC_1001_R1 (p_at_id IN NUMBER, p_bild_doc NUMBER:= 1)
        RETURN BLOB
    IS
        CURSOR c_act IS
            SELECT a.at_sc,
                   a.at_dt,
                   a.At_rnspm,
                   a.at_cu,
                   a.at_wu,
                   ap.ap_reg_dt
              FROM act a, appeal ap
             WHERE a.at_id = p_at_id AND ap.ap_id(+) = a.at_ap;

        c          c_act%ROWTYPE;

        p          R_Person_for_act;                               --отримувач

        l_str      VARCHAR2 (3200);

        l_jbr_id   NUMBER;
        l_result   BLOB;
    BEGIN
        IF p_bild_doc = 1
        THEN
            rdm$rtfl_univ.initreport (p_code     => 'ACT_IP_DOC_1001_R1',
                                      p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);
        ELSE
            --костиль: якщо тільки план(p_bild_doc = 1), то бланк створюється в любому випадку, інакше тільки, якщо є дані
            AddDatasetIPGlobal (p_at_id, 'ds1001_global');
        END IF;

        ------------------------------------
        OPEN c_act;

        FETCH c_act INTO c;

        CLOSE c_act;

        --p:= get_AtPerson(p_at_id, get_AtPersonSc_id(p_at_id, c.at_sc));
        p :=
            get_AtPerson (p_at    => p_at_id,
                          p_atp   => get_AtPerson_id (p_at_id, 'OS'));


        AddParam ('1001.1', p.pib);
        AddParam ('1001.2',
                  TRUNC (MONTHS_BETWEEN (c.at_dt, p.birth_dt) / 12));    --Вік
        AddParam ('1001.3', Gender (p.sex));                           --Стать
        AddParam ('1001.4', Get_Ftr_Nt (p_at_id, p_nda => 7276)); --Мова спілкування
        AddParam (
            '1001.5',
            v_ddn ('uss_ndi.V_DDN_SCY_GROUP',
                   Get_Ftr (p_at_id, p_nda => 7277)));          --Інвалідність
        AddParam ('1001.6', Get_Ftr_Nt (p_at_id, p_nda => 7278)); --Додаткова інформація

        AddParam ('1001.6', Get_Ftr_Nt (p_at_id, p_nda => 7279)); --ПІБ асистент
        AddParam ('1001.7', Get_Ftr_Nt (p_at_id, p_nda => 7280)); --залучення інших фахівців

        l_str :=
            q'[
    select
           row_number() over(order by atip_order, a.nsa_order) as c1,
           a.nsa_name          as c2,
           atip.atip_resources as c3,
           case when a.nsa_ind_minutes > 0 then round(a.nsa_ind_minutes/60) end c4, --Орієнтовний час виконання 1 заходу, годин
           Pr.Dic_Name         as c5, --Періодичність
           atip.atip_qnt       as c6, -- Кількість заходів на 1 послугу
           round(a.nsa_ind_minutes* atip.atip_qnt/60) as c7,--Загальний час на 1 послугу, годин
           null as c8
      from
           (select * from uss_ndi.v_ndi_service_type t where t.nst_code in ('020.0')) nst,
           uss_ndi.v_ndi_nst_activities a,
           uss_esr.At_individual_plan atip,
           Uss_Ndi.v_Ddn_Atip_Period Pr
     where atip.atip_nst = nst.nst_id
       and atip.atip_nsa = a.nsa_id(+)
       and atip.history_status = 'A'
       and Pr.Dic_Value(+)= atip.Atip_Period
       and atip.atip_at = :p_at_id
    order by atip_order, a.nsa_order
  ]';
        l_str :=
            REGEXP_REPLACE (l_str,
                            ':p_at_id',
                            p_at_id,
                            1,
                            0,
                            'i');

        rdm$rtfl_univ.AddDataset ('1001ds', l_str);

        AddParam ('1001.10', Get_Ftr_Nt (p_at_id, p_nda => 7281)); --перегляд індивідуального плану
        AddParam ('1001.11', Get_Ftr_Nt (p_at_id, p_nda => 7282)); --Дата перегляду

        AddParam ('1001sgn1', Get_Ftr_Nt (p_at_id, p_nda => 7279));
        AddParam ('1001sgn2', Get_Ftr_Nt (p_at_id, p_nda => 7283));
        AddParam ('1001sgn3', Get_Ftr_Nt (p_at_id, p_nda => 7284));

        ------------------------------------
        IF p_bild_doc = 1
        THEN
            rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                             p_rpt_blob   => l_result);
            replace_ekr (l_result);
        END IF;

        RETURN l_result;
    END ACT_IP_DOC_1001_R1;

    --#95001 ІНДИВІДУАЛЬНИЙ ПЛАН надання соціальної послуги фізичного супроводу
    FUNCTION ACT_IP_DOC_1003_R1 (p_at_id IN NUMBER, p_bild_doc NUMBER:= 1)
        RETURN BLOB
    IS
        CURSOR c_act IS
            SELECT a.at_sc,
                   a.at_dt,
                   a.At_rnspm,
                   a.at_cu,
                   a.at_wu,
                   ap.ap_reg_dt
              FROM act a, appeal ap
             WHERE a.at_id = p_at_id AND ap.ap_id(+) = a.at_ap;

        c          c_act%ROWTYPE;

        p          R_Person_for_act;                               --отримувач

        l_str      VARCHAR2 (3200);

        l_jbr_id   NUMBER;
        l_result   BLOB;
    BEGIN
        IF p_bild_doc = 1
        THEN
            rdm$rtfl_univ.initreport (p_code     => 'ACT_IP_DOC_1003_R1',
                                      p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);
        ELSE
            --костиль: якщо тільки план(p_bild_doc = 1), то бланк створюється в любому випадку, інакше тільки, якщо є дані
            AddDatasetIPGlobal (p_at_id, 'ds1003_global');
        END IF;

        ------------------------------------
        OPEN c_act;

        FETCH c_act INTO c;

        CLOSE c_act;

        p := get_AtPerson (p_at_id, get_AtPersonSc_id (p_at_id, c.at_sc));

        AddParam ('1003p1', NVL (Date2Str (c.at_dt), c_date_empty));

        AddParam ('1003p2', p.pib);
        AddParam (
            '1003p3',
            v_ddn ('uss_ndi.V_DDN_SCY_GROUP',
                   Get_Ftr (p_at_id, p_nda => 5529)));          --Інвалідність
        AddParam ('1003p4', Get_Ftr_Nt (p_at_id, p_nda => 5857)); --Ступінь індивідуальної потреби

        l_str :=
            q'[
    select
           a.nsa_name       as c1,
           atip.atip_place  as c2,
           atip.atip_resources as c3,
           atip.atip_qnt||' '||Pr.Dic_Name as c4,
           (select listagg(s.atop_ln||' '||s.atop_fn||' '||s.atop_mn, Api$Act_Rpt.cnst_par) within group(order by s.atop_order, s.atop_ln)
              from uss_esr.at_other_spec s where s.atop_at = atip.atip_at and s.history_status = 'A'
               and s.atop_atip = atip.atip_id
           )                as c5,
           Api$Act_Rpt.get_atip_term(atip.atip_id) as c6 --Строк виконання заходів

      from
           (select * from uss_ndi.v_ndi_service_type t where t.nst_code in ('021.0')) nst,
           uss_ndi.v_ndi_nst_activities a,
           uss_esr.At_individual_plan atip,
           Uss_Ndi.v_Ddn_Atip_Period Pr
     where atip.atip_nst = nst.nst_id
       and atip.atip_nsa = a.nsa_id(+)
       and atip.history_status = 'A'
       and Pr.Dic_Value(+)= atip.Atip_Period
       and atip.atip_at = :p_at_id
    order by atip_order, a.nsa_order
  ]';
        l_str :=
            REGEXP_REPLACE (l_str,
                            ':p_at_id',
                            p_at_id,
                            1,
                            0,
                            'i');

        rdm$rtfl_univ.AddDataset ('1003ds', l_str);

        AddParam ('1003p5', Get_Ftr_Nt (p_at_id, p_nda => 5530)); --Дата перегляду
        AddParam ('1003p6-1',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5531, p_Chk => 'UN')); --індивідуальний план залишився незмінним uss_ndi.V_DDN_SS_REVIEWING_IP
        AddParam ('1003p6-2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5531, p_Chk => 'CH')); --змінився


        ------------------------------------
        IF p_bild_doc = 1
        THEN
            rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                             p_rpt_blob   => l_result);
            replace_ekr (l_result);
        END IF;

        RETURN l_result;
    END ACT_IP_DOC_1003_R1;

    --#94332 Інд.план надання СП соціальної інтеграції та реінтеграції бездомних осіб
    FUNCTION ACT_IP_DOC_1006_R1 (p_at_id IN NUMBER, p_bild_doc NUMBER:= 1)
        RETURN BLOB
    IS
        CURSOR c_act IS
            SELECT a.at_sc,
                   a.at_dt,
                   a.At_rnspm,
                   a.at_cu,
                   a.at_wu,
                   ap.ap_reg_dt
              FROM act a, appeal ap
             WHERE a.at_id = p_at_id AND ap.ap_id(+) = a.at_ap;

        c          c_act%ROWTYPE;

        p          R_Person_for_act;                               --отримувач

        l_str      VARCHAR2 (3200);

        l_jbr_id   NUMBER;
        l_result   BLOB;
    BEGIN
        IF p_bild_doc = 1
        THEN
            rdm$rtfl_univ.initreport (p_code     => 'ACT_IP_DOC_1006_R1',
                                      p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);
        ELSE
            --костиль: якщо тільки план(p_bild_doc = 1), то бланк створюється в любому випадку, інакше тільки, якщо є дані
            AddDatasetIPGlobal (p_at_id, 'ds1006_global');
        END IF;

        ------------------------------------
        OPEN c_act;

        FETCH c_act INTO c;

        CLOSE c_act;

        p := get_AtPerson (p_at_id, get_AtPersonSc_id (p_at_id, c.at_sc));

        AddParam ('1006.1', p.pib);
        AddParam ('1006.2',
                  TRUNC (MONTHS_BETWEEN (SYSDATE, p.birth_dt) / 12));
        AddParam ('1006.3', Gender (p.sex));
        AddParam (
            '1006.4',
            v_ddn ('uss_ndi.V_DDN_SS_MARITAL_SPCF',
                   Get_Ftr (p_at_id, p_nda => 1663)));         --Сімейний стан
        AddParam ('1006.5', Get_Ftr_Nt (p_at_id, p_nda => 7266)); --Ступінь індивідуальної потреби
        AddParam ('1006.6', Get_Ftr_Nt (p_at_id, p_nda => 7267)); --Додаткова інформація
        AddParam ('1006.7', TO_CHAR (c.ap_reg_dt, 'dd.mm.yyyy')); --Дата звернення
        AddParam ('1006.8', Api$act.Get_At_Spec_Name (c.at_wu, c.at_cu)); --Надавач соціальної послуги
        AddParam ('1006.9', Get_Ftr_Nt (p_at_id, p_nda => 1672)); --Потреба в залученні інших фахівців

        l_str :=
            q'[
    select
           nst.nst_name     as c1,
           a.nsa_name       as c2,
           atip.atip_resources as c3,
           atip.atip_qnt||' '||Pr.Dic_Name||' '||Api$Act_Rpt.get_atip_term(atip.atip_id) as c4,
           (select listagg(s.atop_ln||' '||s.atop_fn||' '||s.atop_mn, Api$Act_Rpt.cnst_par) within group(order by s.atop_order, s.atop_ln)
              from uss_esr.at_other_spec s where s.atop_at = atip.atip_at and s.history_status = 'A'
               and s.atop_atip = atip.atip_id
           )                as c5

      from
           (select * from uss_ndi.v_ndi_service_type t where t.nst_code in ('014.0')) nst,
           uss_ndi.v_ndi_nst_activities a,
           uss_esr.At_individual_plan atip,
           Uss_Ndi.v_Ddn_Atip_Period Pr
     where atip.atip_nst = nst.nst_id
       and atip.atip_nsa = a.nsa_id(+)
       and atip.history_status = 'A'
       and Pr.Dic_Value(+)= atip.Atip_Period
       and atip.atip_at = :p_at_id
    order by atip_order, a.nsa_order
  ]';
        l_str :=
            REGEXP_REPLACE (l_str,
                            ':p_at_id',
                            p_at_id,
                            1,
                            0,
                            'i');

        rdm$rtfl_univ.AddDataset ('1006ds', l_str);

        AddParam ('1006.10', Get_Ftr_Nt (p_at_id, p_nda => 7269)); --Дата перегляду

        AddParam ('1006sgn1', Api$act.Get_At_Spec_Name (c.at_wu, c.at_cu));
        AddParam ('1006sgn2', p.pib);

        AddParam ('sgn_mark',
                  api$act_rpt.get_sign_mark (p_at_id, p.Atp_Id, ''));

        ------------------------------------
        IF p_bild_doc = 1
        THEN
            rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                             p_rpt_blob   => l_result);
            replace_ekr (l_result);
        END IF;

        RETURN l_result;
    END ACT_IP_DOC_1006_R1;

    -- #98709 015.1- Інд_план надання СП догляду вдома
    FUNCTION ACT_IP_DOC_1012_R1 (p_at_id IN NUMBER, p_bild_doc NUMBER:= 1)
        RETURN BLOB
    IS
        CURSOR c_act IS
            SELECT a.at_sc,
                   a.at_dt,
                   a.At_rnspm,
                   a.at_cu,
                   a.at_wu,
                   ap.ap_reg_dt
              FROM act a, appeal ap
             WHERE a.at_id = p_at_id AND ap.ap_id(+) = a.at_ap;

        c          c_act%ROWTYPE;

        p          R_Person_for_act;                               --отримувач

        l_str      VARCHAR2 (3200);

        l_jbr_id   NUMBER;
        l_result   BLOB;
    BEGIN
        IF p_bild_doc = 1
        THEN
            rdm$rtfl_univ.initreport (p_code     => 'ACT_IP_DOC_1012_R1',
                                      p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);
        ELSE
            --костиль: якщо тільки план(p_bild_doc = 1), то бланк створюється в любому випадку, інакше тільки, якщо є дані
            AddDatasetIPGlobal (p_at_id, 'ds1012_global');
        END IF;

        ------------------------------------
        OPEN c_act;

        FETCH c_act INTO c;

        CLOSE c_act;

        p := get_AtPerson (p_at_id, get_AtPersonSc_id (p_at_id, c.at_sc));

        AddParam ('1012p1', NVL (Date2Str (c.at_dt), c_date_empty));

        AddParam ('1012p2', p.pib);
        AddParam (
            '1012p3',
            v_ddn ('uss_ndi.V_DDN_SCY_GROUP',
                   Get_Ftr (p_at_id, p_nda => 7420)));          --Інвалідність
        AddParam ('1012p4', Get_Ftr_Nt (p_at_id, p_nda => 7421)); --Ступінь індивідуальної потреби

        l_str :=
            q'[
    SELECT a.Nsa_Name AS C1,
           Atip.Atip_Place AS C2,
           Atip.Atip_Resources AS C3,
           Atip.Atip_Qnt || ' ' || Pr.Dic_Name AS C4,

           (SELECT Listagg(s.Atop_Ln || ' ' || s.Atop_Fn || ' ' || s.Atop_Mn, Api$act_Rpt.Cnst_Par) --
                   Within GROUP(ORDER BY s.atop_order, s.Atop_Ln)
              FROM Uss_Esr.At_Other_Spec s
             WHERE s.Atop_At = Atip.Atip_At
               AND s.History_Status = 'A'
               AND s.Atop_Atip = Atip.Atip_Id) AS C5,

           Api$act_Rpt.Get_Atip_Term(Atip.Atip_Id) AS C6 --Строк виконання заходів

      FROM Uss_Ndi.v_Ndi_Service_Type   Nst,
           Uss_Ndi.v_Ndi_Nst_Activities a,
           Uss_Esr.At_Individual_Plan   Atip,
           Uss_Ndi.v_Ddn_Atip_Period    Pr
     WHERE 1 = 1
       AND Nst.Nst_Code IN ('015.1')
       AND Atip.Atip_Nst = Nst.Nst_Id
       and atip.atip_nsa = a.nsa_id(+)
       AND Atip.History_Status = 'A'
       AND Pr.Dic_Value(+) = Atip.Atip_Period
       AND Atip.Atip_At = :p_At_Id
     ORDER BY atip_order, a.Nsa_Order
  ]';
        l_str :=
            REGEXP_REPLACE (l_str,
                            ':p_at_id',
                            p_at_id,
                            1,
                            0,
                            'i');

        rdm$rtfl_univ.AddDataset ('1012ds', l_str);

        AddParam ('1012p5',
                  NVL (Get_Ftr_Nt (p_at_id, p_nda => 7422), c_date_empty2)); --Дата перегляду
        AddParam ('1012p6-1',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 7423, p_Chk => 'UN')); --індивідуальний план залишився незмінним uss_ndi.V_DDN_SS_REVIEWING_IP
        AddParam ('1012p6-2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 7423, p_Chk => 'CH')); --змінився


        AddParam ('osp_pib', p.Pib);
        AddParam ('sgn_mark', get_sign_mark (p_at_id, p.Atp_Id, ''));

        ------------------------------------
        IF p_bild_doc = 1
        THEN
            rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                             p_rpt_blob   => l_result);
            replace_ekr (l_result);
        END IF;

        RETURN l_result;
    END ACT_IP_DOC_1012_R1;

    --#93536 для 1.3 колонка Наявні документи  p_tp-1 -список типів док, 2- список документів
    FUNCTION get_doc_803_1_3 (p_ap_id    IN NUMBER,
                              p_app_id      NUMBER,
                              p_tp          NUMBER)
        RETURN VARCHAR2
    IS
        Result   VARCHAR2 (32000);
    BEGIN
        /*
        6, 7 - 1 - паспорт громадянина України,
        8,9 - 2 - документ, що підтверджує право на постійне / тимчасове проживання в Україні,
        808 - 3 - паспорт іноземця,
        601,602,10118 - 4 –пенсійне посвідчення,
        115,10038,10128 - 5 – посвідчення особи з інвалідністю,
        5 - 6 - облікова картка платника податків,
        10052 - 7 - довідка про взяття на облік внутрішньо переміщеної особи,
        805 - 8 - посвідчення про взяття на облік бездомної особи,
        9 - документи відсутні*/
        /*
        select
              case when nda_ndt in (6,7) then 1
               when nda_ndt in (8,9) then 2
               when nda_ndt in (808) then 3
               when nda_ndt in (601,602,10118) then 4
               when nda_ndt in (115,10038,10128) then 5
               when nda_ndt in (5) then 6
               when nda_ndt in (10052) then 7
               when nda_ndt in (805) then 8
               else 9
              end tp,
              dt.ndt_name, c.DIC_NAME, a.*, pt.pt_data_type
         from uss_ndi.ndi_document_type dt, uss_ndi.ndi_document_attr a, uss_ndi.ndi_param_type pt, V_DDN_DOC_ATTR_CLASS c
        where a.nda_ndt = dt.ndt_id
         and a.history_status = 'A' and pt.pt_id(+)= a.nda_pt
         and a.nda_ndt in (6,7, 8,9, 808, 601,602,10118, 115,10038,10128, 5, 10052, 805, 9)
         and c.DIC_VALUE = a.nda_class
         and a.nda_class in ('DSN', --№ док
                             'DORG', --Орган видачі документа
                             'DGVDT', --DATE
                             'DSN'    --Серія та номер документа
                             );*/

        SELECT CASE p_tp
                   WHEN 1
                   THEN
                       LISTAGG (num, ', ') WITHIN GROUP (ORDER BY num)
                   WHEN 2
                   THEN
                       LISTAGG (num || ': ' || str, c_chr10)
                           WITHIN GROUP (ORDER BY num)
               END    str
          INTO Result
          FROM (  SELECT CASE WHEN p_tp = 2 THEN apd_id END,
                         num,
                            MAX (
                                CASE
                                    WHEN nda_class IN ('DSN', 'DSN')
                                    THEN
                                        apda_val_string
                                END)
                         || ' '
                         || MAX (
                                CASE
                                    WHEN nda_class IN ('DORG')
                                    THEN
                                        apda_val_string
                                END)
                         || ' '
                         || MAX (
                                CASE
                                    WHEN nda_class IN ('DGVDT')
                                    THEN
                                        TO_CHAR (apda_val_dt, 'dd.mm.yyyy')
                                END)    str
                    FROM (SELECT CASE
                                     WHEN d.apd_ndt IN (6, 7)
                                     THEN
                                         1
                                     WHEN d.apd_ndt IN (8, 9)
                                     THEN
                                         2
                                     WHEN d.apd_ndt IN (808)
                                     THEN
                                         3
                                     WHEN d.apd_ndt IN (601, 602, 10118)
                                     THEN
                                         4
                                     WHEN d.apd_ndt IN (115, 10038, 10128)
                                     THEN
                                         5
                                     WHEN d.apd_ndt IN (5)
                                     THEN
                                         6
                                     WHEN d.apd_ndt IN (10052)
                                     THEN
                                         7
                                     WHEN d.apd_ndt IN (805)
                                     THEN
                                         8
                                     ELSE
                                         9
                                 END    num,
                                 nda.nda_class,
                                 d.apd_id,
                                 a.*
                            FROM uss_esr.ap_document        d,
                                 uss_esr.ap_document_attr   a,
                                 uss_ndi.v_ndi_document_attr nda
                           WHERE     d.apd_ap = p_ap_id
                                 AND d.apd_app = p_app_id
                                 AND d.history_status = 'A'
                                 AND a.apda_apd = d.apd_id
                                 AND a.history_status = 'A'
                                 AND d.apd_ndt IN (6,
                                                   7,
                                                   8,
                                                   9,
                                                   808,
                                                   601,
                                                   602,
                                                   10118,
                                                   115,
                                                   10038,
                                                   10128,
                                                   5,
                                                   10052,
                                                   805,
                                                   9,
                                                   37)
                                 AND nda.nda_id = a.apda_nda
                                 AND nda.nda_class IN ('DSN',          --№ док
                                                       'DORG', --Орган видачі документа
                                                       'DGVDT',         --DATE
                                                       'DSN' --Серія та номер документа
                                                            ))
                GROUP BY CASE WHEN p_tp = 2 THEN apd_id END, num);

        RETURN Result;
    END;

    --#93536 ANPOE «Акт про надання повнолітній особі соціальних послуг екстрено (кризово)»
    FUNCTION ACT_DOC_803_R1 (p_at_id IN NUMBER)
        RETURN BLOB
    IS
        --USS_ESR.Cmes$act_Anpoe
        CURSOR c_act IS
            SELECT a.At_Id,
                   a.at_num,
                   a.at_dt,
                   a.At_rnspm,
                   a.at_sc,
                   a.At_Wu,
                   a.at_cu,
                   a.at_live_address,
                   a.At_action_start_dt,
                   a.At_action_stop_dt,
                   a.at_ap,
                   ikis_rbm.tools.GetCuPib (a.at_cu)     AS cu_pib
              FROM uss_esr.act a
             WHERE a.at_id = p_at_id;

        c                  c_act%ROWTYPE;


        l_atpO             NUMBER;                                 --отримувач
        l_prsO             R_Person_for_act;

        l_str              VARCHAR2 (32000);
        l_ap_id            NUMBER;                              --id звернення

        /*l_sing_id  number;
        l_sing_Pib Tools.r_Pib;*/

        l_ind_plan_at_id   NUMBER
            := NVL (get_At_individual_plan_at_id (p_at_id), 0); --получити at_id акта, до якого прив"язан інд.план

        l_jbr_id           NUMBER;
        l_result           BLOB;
        l_test             CLOB;



        FUNCTION TestAtFtrChk (p_at_id   act.at_id%TYPE,
                               p_atp     at_person.atp_id%TYPE:= -1,
                               p_nda     VARCHAR2,
                               p_nng     NUMBER:= -1)
            RETURN VARCHAR2
        IS
        BEGIN
            FOR c
                IN (SELECT f.atef_feature
                      FROM uss_esr.at_section s, uss_esr.at_section_feature f
                     WHERE     s.ate_at = p_at_id
                           AND (p_atp = -1 OR s.ate_atp = p_atp)
                           AND (p_nng = -1 OR s.ate_nng = p_nng)
                           AND f.atef_ate = s.ate_id
                           AND f.atef_nda IN
                                   (SELECT TO_NUMBER (COLUMN_VALUE)     nda
                                      FROM XMLTABLE (p_nda)
                                     WHERE TRIM (p_nda) IS NOT NULL))
            LOOP
                IF c.atef_feature = 'T'
                THEN
                    RETURN org2ekr (c_check);
                END IF;
            END LOOP;

            RETURN NULL;
        END;

        FUNCTION TestAtFtrNtChk (p_at_id   act.at_id%TYPE,
                                 p_atp     at_person.atp_id%TYPE:= -1,
                                 p_nda     VARCHAR2,
                                 p_nng     NUMBER:= -1)
            RETURN VARCHAR2
        IS
        BEGIN
            FOR c
                IN (SELECT f.atef_notes
                      FROM uss_esr.at_section s, uss_esr.at_section_feature f
                     WHERE     s.ate_at = p_at_id
                           AND (p_atp = -1 OR s.ate_atp = p_atp)
                           AND (p_nng = -1 OR s.ate_nng = p_nng)
                           AND f.atef_ate = s.ate_id
                           AND f.atef_nda IN
                                   (SELECT TO_NUMBER (COLUMN_VALUE)     nda
                                      FROM XMLTABLE (p_nda)
                                     WHERE TRIM (p_nda) IS NOT NULL))
            LOOP
                IF c.atef_notes IS NOT NULL
                THEN
                    RETURN org2ekr (c_check);
                END IF;
            END LOOP;

            RETURN NULL;
        END;
    BEGIN
        rdm$rtfl_univ.initreport (p_code     => 'ACT_DOC_803_R1',
                                  p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);

        ------------------------------------
        OPEN c_act;

        FETCH c_act INTO c;

        CLOSE c_act;

        l_ap_id := c.at_ap;

        l_atpO :=
            NVL (
                get_AtPersonSc_id (p_at_id, c.at_sc),
                NVL (
                    get_AtPerson_id (p_At            => p_at_id,
                                     p_App_Tp        => 'Z',
                                     p_App_Tp_Only   => 1),
                    get_AtPerson_id (p_At            => p_at_id,
                                     p_App_Tp        => 'OS',
                                     p_App_Tp_Only   => 1)));
        l_prsO := get_AtPerson (p_at_id, l_atpO);

        AddParam ('p01', Underline (Date2Str (c.at_action_start_dt), 1));
        AddParam ('p02',
                  Underline (Get_Nsp_Name (p_rnspm_id => c.At_rnspm), 1)); --надавач соцпослуг
        AddParam (
            'p03',
            Underline (
                   GetCuPIB (c.at_cu)
                || ', '
                || Get_Ftr_Nt (p_at_id, p_Nda => 8540),
                1));
        AddParam ('p04', Underline (l_prsO.pib, 1));

        AddParam ('p05', Underline (l_prsO.phone, 1));
        --1. Загальні відомості про отримувача соціальних послуг
        --uss_ndi.V_DDN_SS_NEEDS
        AddParam ('p1.1', chk_val ('FM', Get_Ftr (p_at_id, p_nda => 2033)));
        AddParam ('p1.2',
                  GetAtSection (p_at_id, p_nng => 193).ate_indicator_value1);
        AddParam ('p1.3',
                  GetAtSection (p_at_id, p_nng => 193).ate_indicator_value2);
        AddParam ('p1.4', chk_val ('Z', Get_Ftr (p_at_id, p_nda => 2033)));
        --1.2. Досвід отримання соціальних послуг
        AddParam ('p1.5', Get_Ftr_Chk (p_at_id, p_nda => 2841));
        AddParam ('p1.6', Get_Ftr_Chk (p_at_id, p_nda => 2842));
        AddParam ('p1.7', Get_Ftr_Chk (p_at_id, p_nda => 2843));

        --1.3. Дані повнолітніх членів сім’ї отримувача соціальних послуг / повнолітньої особи (отримувача соціальних послуг)
        --члени родини
        --Atp_is_capable ->  uss_ndi.v_ddn_capacity_tp
        --Atp_is_selfservice -> uss_ndi.v_ddn_self_serv_tp
        --Atp_is_vpo -> uss_ndi.v_ddn_vpo_reg_st
        l_str :=
            q'[
       select
             pib c1,
             decode(sex, 'F', 'Ж', 'M', 'Ч') c2,
             birth_dt_str c3,
             atp_citizenship c4,
             live_address c5,
             fact_address c6,
             case when is_disabled = 'T' then 'Так' else 'Ні' end c7,
             nvl((select t1.dic_name from uss_ndi.v_ddn_capacity_tp t1 where t1.dic_value = t.is_capable), decode(t.is_capable, 'T', 'Так', 'F', 'Ні')) c8,
             nvl((select t1.dic_name from uss_ndi.v_ddn_self_serv_tp t1 where t1.dic_value = t.is_selfservice), decode(t.is_selfservice, 'T', 'Так', 'F', 'Ні')) c9,
             nvl((select t1.dic_name from uss_ndi.v_ddn_vpo_reg_st t1 where t1.dic_value = t.is_vpo), decode(t.is_vpo, 'T', 'Так', 'F', 'Ні')) c10,
             uss_esr.Api$Act_Rpt.get_doc_803_1_3(p_ap_id => :p_ap_id, p_app_id => t.atp_app, p_tp => 1) c11,
             uss_esr.Api$Act_Rpt.get_doc_803_1_3(p_ap_id => :p_ap_id, p_app_id => t.atp_app, p_tp => 2) c12
       from table(uss_esr.Api$Act_Rpt.At_Person_for_act(:p_at_id)) t
       where months_between(sysdate, t.birth_dt)/12 >= 18
       order by birth_dt]';
        l_str :=
            REGEXP_REPLACE (l_str,
                            ':p_at_id',
                            p_at_id,
                            1,
                            0,
                            'i');
        l_str :=
            REGEXP_REPLACE (l_str,
                            ':p_ap_id',
                            l_ap_id,
                            1,
                            0,
                            'i');
        rdm$rtfl_univ.AddDataset ('ds13', l_str);

        --1.4. Дані про дитину/дітей отримувача соціальних послуг
        l_str :=
            q'[
       select
             pib c1,
             decode(sex, 'F', 'Ж', 'M', 'Ч') c2,
             atp_citizenship c3,
             birth_dt_str c4,
             live_address c5,
             fact_address c6,
             case when is_disabled = 'T' then 'Так' else 'Ні' end c7,
             case when IS_ORPHAN = 'T' then 'Так' else 'Ні' end  /*(select t1.dic_name from uss_ndi.v_ddn_vpo_reg_st t1 where t1.dic_value = t.is_vpo)*/ c8,
             case when IS_VPO = 'T' then 'Так' else 'Ні' end/*uss_esr.Api$Act_Rpt.get_doc_803_1_3(p_ap_id => :p_ap_id, p_app_id => t.atp_app, p_tp => 1)*/ c9,
             uss_esr.Api$Act_Rpt.get_doc_803_1_3(p_ap_id => :p_ap_id, p_app_id => t.atp_app, p_tp => 2) c10
       from table(uss_esr.Api$Act_Rpt.At_Person_for_act(:p_at_id)) t
       where months_between(sysdate, t.birth_dt)/12 < 18
       order by birth_dt]';
        l_str :=
            REGEXP_REPLACE (l_str,
                            ':p_at_id',
                            p_at_id,
                            1,
                            0,
                            'i');
        l_str :=
            REGEXP_REPLACE (l_str,
                            ':p_ap_id',
                            l_ap_id,
                            1,
                            0,
                            'i');
        rdm$rtfl_univ.AddDataset ('ds14', l_str);

        --2. Оцінка ситуації, в якій перебуває отримувач соціальних послуг
        AddParam ('p2.1_1',
                  UnderLine (Get_Ftr_Nt (p_at_id, p_nda => 2844), 1));

        SELECT MAX (
                   CASE Get_Ftr (p_at_id, p_nda => 2845)
                       WHEN t.dic_value
                       THEN
                              t.dic_name
                           || ', '
                           || api$act_rpt.Get_Ftr_Nt (p_at_id, p_nda => 2845)
                   END)
          INTO l_str
          FROM uss_ndi.v_ddn_durat_sgn t;

        AddParam ('p2.1_2', Underline (l_str, 1));

        SELECT LISTAGG (t.dic_name, ', ' ON OVERFLOW TRUNCATE '...')
                   WITHIN GROUP (ORDER BY 1)
          INTO l_str
          FROM uss_ndi.V_DDN_SS_CAUSES_DLC t
         WHERE dic_value IN
                   (    SELECT REGEXP_SUBSTR (text,
                                              '[^(\,)]+',
                                              1,
                                              LEVEL)    AS z_rdt_id
                          FROM (SELECT Get_Ftr_Nt (p_at_id, p_nda => 2080)   AS text
                                  FROM DUAL)
                    CONNECT BY LENGTH (REGEXP_SUBSTR (text,
                                                      '[^(\,)]+',
                                                      1,
                                                      LEVEL)) > 0);


        AddParam ('p2.1_3', Underline (l_str, 1));

        AddParam ('p2.1_4-1', Get_Ftr_Chk (p_at_id, p_nda => 2846));
        AddParam ('p2.1_4-2', Get_Ftr_ChkF (p_at_id, p_nda => 2846));

        AddParam ('p2.1_5-1', Get_Ftr_Chk (p_at_id, p_nda => 2847));
        AddParam ('p2.1_5-2', Get_Ftr_ChkF (p_at_id, p_nda => 2847));
        AddParam ('p2.1_6',
                  Underline (Get_Ftr_Nt (p_at_id, p_nda => 2847), 1));

        AddParam ('p2.1_7-1', Get_Ftr_Chk (p_at_id, p_nda => 2849));
        AddParam ('p2.1_7-2', Get_Ftr_ChkF (p_at_id, p_nda => 2849));
        AddParam ('p2.1_8',
                  Underline (Get_Ftr_Nt (p_at_id, p_nda => 2849), 1));

        AddParam ('p2.1_9-1', Get_Ftr_Chk (p_at_id, p_nda => 2851));
        AddParam ('p2.1_9-2', Get_Ftr_ChkF (p_at_id, p_nda => 2851));
        AddParam ('p2.1_10',
                  Underline (Get_Ftr_Nt (p_at_id, p_nda => 2851), 1));
        --2.2. Загроза життю та/або здоров’ю отримувача соціальних послуг
        AddParam ('p2.2_1-1', Get_Ftr_Chk (p_at_id, p_nda => 2853));
        AddParam ('p2.2_1-2', Get_Ftr_ChkF (p_at_id, p_nda => 2853));
        AddParam ('p2.2_2-1', Get_Ftr_Chk (p_at_id, p_nda => 2854));
        AddParam ('p2.2_2-2', Get_Ftr_ChkF (p_at_id, p_nda => 2854));

        --Ознаки, що можуть свідчити про загрозу життю чи здоров’ю NNG = 194
        AddParam ('p2.2_3',
                  TestAtFtrChk (p_at_id, p_nda => '2855,2856,2857,2858,2859'));
        AddParam ('p2.2_3-1', Get_Ftr_Chk (p_at_id, p_nda => 2855));
        AddParam ('p2.2_3-2', Get_Ftr_Chk (p_at_id, p_nda => 2856));
        AddParam ('p2.2_3-3', Get_Ftr_Chk (p_at_id, p_nda => 2857));
        AddParam ('p2.2_3-4', Get_Ftr_Chk (p_at_id, p_nda => 2858));
        AddParam ('p2.2_3-5', Get_Ftr_Chk (p_at_id, p_nda => 2859));
        AddParam ('p2.2_3-5-1',
                  Underline (Get_Ftr_Nt (p_at_id, p_nda => 2859), 1));
        --Отримувач соціальних послуг не може залишити небезпечну територію NNG = 195
        AddParam (
            'p2.2_4',
            TestAtFtrChk (p_at_id, p_nda => '2860,2861,2862,2863,2864,2865'));
        AddParam ('p2.2_4-1', Get_Ftr_Chk (p_at_id, p_nda => 2860));
        AddParam ('p2.2_4-2', Get_Ftr_Chk (p_at_id, p_nda => 2861));
        AddParam ('p2.2_4-3', Get_Ftr_Chk (p_at_id, p_nda => 2862));
        AddParam ('p2.2_4-4', Get_Ftr_Chk (p_at_id, p_nda => 2863));
        AddParam ('p2.2_4-5', Get_Ftr_Chk (p_at_id, p_nda => 2864));
        AddParam ('p2.2_4-6', Get_Ftr_Chk (p_at_id, p_nda => 2865));
        AddParam ('p2.2_4-6-1',
                  Underline (Get_Ftr_Nt (p_at_id, p_nda => 2865), 1));
        --До отримувача соціальних послуг надходять погрози або є ризики надходження погроз
        AddParam (
            'p2.2_5',
            TestAtFtrChk (p_at_id, p_nda => '2866,2867,2868,2869,2870,2871'));
        AddParam ('p2.2_5-1', Get_Ftr_Chk (p_at_id, p_nda => 2866));
        AddParam ('p2.2_5-2', Get_Ftr_Chk (p_at_id, p_nda => 2867));
        AddParam ('p2.2_5-3', Get_Ftr_Chk (p_at_id, p_nda => 2868));
        AddParam ('p2.2_5-4', Get_Ftr_Chk (p_at_id, p_nda => 2869));
        AddParam ('p2.2_5-5', Get_Ftr_Chk (p_at_id, p_nda => 2870));
        AddParam ('p2.2_5-6', Get_Ftr_Chk (p_at_id, p_nda => 2871));
        AddParam ('p2.2_5-6-1',
                  Underline (Get_Ftr_Nt (p_at_id, p_nda => 2871), 1));
        --Отримувач соціальних послуг/ один з членів сім’ї отримувача соціальних послуг постраждав від домашнього насильства
        AddParam ('p2.2_6', TestAtFtrNtChk (p_at_id, p_nda => '2872,2873'));
        AddParam ('p2.2_6-1',
                  Underline (Get_Ftr_Nt (p_at_id, p_nda => 2872), 1));
        AddParam ('p2.2_6-2',
                  Underline (Get_Ftr_Nt (p_at_id, p_nda => 2873), 1));
        --Отримувач соціальних послуг/один з членів сім’ї отримувача соціальних послуг постраждав ід насильства внаслідок воєнних дій
        AddParam ('p2.2_7', TestAtFtrNtChk (p_at_id, p_nda => '2874,2875'));
        AddParam ('p2.2_7-1',
                  Underline (Get_Ftr_Nt (p_at_id, p_nda => 2874), 1));
        AddParam ('p2.2_7-2',
                  Underline (Get_Ftr_Nt (p_at_id, p_nda => 2875), 1));
        --Стан раптового погіршення фізичного або психічного здоров’я, що становить пряму та невідворотну загрозу
        AddParam ('p2.2_8', TestAtFtrNtChk (p_at_id, p_nda => '2876,2877'));
        AddParam ('p2.2_8-1',
                  Underline (Get_Ftr_Nt (p_at_id, p_nda => 2876), 1));
        AddParam ('p2.2_8-2',
                  Underline (Get_Ftr_Nt (p_at_id, p_nda => 2877), 1));
        --Інше
        AddParam ('p2.2_9',
                  Underline (Get_Ftr_Nt (p_at_id, p_nda => 2878), 1));
        --Готовність отримувача соціальних послуг до дій з метою зниження рівня загрози життю
        AddParam ('p2.2_10-1', Get_Ftr_Chk (p_at_id, p_nda => 2879));
        AddParam ('p2.2_10-2', Get_Ftr_ChkF (p_at_id, p_nda => 2879));
        --Примітки щодо готовності
        AddParam ('p2.2_11',
                  Underline (Get_Ftr_Nt (p_at_id, p_nda => 2879), 1));

        --2.3. Інша інформація
        AddParam ('p2.3', Underline (Get_Ftr_Nt (p_at_id, p_nda => 2880), 1));
        --2.4. Ключові потреби отримувача соціальних послуг(зазначити всі актуальні)
        AddParam ('p2.4_1', Get_Ftr_Chk (p_at_id, p_nda => 2881));
        AddParam ('p2.4_3', Get_Ftr_Chk (p_at_id, p_nda => 2883));
        AddParam ('p2.4_5', Get_Ftr_Chk (p_at_id, p_nda => 2885));
        AddParam ('p2.4_7', Get_Ftr_Chk (p_at_id, p_nda => 2887));
        AddParam ('p2.4_9', Get_Ftr_Chk (p_at_id, p_nda => 2889));
        AddParam ('p2.4_11', Get_Ftr_Chk (p_at_id, p_nda => 2891));
        AddParam ('p2.4_13', Get_Ftr_Chk (p_at_id, p_nda => 2893));
        AddParam ('p2.4_15', Get_Ftr_Chk (p_at_id, p_nda => 2895));
        AddParam ('p2.4_17', Get_Ftr_Chk (p_at_id, p_nda => 2897));
        AddParam ('p2.4_19', Get_Ftr_Chk (p_at_id, p_nda => 2899));
        AddParam ('p2.4_19_2',
                  Underline (Get_Ftr_Nt (p_at_id, p_nda => 2899), 1));

        AddParam ('p2.4_2', Get_Ftr_Chk (p_at_id, p_nda => 2882));
        AddParam ('p2.4_4', Get_Ftr_Chk (p_at_id, p_nda => 2884));
        AddParam ('p2.4_6', Get_Ftr_Chk (p_at_id, p_nda => 2886));
        AddParam ('p2.4_8', Get_Ftr_Chk (p_at_id, p_nda => 2888));
        AddParam ('p2.4_10', Get_Ftr_Chk (p_at_id, p_nda => 2890));
        AddParam ('p2.4_12', Get_Ftr_Chk (p_at_id, p_nda => 2892));
        AddParam ('p2.4_14', Get_Ftr_Chk (p_at_id, p_nda => 2894));
        AddParam ('p2.4_16', Get_Ftr_Chk (p_at_id, p_nda => 2896));
        AddParam ('p2.4_18', Get_Ftr_Chk (p_at_id, p_nda => 2898));
        AddParam ('p2.4_20', Get_Ftr_Chk (p_at_id, p_nda => 2900));
        AddParam ('p2.4_20_2',
                  Underline (Get_Ftr_Nt (p_at_id, p_nda => 2900), 1));

        --Інше
        AddParam ('p2.4_21',
                  Underline (Get_Ftr_Nt (p_at_id, p_nda => 2901), 1));

        --2.5. Ресурси отримувача соціальних послуг
        --Досвід переживання подібної ситуації в минулому uss_ndi.V_DDN_THREAT_EXP_SGN
        AddParam ('p2.5_1-1', Get_Ftr_Chk (p_at_id, p_nda => 2848));
        AddParam (
            'p2.5_1-2',
            NVL (
                chk_val ('P', Get_Ftr (p_at_id, p_nda => 2850)),
                NVL (chk_val ('N', Get_Ftr (p_at_id, p_nda => 2850)),
                     chk_val ('O', Get_Ftr (p_at_id, p_nda => 2850)))));

        --якщо "має такий досвід", то вказати який uss_ndi.V_DDN_THREAT_EXP_TP
        AddParam ('p2.5_1-3', chk_val ('P', Get_Ftr (p_at_id, p_nda => 2850)));
        AddParam ('p2.5_1-4', chk_val ('N', Get_Ftr (p_at_id, p_nda => 2850)));
        AddParam ('p2.5_1-5', chk_val ('O', Get_Ftr (p_at_id, p_nda => 2850)));
        AddParam ('p2.5_1-6',
                  Underline (Get_Ftr_Nt (p_at_id, p_nda => 2850), 1));

        --Чи може отримувач СП розраховувати на підтримку та допомогу родичів/близьких? uss_ndi.V_DDN_SS_REL_HLP_SGN
        AddParam ('p2.5_2-1', chk_val ('F', Get_Ftr (p_at_id, p_nda => 2852)));
        AddParam ('p2.5_2-2', chk_val ('T', Get_Ftr (p_at_id, p_nda => 2852)));
        AddParam ('p2.5_2-3', chk_val ('P', Get_Ftr (p_at_id, p_nda => 2852)));
        AddParam ('p2.5_2-4',
                  Underline (Get_Ftr_Nt (p_at_id, p_nda => 2852), 1));
        --Чи готовий до співпраці з фахівцями для подолання кризової ситуації? uss_ndi.V_DDN_SS_REL_HLP_SGN
        AddParam ('p2.5_4-1', chk_val ('F', Get_Ftr (p_at_id, p_nda => 2915)));
        AddParam ('p2.5_4-2', chk_val ('T', Get_Ftr (p_at_id, p_nda => 2915)));
        AddParam ('p2.5_4-3', chk_val ('P', Get_Ftr (p_at_id, p_nda => 2915)));
        AddParam ('p2.5_4-4',
                  Underline (Get_Ftr_Nt (p_at_id, p_nda => 2915), 1));
        --Доходи отримувача соціальних послуг uss_ndi.V_DDN_SS_INCOME_TP
        AddParam ('p2.5_3-1', Get_Ftr_Chk (p_at_id, p_nda => 1494));
        AddParam ('p2.5_3-2', Get_Ftr_Chk (p_at_id, p_nda => 1545));
        AddParam ('p2.5_3-3', Get_Ftr_Chk (p_at_id, p_nda => 1553));
        AddParam ('p2.5_3-4', Get_Ftr_Chk (p_at_id, p_nda => 1573));
        AddParam ('p2.5_3-5', Get_Ftr_Chk (p_at_id, p_nda => 1581));
        AddParam ('p2.5_3-6', Get_Ftr_Chk (p_at_id, p_nda => 1596));
        AddParam ('p2.5_3-7', Get_Ftr_Chk (p_at_id, p_nda => 1637));
        AddParam ('p2.5_3-8', Get_Ftr_Chk (p_at_id, p_nda => 1645));
        AddParam ('p2.5_3-9', Get_Ftr_Chk (p_at_id, p_nda => 2454));
        AddParam ('p2.5_3-10', Get_Ftr_Chk (p_at_id, p_nda => 2455));
        AddParam ('p2.5_3-11', Get_Ftr_Chk (p_at_id, p_nda => 2456));
        AddParam ('p2.5_3-12',
                  Underline (Get_Ftr_Nt (p_at_id, p_nda => 2456), 1));
        --Інші наявні ресурси отримувача
        AddParam ('p2.5_5',
                  Underline (Get_Ftr_Nt (p_at_id, p_nda => 2083), 1));
        --3. Потреба у соціальних послугах екстрено (кризово)

        l_str :=
            q'[
    select
           nst_name as c1,
           nvl(nsa.nsa_name, atip.atip_nsa_hand_name) as c2,
           to_char(atip.atip_start_dt, 'DD.MM.YYYY') || ' - ' || to_char(atip.atip_stop_dt, 'DD.MM.YYYY')/*pr.dic_name*/ as c3,
           atip.atip_desc   as c4
      from
           uss_esr.At_individual_plan atip,
           uss_ndi.v_ndi_service_type nst,
           uss_ndi.v_ndi_nst_activities nsa,
           uss_ndi.v_ddn_atip_period pr
     where 1=1
       and atip.atip_at = :p_at_id
       and atip.history_status = 'A'
       and nst.nst_id = atip.atip_nst
       and nsa.nsa_id(+) = atip.atip_nsa
       and pr.dic_value(+)= atip.atip_period
     order by atip_order
    ]';
        l_str :=
            REGEXP_REPLACE (l_str,
                            ':p_at_id',
                            p_at_id                       /*l_ind_plan_at_id*/
                                   ,
                            1,
                            0,
                            'i');
        rdm$rtfl_univ.AddDataset ('ds3', l_str);

        --Я отримав(ла) та ознайомився(лася) з розділами 1–3
        AddParam (
            'p3_1',
            NVL (Underline (get_at_signers_pers (p_at_id, l_atpO).pib, 1),
                 '________________________________________________________'));
        AddParam (
            'p3_2',
            NVL (Underline (TO_CHAR (c.AT_ACTION_STOP_DT, 'dd.mm.yyyy'), 1),
                 '____  ____________ 20___'));

        --4. Результати роботи
        l_str := q'[
    select
           nst_name/*nsa.nsa_name*/    as c1,
           atr.atr_result  as c2
      from
           uss_esr.at_results atr,
           uss_esr.At_individual_plan atip,
           uss_ndi.v_ndi_service_type nst,
           uss_ndi.v_ndi_nst_activities nsa
     where 1=1
       and atr.atr_at = :p_at_id
       and atip.atip_id = atr.atr_atip
       and atip.history_status = 'A'
       and atr.history_status = 'A'
       and nst.nst_id = atip.atip_nst
       and nsa.nsa_id(+) = atip.atip_nsa
     order by atip_id
    ]';
        l_str :=
            REGEXP_REPLACE (l_str,
                            ':p_at_id',
                            p_at_id,
                            1,
                            0,
                            'i');
        rdm$rtfl_univ.AddDataset ('ds4.1', l_str);

        --У разі переадресації до інших надавачів соціальних послуг
        SELECT LISTAGG (
                      ' '
                   || Get_Nsp_Name (p_rnspm_id => atr.atr_redirect_rnspm)
                   || ' '
                   || nsa.nsa_name
                   || ' '
                   || atr.atr_redirect_else
                   || TO_CHAR (atr.atr_redirect_dt, 'dd.mm.yyyy'),
                   c_chr10)
               WITHIN GROUP (ORDER BY atr.atr_redirect_dt, nsa.nsa_name)    str
          INTO l_str
          FROM uss_esr.at_results            atr,
               uss_esr.At_individual_plan    atip,
               uss_ndi.v_ndi_service_type    nst,
               uss_ndi.v_ndi_nst_activities  nsa
         WHERE     1 = 1
               AND atr.atr_at = p_at_id
               AND atip.atip_id = atr.atr_atip
               AND atip.history_status = 'A'
               AND nst.nst_id = atip.atip_nst
               AND nsa.nsa_id = atip.atip_nsa
               AND atr.atr_redirect_rnspm IS NOT NULL;

        --якщо не стоїть галка на переадресації
        IF NVL (Get_Ftr (p_at_id, p_nda => 2078), 'F') <> 'T'
        THEN
            l_str := NULL;
        END IF;

        AddParam ('p4.1_1', l_str);

        --4.2. Загальна тривалість надання соціальних послуг екстрено (кризово)
        AddParam (
            'p4.2_1',
            Underline (TO_CHAR (c.at_action_start_dt, 'dd.mm.yyyy'), 1));
        AddParam ('p4.2_2',
                  Underline (TO_CHAR (c.at_action_stop_dt, 'dd.mm.yyyy'), 1));

        AddParam ('p4.3_1', Get_Ftr_Chk (p_at_id, p_nda => 2031));
        AddParam ('p4.3_2',
                  Underline (Get_Ftr_Nt (p_at_id, p_nda => 2031), 1));
        AddParam ('p4.3_3', Get_Ftr_Chk (p_at_id, p_nda => 2032));
        AddParam ('p4.3_4',
                  Underline (Get_Ftr_Nt (p_at_id, p_nda => 2032), 1));

        --підписанти
        AddParam ('sgn1', Underline (Get_Ftr_Nt (p_at_id, p_Nda => 8540) /*Get_Km(p_At_Id).position*/
                                                                        , 1)); --Api$act.Get_Signer_Position(c.At_Id, 'PR')); --посада
        AddParam ('sgn2', Underline (c.cu_pib, 1)); --Api$act.Get_At_Spec_Name(c.At_Wu, c.At_Cu)); --l_sing_Pib.Ln||' '||l_sing_Pib.Fn||' '||l_sing_Pib.Mn);
        AddParam ('sgn3', Underline (l_prsO.pib, 1)); --get_at_signers_pers(p_at_id, l_atpO).pib); --Отримувач

        AddParam ('sgn_mark', get_sign_mark (p_at_id, l_atpO, ''));

        ------------------------------------
        rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                         p_rpt_blob   => l_result);
        replace_ekr (l_result);

        RETURN l_result;
    END ACT_DOC_803_R1;

    --#94404 ЩОДЕННИК РОБОТИ з прийомною сім'єю/дитячим будинком сімейного типу
    FUNCTION ACT_DOC_834_R1 (p_at_id IN NUMBER)
        RETURN BLOB
    IS
        l_str      VARCHAR2 (32000);

        l_jbr_id   NUMBER;
        l_result   BLOB;
    BEGIN
        rdm$rtfl_univ.initreport (p_code     => 'ACT_DOC_834_R1',
                                  p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);
        ------------------------------------

        l_str :=
            q'[
    select row_number() over(a.nsa_order) as c1,
           atip.atip_place  as c2, --Дата та місце
           null c3, --Особи, з якими була проведена робота
           a.nsa_name       as c4, --Вжиті заходи
           atip.atip_exprections as c5, --Досягнуті результати
           atip.atip_desc   as c6
      from
           (select * from uss_ndi.v_ndi_service_type t where t.nst_code in ('010.2')) nst,
           uss_ndi.v_ndi_nst_activities a,
           uss_esr.At_individual_plan atip
     where atip.atip_nst = nst.nst_id
       and atip.atip_nsa = a.nsa_id(+)
       and atip.history_status = 'A'
       and atip.atip_at = :p_at_id
    order by c1
    ]';
        l_str :=
            REGEXP_REPLACE (l_str,
                            ':p_at_id',
                            p_at_id,
                            1,
                            0,
                            'i');
        rdm$rtfl_univ.AddDataset ('ds', l_str);


        ------------------------------------
        rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                         p_rpt_blob   => l_result);
        replace_ekr (l_result);

        RETURN l_result;
    END;

    --#91350 ndt = 837 «Карта визначення індивідуальних потреб особи в наданні СП консультування»
    FUNCTION ACT_DOC_837_R1 (p_at_id IN NUMBER)
        RETURN BLOB
    IS
        --select t.*, rowid from uss_esr.rpt_templates t where t.rt_code = 'BUILD_ACT_KARD_R2';

        CURSOR c_at IS
            SELECT a.at_ap,
                   a.at_pc,
                   a.at_org,
                   a.at_dt,
                   a.at_action_start_dt,
                   a.at_action_stop_dt,
                   a.at_family_info,
                   a.at_live_address,
                   a.at_case_class,
                   a.at_cu,
                   a.at_rnspm,
                   sc.sc_unique,
                   p.atp_id,
                   pc.pc_sc,
                   p.Atp_App_Tp,
                   ikis_rbm.tools.GetCuPib (a.at_cu)     AS cu_pib
              FROM uss_esr.act              a,
                   uss_esr.personalcase     pc,
                   uss_esr.At_Person        p,
                   uss_person.v_socialcard  sc
             WHERE     a.at_id = p_at_id
                   AND pc.pc_id = a.at_pc
                   AND p.atp_at = a.at_id
                   AND p.atp_sc = pc.pc_sc
                   AND sc.sc_id = a.at_sc;

        l_at       c_at%ROWTYPE;

        --підписанти Інші спеціалісти
        CURSOR c_spc (p_tp VARCHAR2)
        IS
            SELECT s.atop_ln || ' ' || s.atop_fn || ' ' || s.atop_mn
                       pib,
                      s.atop_ln
                   || ' '
                   || SUBSTR (s.atop_fn, 1, 1)
                   || '. '
                   || SUBSTR (s.atop_mn, 1, 1)
                   || '.'
                       pib_shot,
                   s.*
              FROM uss_esr.at_other_spec s, Uss_Ndi.v_ddn_atop_apop_tp tp
             WHERE     s.atop_at = p_at_id
                   AND s.atop_tp = tp.dic_value
                   AND tp.dic_value = p_tp
                   AND s.history_status = 'A';

        r_spc      c_spc%ROWTYPE;

        --l_atp_O  number:= get_AtPerson_id(p_at_id, 'OS'); --отримувач
        l_prs      R_Person_for_act;

        l_jbr_id   NUMBER;
        l_result   BLOB;
        l_str      VARCHAR2 (4000);
    BEGIN
        rdm$rtfl_univ.initreport (p_code     => 'ACT_DOC_837_R1',
                                  p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);

        OPEN c_at;

        FETCH c_at INTO l_at;

        CLOSE c_at;

        --l_prs:= get_AtPerson(p_at => p_at_id, p_atp => l_atp_O);
        l_prs := get_AtPerson (p_at => p_at_id, p_atp => l_at.atp_id);

        addparam ('p1', Get_Nsp_Name (p_rnspm_id => l_at.at_rnspm)); --надавач послуги
        addparam ('p2', Date2Str (l_at.at_dt));
        --отримувач
        addparam ('p3', l_prs.Pib);
        addparam ('p4', l_prs.birth_dt_str);
        addparam (
            'p5',
               NVL (l_at.at_live_address, l_prs.live_address)
            || CASE WHEN l_prs.phone IS NOT NULL THEN ', ' || l_prs.phone END);

        addparam ('p7', Get_Ftr_Chk (p_at_id, p_nda => 3502));
        addparam ('p8', Get_Ftr_Chk (p_at_id, p_nda => 3504));
        addparam ('p9', Get_Ftr_Nt (p_at_id, p_nda => 3504));
        addparam ('p10', Get_Ftr_Chk (p_at_id, p_nda => 3505));
        addparam ('p11', Get_Ftr_Nt (p_at_id, p_nda => 3505));
        addparam ('p12', Get_Ftr_Chk (p_at_id, p_nda => 3507));
        addparam ('p13', Get_Ftr_Nt (p_at_id, p_nda => 3507));
        --ІІ. Потреба отримувача в соціальній послузі консультування
        addparam ('p14', Get_Ftr_Nt (p_at_id, p_nda => 3508));
        l_str := Get_Ftr_Nt (p_at_id, p_nda => 3509);
        addparam ('p15', CASE WHEN l_str IS NOT NULL THEN '2. ' || l_str END);
        l_str := Get_Ftr_Nt (p_at_id, p_nda => 3511);
        addparam ('p16', CASE WHEN l_str IS NOT NULL THEN '3. ' || l_str END);
        --ІІІ. Види та обсяг консультування
        addparam ('p17', Get_Ftr_Chk (p_at_id, p_nda => 3510));
        addparam ('p18', Get_Ftr_Nt (p_at_id, p_nda => 3510));
        addparam ('p19', Get_Ftr_Chk (p_at_id, p_nda => 3512));
        addparam ('p20', Get_Ftr_Nt (p_at_id, p_nda => 3512));
        addparam ('p21', Get_Ftr_Chk (p_at_id, p_nda => 3514));
        addparam ('p22', Get_Ftr_Nt (p_at_id, p_nda => 3514));
        addparam ('p23', Get_Ftr_Chk (p_at_id, p_nda => 3516));
        addparam ('p24', Get_Ftr_Nt (p_at_id, p_nda => 3516));
        addparam ('p25', Get_Ftr_Chk (p_at_id, p_nda => 3518));
        addparam ('p26', Get_Ftr_Nt (p_at_id, p_nda => 3518));
        --ІV. Методи консультування
        addparam ('p27', Get_Ftr_Chk (p_at_id, p_nda => 3520));
        addparam ('p28', Get_Ftr_Chk (p_at_id, p_nda => 3521));
        addparam ('p29', Get_Ftr_Chk (p_at_id, p_nda => 3522));
        --V. Форми консультування
        addparam ('p30', Get_Ftr_Chk (p_at_id, p_nda => 3524));
        addparam ('p31', Get_Ftr_Chk (p_at_id, p_nda => 3525));
        addparam ('p32', Get_Ftr_Chk (p_at_id, p_nda => 3526));
        --VІ. Потреба в залученні інших фахівців
        addparam ('p33', Get_Ftr_Chk (p_at_id, p_nda => 3527));
        addparam ('p34', Get_Ftr_Chk (p_at_id, p_nda => 3528));
        addparam ('p35', Get_Ftr_Chk (p_at_id, p_nda => 3529));
        addparam ('p36', Get_Ftr_Chk (p_at_id, p_nda => 3530));
        addparam ('p37', Get_Ftr_Nt (p_at_id, p_nda => 3530));
        --VІІ. Висновки
        addparam ('p38', Get_Ftr_Nt (p_at_id, p_nda => 3532));
        --підпис
        --open c_spc('CM'); fetch c_spc into r_spc; close c_spc;
        --addparam('p39', r_spc.pib_shot);
        addparam ('p39', l_at.cu_pib);

        --результуючий blob
        rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                         p_rpt_blob   => l_result);

        replace_ekr (l_result);

        RETURN l_result;
    END ACT_DOC_837_R1;

    --#92242 «Анкета вуличного консультування»
    FUNCTION ACT_DOC_838_R1 (p_at_id IN NUMBER)
        RETURN BLOB
    IS
        CURSOR c_prs IS
            SELECT p.atp_ln || ' ' || p.atp_fn || ' ' || p.atp_mn
                       pib,
                   p.*,
                      p.atp_ln
                   || ' '
                   || SUBSTR (p.atp_fn, 1, 1)
                   || '. '
                   || SUBSTR (p.atp_mn, 1, 1)
                   || '. '
                       pib_short,
                   a.at_action_stop_dt,
                   ikis_rbm.tools.GetCuPib (a.at_cu)
                       AS cu_pib
              FROM act a, uss_esr.at_person p
             WHERE     a.at_id = p_at_id
                   AND p.atp_at = a.at_id
                   AND p.history_status = 'A'
                   AND p.atp_sc = a.at_sc;

        p          c_prs%ROWTYPE;


        l_jbr_id   NUMBER;
        l_result   BLOB;
    BEGIN
        rdm$rtfl_univ.initreport (p_code     => 'ACT_DOC_838_R1',
                                  p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);

        ------------------------------------
        OPEN c_prs;

        FETCH c_prs INTO p;

        CLOSE c_prs;

        addparam ('p1', p.pib);
        addparam ('p2', TO_DATE (p.atp_birth_dt, 'dd.mm.yyyy'));
        addparam ('p3', Get_Ftr_Nt (p_at_id, p.atp_id, 3547));
        addparam ('p4', Get_Ftr_Nt (p_at_id, p.atp_id, 3548));
        addparam ('p5', Get_Ftr_Nt (p_at_id, p.atp_id, 3549));
        addparam ('p6', Get_Ftr_Nt (p_at_id, p.atp_id, 3550));
        addparam ('p7', p.atp_citizenship /*Get_Ftr_Nt(p_at_id, p.atp_id, p.atp_citizenship)*/
                                         );
        addparam (
            'p8',
               Get_Ftr_Nt (p_at_id, p.atp_id, 3552)
            || ' '
            || Get_Ftr_Nt (p_at_id, p.atp_id, 3553));
        addparam ('p9', Get_Ftr_Nt (p_at_id, p.atp_id, 3554));
        addparam ('p10', p.atp_live_address); --Попередня реєстрація місця проживання/перебування
        addparam ('p11', Get_Ftr_Chk (p_at_id, p.atp_id, 3565));
        addparam ('p12', Get_Ftr_Nt (p_at_id, p.atp_id, 3567));
        addparam ('p13', Get_Ftr_Nt (p_at_id, p.atp_id, 3568));
        addparam (
            'p14',
            NVL (p.atp_work_place, Get_Ftr_Nt (p_at_id, p.atp_id, 8615))); --Останнє місце роботи (коли звільнений(а), причина звільнення)
        addparam ('p15', Get_Ftr_Nt (p_at_id, p.atp_id, 3572));
        addparam ('p16', Get_Ftr_Nt (p_at_id, p.atp_id, 3573));
        addparam ('p17', Get_Ftr_Nt (p_at_id, p.atp_id, 3574));
        addparam ('p18', Get_Ftr_Nt (p_at_id, p.atp_id, 3575));
        addparam ('p19', Get_Ftr_Nt (p_at_id, p.atp_id, 3576));
        addparam ('p20', Get_Ftr_Nt (p_at_id, p.atp_id, 3577));
        --Досвід звернення до закладів/установ/організацій щодо отримання допомоги (коли, куди, результат)
        addparam (
            'p21',
            RTRIM (
                   Get_Ftr_Nt (p_at_id, p.atp_id, 3579)
                || '; '
                || Get_Ftr_Nt (p_at_id, p.atp_id, 3578)
                || '; '
                || Get_Ftr_Nt (p_at_id, p.atp_id, 3580),
                '; '));
        --Чи є клієнтом закладу для бездомних осіб (якого, послуги,  періодичність тощо
        addparam (
            'p22',
            RTRIM (              --Get_Ftr_Nt(p_at_id, p.atp_id, 3581)||', '||
                   uss_rnsp.api$find.Get_Nsp_Name (
                       Get_Ftr (p_at_id, p.atp_id, 3582))
                || '; '
                || CASE
                       WHEN Get_Ftr_Nt (p_at_id, p.atp_id, 3583) IS NOT NULL
                       THEN
                              'послуги: '
                           || get_nst (Get_Ftr_Nt (p_at_id, p.atp_id, 3583))
                           || '; '
                   END
                || Get_Ftr_Nt (p_at_id, p.atp_id, 3584)
                || '; '
                || Get_Ftr_Nt (p_at_id, p.atp_id, 3585),
                '; '));
        addparam ('p23', Get_Ftr_Nt (p_at_id, p.atp_id, 3586));

        AddParam (
            'p_dt',
            NVL (Underline (TO_CHAR (p.at_action_stop_dt, 'DD.MM.YYYY'), 1),
                 '____ _____________ ____'));
        AddParam (
            'pib',
            NVL (Underline (p.cu_pib, 1),
                 '__________________________________'));

        AddParam ('osp_pib',
                  NVL (Underline (p.pib, 2), '________________________'));
        AddParam ('sign_1',
                  api$act_rpt.get_sign_mark (p_at_id, p.atp_id, '_________'));

        ------------------------------------
        rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                         p_rpt_blob   => l_result);
        replace_ekr (l_result);

        RETURN l_result;
    END;

    --#93919 «Направлення сім`ї/особи до іншого суб’єкта для надання соціальних послуг»
    FUNCTION ACT_DOC_840_R1 (p_at_id IN NUMBER)
        RETURN BLOB
    IS
        --uss_esr.CMES$ACT_NDIS

        CURSOR c_act IS
            SELECT a.At_Id,
                   a.at_num,
                   a.at_dt,
                   a.at_org,
                   a.At_rnspm,
                   a.at_redirect_rnspm,
                   a.at_sc,
                   a.At_Wu,
                   a.at_cu,
                   sc.sc_unique,
                   p.atp_birth_dt
              FROM uss_esr.act              a,
                   uss_person.v_socialcard  sc,
                   uss_esr.At_Person        p
             WHERE     a.at_id = p_at_id
                   AND sc.sc_id = a.at_sc
                   AND p.atp_at = a.at_id
                   AND p.atp_sc = sc.sc_id;

        c          c_act%ROWTYPE;

        l_jbr_id   NUMBER;
        l_result   BLOB;
    BEGIN
        rdm$rtfl_univ.initreport (p_code     => 'ACT_DOC_840_R1',
                                  p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);

        ------------------------------------
        OPEN c_act;

        FETCH c_act INTO c;

        CLOSE c_act;

        AddParam ('p1', Get_Nsp_Name (p_rnspm_id => c.at_rnspm)); --tools.GetOrgName(c.at_org));  --найменування суб’єкта, який направляє)
        AddParam ('p2', Get_Nsp_Name (p_rnspm_id => c.at_redirect_rnspm)); --новий надавач соцпослуг
        AddParam ('p3', c.at_num);
        AddParam ('p4', Date2Str (c.at_dt));
        AddParam ('p5', GetScPIB (c.At_Sc));           --Сім’я/особа отримувач
        AddParam (
            'p6',
            NVL (TO_CHAR (c.atp_birth_dt, 'dd.mm.yyyy'),
                 '____  ____________ 20___'));
        AddParam ('p7', c.sc_unique);
        AddParam ('p8', AtDocAtrStr (p_at_id, p_nda => 4356)); --У зв’язку зі складною життєвою ситуацією
        AddParam ('p9', Get_Nsp_Name (p_rnspm_id => c.at_rnspm)); --tools.GetOrgName(c.at_org));               --найменування суб’єкта, який направляє)
        AddParam ('p10', AtDocAtrStr (p_at_id, p_nda => 4354)); --Додаткова інформація про сім’ю/
        AddParam ('p11', AtDocAtrStr (p_at_id, p_nda => 4355)); --Додаткова інформація про послуги/виплати,
        --підпис
        AddParam ('p12', AtDocAtrStr (p_at_id, p_nda => 8330)); --Api$act.Get_Signer_Position(c.At_Id, 'PR')); --посада
        AddParam ('p13', At_Doc_Atr_Lst (p_at_id, '8331,8332')); --Api$act.Get_At_Spec_Name(c.At_Wu, c.At_Cu));
        AddParam ('p14', NVL (Date2Str (c.at_dt), c_date_empty));

        ------------------------------------
        rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                         p_rpt_blob   => l_result);
        replace_ekr (l_result);

        RETURN l_result;
    END ACT_DOC_840_R1;

    --#94121 «Акт з надання соціальної послуги кризового та екстреного втручання» для послуги 012.0
    FUNCTION ACT_DOC_841_R1 (p_at_id IN NUMBER)
        RETURN BLOB
    IS
        CURSOR c_act IS
            SELECT p.atp_id,
                   a.At_Id,
                   a.at_num,
                   a.at_dt,
                   a.at_org,
                   a.At_rnspm,
                   at_action_start_dt,
                   at_action_stop_dt,
                   a.at_sc,
                   a.At_Wu,
                   a.at_cu
              FROM uss_esr.act              a,
                   uss_person.v_socialcard  sc,
                   uss_esr.At_Person        p
             WHERE     a.at_id = p_at_id
                   AND sc.sc_id = a.at_sc
                   AND p.atp_at = a.at_id
                   AND p.atp_sc = sc.sc_id;

        c          c_act%ROWTYPE;

        l_str      VARCHAR2 (32000);

        l_jbr_id   NUMBER;
        l_result   BLOB;
    BEGIN
        rdm$rtfl_univ.initreport (p_code     => 'ACT_DOC_841_R1',
                                  p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);

        ------------------------------------
        OPEN c_act;

        FETCH c_act INTO c;

        CLOSE c_act;

        AddParam ('p1', UnderLine (GetScPIB (c.At_Sc), 1));        --отримувач
        AddParam ('p2', TO_CHAR (c.at_action_start_dt, 'dd.mm.yyyy'));
        AddParam ('p3', TO_CHAR (c.at_action_stop_dt, 'dd.mm.yyyy'));

        /*l_str:= q'[
          select
                 atip.atip_exprections as c1,
                 nsa.nsa_name          as c2,
                 nsa2.nsa_name         as c3,
                 atip.atip_resources   as c4,
                 atip.atip_desc        as c5
            from
                 uss_esr.at_results atr,
                 uss_esr.At_individual_plan atip,
                 uss_ndi.v_ndi_service_type nst,
                 uss_ndi.v_ndi_nst_activities nsa,
                 uss_ndi.v_ndi_nst_activities nsa2
           where 1=1
             and atr.atr_at = :p_at_id
             and atip.atip_id = atr.atr_atip
             and atip.history_status = 'A'
             and nst.nst_id = atip.atip_nst
             and nsa.nsa_id = atip.atip_nsa
             and nsa2.nsa_id = atip.atip_nsa_det
           order by nsa.nsa_name
          ]';*/
        l_str := q'[
    select
           atip.atip_exprections     as c1,
           atip.atip_nsa_hand_name   as c2,
           nsa.nsa_name              as c3,
           atip.atip_resources       as c4,
           atip.atip_desc            as c5
      from
           uss_esr.At_individual_plan atip,
           uss_ndi.v_ndi_service_type nst,
           uss_ndi.v_ndi_nst_activities nsa
     where 1=1
       and atip_at = :p_at_id
       and atip.history_status = 'A'
       and nst.nst_id(+) = atip.atip_nst
       and nsa.nsa_id = atip.atip_nsa_det
     order by nsa.nsa_name
    ]';
        l_str :=
            REGEXP_REPLACE (l_str,
                            ':p_at_id',
                            p_at_id,
                            1,
                            0,
                            'i');
        rdm$rtfl_univ.AddDataset ('ds1', l_str);

        --Суб’єкти, залучені до надання соціальної послуги
        l_str := q'[
    select s.atop_ln||' '||s.atop_fn||' '||s.atop_mn c1, s.atop_phone c2
      from uss_esr.v_at_other_spec s
     where s.atop_at = :p_at_id
       and s.history_status = 'A'
       and s.atop_tp = 'OC'
    ]';
        l_str := REPLACE (l_str, ':p_at_id', p_at_id);
        rdm$rtfl_univ.AddDataset ('ds2', l_str);

        AddParam ('sng1', UnderLine (GetScPIB (c.At_Sc), 1));      --отримувач
        AddParam (
            'sng2',
            NVL (UnderLine (Date2Str (c.at_dt), 1),
                 '____  ________________20_____'));

        addparam ('sgn_3',
                  get_sign_mark (p_at_id, c.atp_id, '_____________________'));
        ------------------------------------
        rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                         p_rpt_blob   => l_result);
        replace_ekr (l_result);

        RETURN l_result;
    END ACT_DOC_841_R1;

    --#91757 «Повідомлення надавача про надання / відмову в наданні соціальних послуг»  (з автозаповнення)
    FUNCTION ACT_DOC_843_old (p_at_id IN NUMBER)
        RETURN BLOB
    IS
        l_sql      VARCHAR2 (32000);

        l_jbr_id   NUMBER;
        l_result   BLOB;
    BEGIN
        --check_at_signed_docs(p_at_id => p_at_id, p_ndt_id => 843);

        rdm$rtfl_univ.initreport (p_code     => 'ACT_DOC_843_R1',
                                  p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);
        --------------------------------------------------------
        AddParam ('p1', At_Doc_Atr_Lst (p_at_id, '3665,3666,3667')); --ПІБ заявника
        AddParam ('p2',
                  Get_adr (p_ind     => AtDocAtrStr (p_at_id, 3669),
                           p_katot   => AtDocAtrStr (p_at_id, 3668),
                           p_strit   => AtDocAtrStr (p_at_id, 3670),
                           p_bild    => AtDocAtrStr (p_at_id, 3671),
                           p_korp    => AtDocAtrStr (p_at_id, 3672),
                           p_kv      => AtDocAtrStr (p_at_id, 3673))); -- адреса
        AddParam ('p3', AtDocAtrStr (p_at_id, 3659)); --Найменування надавача соціальних послуг
        AddParam ('p4', AtDocAtrStr (p_at_id, 3660)); --Назва розпорядчого документу
        AddParam ('p5', AtDocAtrDt (p_at_id, 3662));
        AddParam ('p6', AtDocAtrStr (p_at_id, 3661));

        --рішення про #p7#надання / відмову
        AddParam (
            'p7',
            CASE
                WHEN     AtSrv_Nst_List (p_at_id, 1) IS NOT NULL
                     AND AtSrv_Nst_List (p_at_id, 0) IS NULL
                THEN
                    '\ulнадання\ul0 / відмову в наданні' --надати соціальну послугу
                WHEN     AtSrv_Nst_List (p_at_id, 1) IS NULL
                     AND AtSrv_Nst_List (p_at_id, 0) IS NOT NULL
                THEN
                    'надання / \ulвідмову в наданні\ul0'           --відмовити
                ELSE
                    'надання / відмову в наданні' --монета встала на ребро, не можемо визначитись...
            END);            -- прийняте рішення uss_ndi.V_DDN_RNSP_PROVIDE_SS

        l_sql :=
            q'[
    select
          nst_name,
          uss_esr.dnet$pd_reports.chk_val('F', tp) p8_1,
          uss_esr.dnet$pd_reports.chk_val('C', tp) p8_2,
          uss_esr.dnet$pd_reports.chk_val('D', tp) p8_3
     from
         (select s.ats_st, nst.nst_name,
                 case (select max(l.arl_nrr) from uss_esr.at_right_log l where l.arl_at = s.ats_at
                          and l.arl_ats = s.ats_id and l.arl_nrr in (222,224,225) and l.arl_result = 'T')
                      when 222 then 'F'-- безоплатно
                      when 224 then 'C'-- платно
                      when 225 then 'D'-- діф.плата
                 end tp
            from uss_esr.at_service s, uss_ndi.v_ndi_service_type nst
           where s.ats_at = #p_at_id# and s.history_status = 'A' and nst.nst_id = s.ats_nst
             and s.ats_st in ('PP', 'SG', 'P', 'R')
          )
  ]';
        l_sql := REPLACE (l_sql, '#p_at_id#', p_at_id);
        rdm$rtfl_univ.AddDataset ('ds', l_sql);

        AddParam ('p8', AtDocAtrStr (p_at_id, NULL));

        AddParam ('p9', At_Doc_Atr_Lst (p_at_id, '3674,3675,3676')); --прізвище отримувача
        --cпосіб надання соціальних послуг
        AddParam ('p10_1', chk_val ('F', AtDocAtrStr (p_at_id, 3677)));
        AddParam ('p10_2', chk_val ('C', AtDocAtrStr (p_at_id, 3677)));
        AddParam ('p10_3', chk_val ('D', AtDocAtrStr (p_at_id, 3677)));

        AddParam ('p11', AtDocAtrStr (p_at_id, 3678));       --Причина відмови

        AddParam ('p12', AtDocAtrStr (p_at_id, 3679));     --Посада підписанта
        AddParam ('p15', At_Doc_Atr_Lst (p_at_id, '3680,3681,3682')); --ПІБ директора
        -----------------------------------------
        rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                         p_rpt_blob   => l_result);
        replace_ekr (l_result);

        RETURN l_result;
    END ACT_DOC_843_old;

    --#96292 «Повідомлення надавача про надання / відмову в наданні соціальних послуг»  (з автозаповнення)
    FUNCTION ACT_DOC_843_R2 (p_at_id IN NUMBER)
        RETURN BLOB
    IS
        l_str      VARCHAR2 (32000);

        l_jbr_id   NUMBER;
        l_result   BLOB;
    BEGIN
        rdm$rtfl_univ.initreport (p_code     => 'ACT_DOC_843_R2',
                                  p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);
        --------------------------------------------------------
        AddParam ('p1', At_Doc_Atr_Lst (p_at_id, '3665,3666,3667')); --ПІБ заявника
        AddParam ('p2',
                  Get_adr (p_ind     => AtDocAtrStr (p_at_id, 3669),
                           p_katot   => AtDocAtrStr (p_at_id, 3668),
                           p_strit   => AtDocAtrStr (p_at_id, 3670),
                           p_bild    => AtDocAtrStr (p_at_id, 3671),
                           p_korp    => AtDocAtrStr (p_at_id, 3672),
                           p_kv      => AtDocAtrStr (p_at_id, 3673))); -- адреса
        AddParam ('p3', AtDocAtrStr (p_at_id, 3659)); --Найменування надавача соціальних послуг
        AddParam ('p4', AtDocAtrStr (p_at_id, 3660)); --Назва розпорядчого документу
        AddParam ('p5', AtDocAtrDt (p_at_id, 3662));
        AddParam ('p6', AtDocAtrStr (p_at_id, 3661));
        AddParam ('p7', At_Doc_Atr_Lst (p_at_id, '3674,3675,3676')); --прізвище отримувача

        --1) про надання соціальних послуг
        l_str := q'[
    select  row_number() over(order by nst.nst_order)  as rn,
            nst.nst_name                               as c1,
            --Uss_Ndi.v_Ddn_Ss_Method
            Api$Act_Rpt.chk_val2(s.Ats_ss_method, 'F') as c2,
            Api$Act_Rpt.chk_val2(s.Ats_ss_method, 'C') as c3,
            Api$Act_Rpt.chk_val2(s.Ats_ss_method, 'D') as c4
    from uss_esr.at_service s,
         Uss_Ndi.v_Ndi_Service_Type nst
   where 1=1
     and s.history_status = 'A'
     and s.ats_st in ('PP', 'SG', 'P', 'R')
     and nst.nst_id = s.ats_nst
     and s.ats_at = :p_at_id
   order by rn
  ]';
        l_str :=
            REGEXP_REPLACE (l_str,
                            ':p_at_id',
                            p_at_id,
                            1,
                            0,
                            'i');
        rdm$rtfl_univ.AddDataset ('ds', l_str);

        --2) про відмову в наданні соціальних послуг:
        AddParam ('p10', AtSrv_Nst_List (p_at_id, 0, '; ' || c_chr10));
        AddParam ('p11', AtDocAtrStr (p_at_id, 3678));       --Причина відмови

        AddParam ('p12', AtDocAtrStr (p_at_id, 3679));     --Посада підписанта
        AddParam ('p13', At_Doc_Atr_Lst (p_at_id, '3680,3681,3682')); --ПІБ директора
        AddParam (
            'p15',
            NVL (Date2Str (AtDocAtr (p_at_id, 5348).atda_val_dt),
                 c_date_empty));

        -----------------------------------------
        rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                         p_rpt_blob   => l_result);
        replace_ekr (l_result);

        RETURN l_result;
    END ACT_DOC_843_R2;

    --#93370 «Оцінка кризової ситуації СП кризового та екстреного втручання» USS_ESR.Cmes$act_Oks
    FUNCTION ACT_DOC_845_R1 (p_at_id IN NUMBER)
        RETURN BLOB
    IS
        CURSOR c_act IS
            SELECT a.at_num,
                   a.at_dt,
                   a.At_rnspm,
                   a.at_sc,
                   a.at_cu,
                   a.at_live_address,
                   a.At_action_start_dt,
                   a.At_action_stop_dt
              FROM uss_esr.act a
             WHERE a.at_id = p_at_id;

        c          c_act%ROWTYPE;

        l_atp_O    NUMBER := get_AtPerson_id (p_at_id, 'OS');      --отримувач
        l_prs_O    R_Person_for_act := get_AtPerson (p_at_id, l_atp_O);
        --l_atp_7  number:= get_AtPerson_id(p_at => p_at_id, p_App_Tp => '???', p_App_Tp_only => 1); --П. І. Б. особи, що звернулась/повідомила про кризову ситуацію:
        --l_prs_7  R_Person_for_act:= get_AtPerson(p_at_id, l_atp_7);

        l_str      VARCHAR2 (32000);

        l_jbr_id   NUMBER;
        l_result   BLOB;

        FUNCTION AtFtrChkT (p_at_id   act.at_id%TYPE,
                            p_atp     at_person.atp_id%TYPE:= -1,
                            p_nda     NUMBER,
                            p_nng     NUMBER:= -1)
            RETURN VARCHAR2
        IS
        BEGIN
            IF Get_Ftr_Chk (p_at_id   => p_at_id,
                            p_atp     => p_atp,
                            p_nda     => p_nda,
                            p_nng     => p_nng)
                   IS NOT NULL
            THEN
                RETURN 'Так';
            ELSE
                RETURN NULL;
            END IF;
        END;

        FUNCTION AtFtrChkF (p_at_id   act.at_id%TYPE,
                            p_atp     at_person.atp_id%TYPE:= -1,
                            p_nda     NUMBER,
                            p_nng     NUMBER:= -1)
            RETURN VARCHAR2
        IS
        BEGIN
            IF Get_Ftr_ChkF (p_at_id   => p_at_id,
                             p_atp     => p_atp,
                             p_nda     => p_nda,
                             p_nng     => p_nng)
                   IS NOT NULL
            THEN
                RETURN 'Ні';
            ELSE
                RETURN NULL;
            END IF;
        END;
    BEGIN
        rdm$rtfl_univ.initreport (p_code     => 'ACT_DOC_845_R1',
                                  p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);

        ------------------------------------
        OPEN c_act;

        FETCH c_act INTO c;

        CLOSE c_act;

        AddParam ('p1', Get_Nsp_Name (p_rnspm_id => c.At_rnspm)); --надавач соцпослуг

        /*select listagg(p.atp_ln||' '||p.atp_fn||' '||p.atp_mn, c_chr10) within group(order by p.atp_ln) pib
          into l_str
          from uss_esr.at_person p where p.atp_at = p_at_id and p.atp_app_tp = '????';*/
        /*select listagg(s.atop_ln||' '||s.atop_fn||' '||s.atop_mn ||', '||s.atop_position, c_chr10)
                 within group(order by s.atop_ln) pib
          into l_str
          from uss_esr.at_other_spec s
         where s.atop_at = p_at_id and s.history_status = 'A'
           and s.atop_tp = 'OC';*/

        SELECT MAX (u.cu_pib)
          INTO l_str
          FROM act t JOIN ikis_rbm.v_cmes_users u ON (u.cu_id = t.at_cu)
         WHERE t.at_id = p_at_id;

        AddParam ('p2', l_str); --Посади та П. І. Б. спеціалістів, які заповнюють цю форму:
        AddParam ('p3',
                  TO_CHAR (c.At_action_start_dt, 'dd.mm.yyyy hh24:mi:ss'));
        AddParam ('p4',
                  TO_CHAR (c.At_action_stop_dt, 'dd.mm.yyyy hh24:mi:ss'));
        AddParam ('p5', l_prs_O.pib);
        AddParam ('p6', c.at_live_address);
        AddParam ('p7', Get_Ftr_Nt (p_at_id, p_nda => 2079)); --l_prs_7.pib);   --П. І. Б. особи, що звернулась/повідомила про кризову ситуацію:
        AddParam ('p8', Get_Ftr_Nt (p_at_id, p_nda => 4190));
        AddParam ('p9_1', Get_Ftr_Chk (p_at_id, p_nda => 4191));         --так
        AddParam ('p9_2', Get_Ftr_ChkF (p_at_id, p_nda => 4191));         --ні
        --Стислий виклад проблеми/кризової ситуації зі слів отримувача соціальної послуги:
        AddParam ('p10', Get_Ftr_Nt (p_at_id, p_nda => 4192));
        AddParam ('p10_1', Get_Ftr_Nt (p_at_id, p_nda => 4193));
        AddParam ('p10_2', Get_Ftr_Nt (p_at_id, p_nda => 4194));
        AddParam ('p10_3', Get_Ftr_Nt (p_at_id, p_nda => 4195));
        AddParam ('p10_4', Get_Ftr_Nt (p_at_id, p_nda => 4196));
        AddParam ('p11', get_AtSctNt (p_at_id, p_nng => 177));     --Коментарі
        AddParam ('p12', Get_Ftr_Nt (p_at_id, p_nda => 4197));
        --Чи існує загроза життю або здоров’ю отримувача соціальної послуги
        AddParam ('p13_1', Get_Ftr_Chk (p_at_id, p_nda => 4198));        --так
        AddParam ('p13_2', Get_Ftr_ChkF (p_at_id, p_nda => 4198));        --ні
        AddParam ('p14_1', Get_Ftr_Chk (p_at_id, p_nda => 4199));        --так
        AddParam ('p14_2', Get_Ftr_ChkF (p_at_id, p_nda => 4199));        --ні
        --Висновки надавача соціальної послуги:
        AddParam ('p15_1', Get_Ftr_Chk (p_at_id, p_nda => 4200));
        AddParam ('p15_2', Get_Ftr_Chk (p_at_id, p_nda => 4201));
        --AddParam('p15_3', Get_Ftr_Chk (p_at_id, p_nda => 4202));
        AddParam ('p15_3', Get_Ftr_Nt (p_at_id, p_nda => 4202));
        AddParam ('p15_4', get_AtSctNt (p_at_id, p_nng => 179));
        --Потреби у терміновій кризовій допомозі:
        AddParam ('p16_1', AtFtrChkT (p_at_id, p_nda => 4203));
        AddParam ('p16_2', AtFtrChkF (p_at_id, p_nda => 4203));
        AddParam ('p16_3', Get_Ftr_Nt (p_at_id, p_nda => 4203));
        AddParam ('p17_1', AtFtrChkT (p_at_id, p_nda => 4204));
        AddParam ('p17_2', AtFtrChkF (p_at_id, p_nda => 4204));
        AddParam ('p17_3', Get_Ftr_Nt (p_at_id, p_nda => 4204));
        AddParam ('p18_1', AtFtrChkT (p_at_id, p_nda => 4205));
        AddParam ('p18_2', AtFtrChkF (p_at_id, p_nda => 4205));
        AddParam ('p18_3', Get_Ftr_Nt (p_at_id, p_nda => 4205));
        AddParam ('p19_1', AtFtrChkT (p_at_id, p_nda => 4206));
        AddParam ('p19_2', AtFtrChkF (p_at_id, p_nda => 4206));
        AddParam ('p19_3', Get_Ftr_Nt (p_at_id, p_nda => 4206));
        AddParam ('p20_1', AtFtrChkT (p_at_id, p_nda => 4207));
        AddParam ('p20_2', AtFtrChkF (p_at_id, p_nda => 4207));
        AddParam ('p20_3', Get_Ftr_Nt (p_at_id, p_nda => 4207));
        AddParam ('p21_1', AtFtrChkT (p_at_id, p_nda => 4208));
        AddParam ('p21_2', AtFtrChkF (p_at_id, p_nda => 4208));
        AddParam ('p21_3', Get_Ftr_Nt (p_at_id, p_nda => 4208));
        AddParam ('p22_1', AtFtrChkT (p_at_id, p_nda => 4209));
        AddParam ('p22_2', AtFtrChkF (p_at_id, p_nda => 4209));
        AddParam ('p22_3', Get_Ftr_Nt (p_at_id, p_nda => 4209));
        AddParam ('p23_1', AtFtrChkT (p_at_id, p_nda => 4210));
        AddParam ('p23_2', AtFtrChkF (p_at_id, p_nda => 4210));
        AddParam ('p23_3', Get_Ftr_Nt (p_at_id, p_nda => 4210));
        AddParam ('p24_1', AtFtrChkT (p_at_id, p_nda => 4211));
        AddParam ('p24_2', AtFtrChkF (p_at_id, p_nda => 4211));
        AddParam ('p24_3', Get_Ftr_Nt (p_at_id, p_nda => 4211));
        --Інформація про скарги на стан здоров’я:
        AddParam ('p25_1', AtFtrChkT (p_at_id, p_nda => 4212));
        AddParam ('p25_2', AtFtrChkF (p_at_id, p_nda => 4212));
        AddParam ('p25_3', Get_Ftr_Nt (p_at_id, p_nda => 4212));
        AddParam ('p26_1', AtFtrChkT (p_at_id, p_nda => 4213));
        AddParam ('p26_2', AtFtrChkF (p_at_id, p_nda => 4213));
        AddParam ('p26_3', Get_Ftr_Nt (p_at_id, p_nda => 4213));
        AddParam ('p27_1', AtFtrChkT (p_at_id, p_nda => 4214));
        AddParam ('p27_2', AtFtrChkF (p_at_id, p_nda => 4214));
        AddParam ('p27_3', Get_Ftr_Nt (p_at_id, p_nda => 4214));
        AddParam ('p28_1', AtFtrChkT (p_at_id, p_nda => 4215));
        AddParam ('p28_2', AtFtrChkF (p_at_id, p_nda => 4215));
        AddParam ('p28_3', Get_Ftr_Nt (p_at_id, p_nda => 4215));
        AddParam ('p29_1', AtFtrChkT (p_at_id, p_nda => 4216));
        AddParam ('p29_2', AtFtrChkF (p_at_id, p_nda => 4216));
        AddParam ('p29_3', Get_Ftr_Nt (p_at_id, p_nda => 4216));
        AddParam ('p30_1', AtFtrChkT (p_at_id, p_nda => 4217));
        AddParam ('p30_2', AtFtrChkF (p_at_id, p_nda => 4217));
        AddParam ('p30_3', Get_Ftr_Nt (p_at_id, p_nda => 4217));
        --Інформація про родину отримувача соціальної послуги:
        AddParam ('p31', Get_Ftr_Nt (p_at_id, p_nda => 4218));
        AddParam ('p32', Get_Ftr_Nt (p_at_id, p_nda => 4219));
        AddParam ('p33', Get_Ftr_Nt (p_at_id, p_nda => 4220));
        --Контакти родичів/
        AddParam ('p34', Get_Ftr_Nt (p_at_id, p_nda => 4221));
        --Ресурси отримувача соціальної послуги
        AddParam ('p35', Get_Ftr_Nt (p_at_id, p_nda => 4222));
        AddParam ('p36', Get_Ftr_Nt (p_at_id, p_nda => 4223));
        AddParam ('p37', Get_Ftr_Nt (p_at_id, p_nda => 4224));
        --Короткотривала мета втручання:
        AddParam ('p38', Get_Ftr_Nt (p_at_id, p_nda => 4225));
        AddParam ('p39', Get_Ftr_Nt (p_at_id, p_nda => 4226));
        AddParam ('p40', Get_Ftr_Nt (p_at_id, p_nda => 4227));

        ------------------------------------
        rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                         p_rpt_blob   => l_result);
        replace_ekr (l_result);

        RETURN l_result;
    END ACT_DOC_845_R1;

    --#95284 Інформація про призупинення надання СП
    FUNCTION ACT_DOC_849_R1 (p_at_id IN NUMBER)
        RETURN BLOB
    IS
        CURSOR c_act IS
            SELECT a.at_org,
                   a.At_rnspm,
                   a.at_dt,
                   a.at_action_start_dt,
                   a.at_action_stop_dt,
                   am.at_id      AS at_tctr_id,
                   am.at_num     am_at_num,
                   am.at_dt      am_at_dt
              FROM act a, v_appeal ap, act am
             WHERE     a.at_id = p_at_id
                   AND ap.ap_id(+) = a.at_ap
                   AND am.at_id(+) = a.At_Main_Link;

        c          c_act%ROWTYPE;

        p          R_Person_for_act;                               --отримувач

        l_jbr_id   NUMBER;
        l_result   BLOB;
    BEGIN
        rdm$rtfl_univ.initreport (p_code     => 'ACT_DOC_849_R1',
                                  p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);

        OPEN c_act;

        FETCH c_act INTO c;

        CLOSE c_act;

        --------------------------------------------------------

        p :=
            get_AtPerson (p_at    => c.at_tctr_id,
                          p_atp   => get_AtPerson_id (c.at_tctr_id));

        AddParam ('1', tools.GetOrgName (c.at_org));
        AddParam ('2', Get_Nsp_Name (p_rnspm_id => c.At_rnspm));     --надавач
        AddParam ('3', AtDocAtrStr (p_at_id, 5547));   --Адреса для листування
        AddParam (
            '4',
            NVL (p.Phone                        /*AtDocAtrStr(p_at_id, 5548)*/
                        ,
                 '___________________________________________________')); --телефон
        AddParam (
            '5',
            NVL (p.Email                        /*AtDocAtrStr(p_at_id, 5549)*/
                        ,
                 '___________________________________________________')); --Адреса електронної пошти
        AddParam ('6', Get_Nsp_Name (p_rnspm_id => c.At_rnspm));     --надавач
        AddParam (
            'addr',
            NVL (p.Fact_Address,
                 '___________________________________________________')); --Адреса місцепроживання
        AddParam ('med_prop', AtDocAtrStr (p_at_id, 5360));   --Протипоказання

        AddParam ('30', c.am_at_num);
        AddParam ('31', TO_CHAR (c.am_at_dt, 'DD.MM.YYYY'));

        AddParam (
            '7',
            v_ddn ('uss_ndi.V_DDN_SS_MNG_DOC', AtDocAtrStr (p_at_id, 5355))); --відповідно до
        AddParam ('8', NVL (AtDocAtrStr (p_at_id, 5357), '______________')); --від
        AddParam ('9', NVL (AtDocAtrStr (p_at_id, 5356), '______________')); --№
        AddParam ('31',
                  NVL (TO_CHAR (c.am_at_dt, 'DD.MM.YYYY'), '______________')); --від
        AddParam ('30', NVL (c.am_at_num, '_________________'));           --№
        AddParam ('10', TO_CHAR (c.at_action_start_dt, 'dd.mm.yyyy')); --призупинення з
        AddParam ('11', TO_CHAR (c.at_action_stop_dt, 'dd.mm.yyyy'));
        AddParam ('12', NVL (AtDocAtrStr (p_at_id, 5358), '______________')); --відповідно до медичного висновку дата
        AddParam ('13', NVL (AtDocAtrStr (p_at_id, 5359), '______________')); --відповідно до медичного висновку №
        AddParam ('14', p.pib);

        AddParam ('15', NVL (c.am_at_num, '______________')); --відповідно до договору №
        AddParam ('16',
                  NVL (TO_CHAR (c.am_at_dt, 'dd.mm.yyyy'), '______________'));

        --Перелік соціальних послуг
        AddParam ('17', AtSrv_Nst_List (c.at_tctr_id, NULL /*призупинення, беру всі*/
                                                          , ';' || c_chr10));

        --AddParam('sgn1', Get_IPr(get_signers_wucu_pib(p_at_id => p_at_id, p_ati_tp => 'PR')));--Керівник надавача соціальних послуг
        AddParam (
            'sgn1',
            AtDocAtrStr (p_at_id, 8460) || ' ' || AtDocAtrStr (p_at_id, 8459)); --Керівник надавача соціальних послуг
        AddParam (
            'sgn2',
            NVL (AtDocAtrStr (p_at_id, 8461), '_______________________')); --Керівник надавача соціальних послуг
        AddParam ('20', Date2Str (c.at_dt));

        ------------------------------------
        rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                         p_rpt_blob   => l_result);
        replace_ekr (l_result);

        RETURN l_result;
    END ACT_DOC_849_R1;

    --#91713  РІШЕННЯ про надання / відмову в наданні соціальних послуг (uss_esr.DNET$PAY_TERMINATE/FUNCTION Fill_Attrs_850)
    FUNCTION Act_Doc_850_R1 (p_At_Id IN NUMBER)
        RETURN BLOB
    IS
        CURSOR c_Act IS
            SELECT Ap.Ap_Id,
                   Ap.Ap_Is_Second,
                   a.At_Cu,
                   a.At_Wu,
                   a.At_Main_Link
              FROM Act a, v_Appeal Ap
             WHERE a.At_Id = p_At_Id AND Ap.Ap_Id(+) = a.At_Ap;

        c           c_Act%ROWTYPE;

        l_Pib_Os    VARCHAR2 (32000);
        l_Str       VARCHAR2 (32000);

        Cur         SYS_REFCURSOR;
        l_Cnt_Nst   INTEGER;                        --кількість наданих послуг
        l_cnt       NUMBER;

        l_Jbr_Id    NUMBER;
        l_Result    BLOB;
    BEGIN
        --check_at_signed_docs(p_at_id => p_at_id, p_ndt_id => 850);

        Rdm$rtfl_Univ.Initreport (p_Code     => 'ACT_DOC_850_R1',
                                  p_Bld_Tp   => Rdm$rtfl_Univ.c_Bld_Tp_Db);

        OPEN c_Act;

        FETCH c_Act INTO c;

        CLOSE c_Act;

        --------------------------------------------------------
        Addparam ('p1',
                  COALESCE (TO_CHAR (SYSDATE, 'DD.MM.YYYY') /*get_Act_Prove_Dt(p_At_Id)*/
                                                            /*Atdocatrdt(p_At_Id, 2934)*/
                                                           , Space (21)));
        Addparam ('p2', COALESCE (Atdocatrstr (p_At_Id, 2935), Space (21)));
        Addparam ('p3', COALESCE (Atdocatrstr (p_At_Id, 2936), Space (86)));
        Addparam ('p4', COALESCE (Atdocatrdt (p_At_Id, 2937), Space (33)));
        Addparam ('p5', COALESCE (Atdocatrstr (p_At_Id, 2938), Space (24)));
        Addparam (
            'p6',
            (CASE c.Ap_Is_Second
                 WHEN 'T' THEN 'первинне/ \ul повторне \ul0'
                 ELSE '\ul первинне \ul0 /повторне'
             END));
        Addparam (
            'p7',
            COALESCE (
                CASE
                    WHEN At_Doc_Atr_Lst (p_At_Id, '2939,2940,2941', NULL)
                             IS NOT NULL
                    THEN
                        At_Doc_Atr_Lst (p_At_Id, '2939,2940,2941')
                END,
                Space (78)));

        --Особа(и), яка(і) отримуватимуть соціальну(і) послугу(и)
        IF Get_Ap_Doc_Atr_Str (c.Ap_Id, 1895) = 'FM'
        THEN
            --FM "моїй сім’ї" - виводити всіх членів сім'ї
            SELECT LISTAGG (i.Sci_Ln || ' ' || i.Sci_Fn || ' ' || i.Sci_Mn,
                            ', ')
                   WITHIN GROUP (ORDER BY
                                        i.Sci_Ln
                                     || ' '
                                     || i.Sci_Fn
                                     || ' '
                                     || i.Sci_Mn)
              INTO l_Pib_Os
              FROM Uss_Esr.Ap_Person         p,
                   Uss_Person.v_Sc_Change    Sc,
                   Uss_Person.v_Sc_Identity  i
             WHERE     p.App_Ap = c.Ap_Id
                   AND p.App_Tp IN ('FM', 'Z', 'FMS')
                   AND Sc.Scc_Id = p.App_Scc
                   AND i.Sci_Id = Sc.Scc_Sci;
        --l_Pib_Os := Get_Atperson(p_At => p_At_Id, p_Atp => Get_Atperson_Id(p_At_Id,'OS')).Ln;
        ELSE
            l_Pib_Os :=
                Get_Atperson (p_At    => p_At_Id,
                              p_Atp   => Get_Atperson_Id (p_At_Id, 'OS')).Pib; --At_Doc_Atr_Lst(p_at_id, '2942,2943,2944')
        END IF;

        Addparam ('p8', COALESCE (l_Pib_Os, Space (36)));
        /* перенесено, дивись нижче
        AddParam('p9', coalesce((CASE  AtDocAtrStr(p_at_id, 2945) --nvl(Get_Ftr(c.at_main_link, p_nda => 2039), Get_Ftr(c.at_main_link, p_nda => 2061))
                                     WHEN 'F' THEN 'Сім''я/особа не потребує надання соціальних послуг'
                                     WHEN 'T' THEN 'Сім''я/особа потребує надання соціальних послуг'
                                 END), space(37)));*/

        --надати соціальну послугу
        l_Str := q'[
    select  row_number() over(order by nst.nst_order)  as rn,
            nst.nst_name                               as c1,
            --Uss_Ndi.v_Ddn_Ss_Method
            Api$Act_Rpt.chk_val2(s.Ats_ss_method, 'F') as c2,
            Api$Act_Rpt.chk_val2(s.Ats_ss_method, 'C') as c3,
            Api$Act_Rpt.chk_val2(s.Ats_ss_method, 'D') as c4
    from uss_esr.at_service s,
         Uss_Ndi.v_Ndi_Service_Type nst
   where 1=1
     and s.history_status = 'A'
     and s.ats_st in ('PP', 'SG', 'P', 'R')
     and nst.nst_id = s.ats_nst
     and s.ats_at = :p_at_id
   order by rn
  ]';
        l_str :=
            REGEXP_REPLACE (l_str,
                            ':p_at_id',
                            p_at_id,
                            1,
                            0,
                            'i');
        Rdm$rtfl_Univ.Adddataset ('ds', l_Str);

        --чи надаються взагалі якісь послуги:
        l_Str := 'SELECT COUNT(*) FROM (' || l_Str || ')';

        OPEN Cur FOR l_Str;

        FETCH Cur INTO l_Cnt_Nst;

        CLOSE Cur;

        Addparam (
            'p9',
            CASE
                WHEN l_Cnt_Nst > 0
                THEN
                    'Сім''я/особа потребує надання соціальних послуг'
                ELSE
                    'Сім''я/особа не потребує надання соціальних послуг'
            END);
        Addparam ('p11', CASE WHEN l_Cnt_Nst = 0 THEN Space (50) END);

        Addparam ('p14', COALESCE (Atdocatrstr (p_At_Id, 2946), Space (50)));

        --відмовити в наданні соціальної послуги
        l_Str := Atsrv_Nst_List (p_At_Id, 0, '; ' || c_Chr10);
        Addparam ('p15', COALESCE (l_Str, Space (36)));
        --Причина відмови
        Addparam ('p16', Get_At_Reject_List (p_At_Id));

        --Спеціаліст з опрацювання заяв
        Addparam ('p17', COALESCE (Atdocatrstr (p_At_Id, 3082), NULL /*'__________________________'*/
                                                                    ));
        Addparam (
            'p18',
            COALESCE (              --Api$act.Get_At_Spec_Name(c.at_wu, NULL),
                CASE
                    WHEN At_Doc_Atr_Lst (p_At_Id, '2955,2956,2957', NULL)
                             IS NOT NULL
                    THEN
                        At_Doc_Atr_Lst (p_At_Id, '2955,2956,2957')
                END,
                NULL                /*'____________________________________'*/
                    ));

        Addparam ('p19', COALESCE (Atdocatrstr (p_At_Id, 3083), NULL /*'__________________________'*/
                                                                    ));
        Addparam (
            'p20',
            COALESCE (
                CASE
                    WHEN At_Doc_Atr_Lst (p_At_Id, '2958,2959,2960', NULL)
                             IS NOT NULL
                    THEN
                        At_Doc_Atr_Lst (p_At_Id, '2958,2959,2960')
                END,
                NULL                /*'____________________________________'*/
                    ));

        SELECT COUNT (*)
          INTO l_cnt
          FROM (SELECT MAX (CASE WHEN z.arl_nrr = 222 THEN z.arl_result END)
                           AS r_222,
                       MAX (CASE WHEN z.arl_nrr = 224 THEN z.arl_result END)
                           AS r_224,
                       MAX (CASE WHEN z.arl_nrr = 225 THEN z.arl_result END)
                           AS r_225,
                       MAX (
                           CASE
                               WHEN z.arl_nrr = 224 THEN z.arl_calc_result
                           END)
                           AS rc_224,
                       MAX (
                           CASE
                               WHEN z.arl_nrr = 225 THEN z.arl_calc_result
                           END)
                           AS rc_225
                  FROM at_right_log z
                 WHERE z.arl_at = p_At_Id AND z.arl_nrr IN (224, 225, 222))
         WHERE     (rc_224 = 'T' OR rc_225 = 'T')
               AND NVL (r_224, 'F') = 'F'
               AND NVL (r_225, 'F') = 'F'
               AND NVL (r_222, 'F') = 'T';

        Addparam (
            'p10',
            CASE
                WHEN l_cnt = 0
                THEN
                    COALESCE (Atdocatrsum (p_At_Id, 2949), Space (10))
            END);                                           --сукупного доходу
        Addparam (
            'p13',
            CASE
                WHEN l_cnt = 0
                THEN
                    COALESCE (Atdocatrsum (p_At_Id, 2950), '___________')
                ELSE
                    '___________'
            END);

        --код датасета поцуплений з: FUNCTION USS_ESR.dnet$pd_reports / assistance_decision, дивись частину до документу 850, рядок приблизно 663
        l_Str :=
               q'[
  SELECT row_number() over(ORDER BY c2, c3) AS c1, c2, c3, c4, c5, c6, c7, c8, c9, c10
   FROM (SELECT t.atp_id,
               pt.dic_sname AS c2,
               uss_person.api$sc_tools.get_pib(t.atp_sc) AS c3,
               td.rltn_tp AS c4,
               td.doc AS c5,
               tt.inc_tp AS c6,
               to_char(SUM(coalesce(t.aid_calc_sum, 0)), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS c7,
               to_char(MAX(CASE WHEN t.aid_month = add_months(t.last_month, -2) THEN t.aid_month END), 'MONTH YYYY', 'nls_date_language=Ukrainian')  || ' \par ' ||
               to_char(SUM(CASE WHEN t.aid_month = add_months(t.last_month, -2) THEN t.aid_calc_sum ELSE 0 END), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS c8,
               to_char(MAX(CASE WHEN t.aid_month = add_months(t.last_month, -1) THEN t.aid_month END), 'MONTH YYYY', 'nls_date_language=Ukrainian')  ||' \par '||
               to_char(SUM(CASE WHEN t.aid_month = add_months(t.last_month, -1) THEN t.aid_calc_sum ELSE 0 END), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS c9,
               to_char(MAX(CASE WHEN t.aid_month = t.last_month THEN t.aid_month END), 'MONTH YYYY', 'nls_date_language=Ukrainian') || ' \par ' ||
               to_char(SUM(CASE WHEN t.aid_month = t.last_month THEN t.aid_calc_sum ELSE 0 END), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS c10
          FROM (SELECT ap.atp_id, ap.atp_sc, ap.atp_at, ap.atp_app_tp, pd.aid_month, pd.aid_calc_sum, MAX(pd.aid_month) over(PARTITION BY ap.atp_id) AS last_month
                  FROM uss_esr.v_at_person ap
                  /*JOIN uss_esr.v_personalcase pc ON pc.pc_sc = ap.atp_sc*/
                  JOIN uss_esr.v_at_income_calc ic ON (ic.aic_at = ap.atp_at/* and ic.aic_pc = pc.pc_id*/)
                  JOIN uss_esr.v_at_income_detail pd ON (pd.aid_app = ap.atp_app
                                                    AND pd.aid_sc = ap.atp_sc
                                                    AND pd.aid_is_family_member = 'T'
                                                    AND pd.aid_aic = ic.aic_id)
                 WHERE ap.atp_at = :p_at_id
                   AND ap.history_status = 'A'
                   AND ap.atp_app_tp IN ('Z', 'FM', 'OS')
                   and 1 = ]'
            || CASE WHEN l_cnt > 0 THEN 2 ELSE 1 END
            || q'[
               ) t

          JOIN uss_ndi.v_Ddn_App_Tp pt ON pt.dic_value = t.atp_app_tp
          LEFT JOIN (SELECT d.apd_app,
                           MAX(CASE
                                 WHEN da.apda_nda = 813 AND da.apda_val_string IS NOT NULL
                                   THEN (SELECT t.dic_name FROM uss_ndi.v_ddn_relation_tp t WHERE t.dic_value = da.apda_val_string)
                               END) AS rltn_tp,
                           coalesce(MAX(CASE da.apda_nda WHEN 1 THEN da.apda_val_string END),
                                    MAX(CASE WHEN da.apda_nda IN (3, 9) THEN da.apda_val_string END)) AS doc
                      FROM uss_esr.v_ap_document d
                      JOIN uss_esr.v_ap_document_attr da ON da.apda_apd = d.apd_id
                                                        AND da.apda_ap = d.apd_ap
                                                        AND da.apda_nda IN (1, 3, 9, 813)
                                                        AND da.history_status = 'A'
                     WHERE d.apd_ap = :p_ap_id
                       AND d.apd_ndt IN (5, 6, 7, 605)
                       AND d.history_status = 'A'
                     GROUP BY d.apd_app) td ON td.apd_app = t.atp_id
          LEFT JOIN (SELECT ais_app, ais_sc, listagg(dic_sname, ', ') within GROUP(ORDER BY dic_srtordr) AS inc_tp
                       FROM (SELECT DISTINCT s.ais_app, s.ais_sc, st.dic_sname, st.dic_srtordr
                               FROM uss_esr.v_at_income_src s
                               JOIN uss_ndi.v_ddn_apri_tp st ON st.dic_value = s.ais_tp
                              WHERE s.ais_at = :p_at_id)
                      GROUP BY ais_app, ais_sc) tt ON tt.ais_app = t.atp_id
                                                  AND tt.ais_sc = t.atp_sc
         WHERE t.aid_month >= add_months(t.last_month, -2)
         GROUP BY t.atp_id, pt.dic_sname, t.atp_sc, td.rltn_tp, td.doc, tt.inc_tp)
  ]';

        l_str :=
            REGEXP_REPLACE (l_str,
                            ':p_at_id',
                            p_at_id,
                            1,
                            0,
                            'i');
        l_str :=
            REGEXP_REPLACE (l_str,
                            ':p_ap_id',
                            c.Ap_Id,
                            1,
                            0,
                            'i');
        Rdm$rtfl_Univ.Adddataset ('ds_calc', Org2ekr (l_Str));

        --дохід сім’ї
        Addparam (
            'p52',
            CASE
                WHEN l_cnt = 0
                THEN
                    COALESCE (Atdocatrsum (p_At_Id, 2947),
                              '_________________________________')
                ELSE
                    '_________________________________'
            END);
        Addparam (
            'p53',
            CASE
                WHEN l_cnt = 0
                THEN
                    COALESCE (Atdocatrsum (p_At_Id, 2948),
                              '_________________________________')
                ELSE
                    '_________________________________'
            END);
        Addparam (
            'p54',
            CASE
                WHEN l_cnt = 0
                THEN
                    COALESCE (Atdocatrsum (p_At_Id, 2949),
                              '_________________________________')
                ELSE
                    '_________________________________'
            END);
        Addparam (
            'p55',
            CASE
                WHEN l_cnt = 0
                THEN
                    COALESCE (Atdocatrsum (p_At_Id, 2950),
                              '_________________________________')
                ELSE
                    '_________________________________'
            END);

        -----------------------------------------
        Rdm$rtfl_Univ.Get_Report_Result (p_Jbr_Id     => l_Jbr_Id,
                                         p_Rpt_Blob   => l_Result);
        Replace_Ekr (l_Result);

        RETURN l_Result;
    END Act_Doc_850_R1;

    --#91716 ПОВІДОМЛЕННЯ про надання / відмову в наданні соціальних послуг  (uss_esr.DNET$PAY_TERMINATE/FUNCTION Fill_Attrs_851)
    FUNCTION ACT_DOC_851_R1_old (p_at_id IN NUMBER)
        RETURN BLOB
    IS
        CURSOR c_act IS
            SELECT a.At_Rnspm, ap.ap_id, ap.ap_is_second
              FROM act a, v_appeal ap
             WHERE a.at_id = p_at_id AND ap.ap_id(+) = a.at_ap;

        c          c_act%ROWTYPE;

        l_jbr_id   NUMBER;
        l_result   BLOB;
    BEGIN
        --check_at_signed_docs(p_at_id => p_at_id, p_ndt_id => 851);

        rdm$rtfl_univ.initreport (p_code     => 'ACT_DOC_851_R1',
                                  p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);

        OPEN c_act;

        FETCH c_act INTO c;

        CLOSE c_act;

        --------------------------------------------------------
        AddParam (
            'p1',
            COALESCE (
                CASE
                    WHEN At_Doc_Atr_Lst (p_at_id, '2963,2964,2965', NULL)
                             IS NOT NULL
                    THEN
                        At_Doc_Atr_Lst (p_at_id, '2963,2964,2965')
                END,
                '_______________________________________________'));
        AddParam (
            'p2',
            COALESCE (Get_adr (p_ind     => AtDocAtrStr (p_at_id, 2966),
                               p_katot   => AtDocAtrStr (p_at_id, 2967),
                               p_strit   => AtDocAtrStr (p_at_id, 2968),
                               p_bild    => AtDocAtrStr (p_at_id, 2969),
                               p_korp    => AtDocAtrStr (p_at_id, 2970),
                               p_kv      => AtDocAtrStr (p_at_id, 2971)),
                      '_______________________________________________'));


        AddParam (
            'p3',
            COALESCE (
                AtDocAtrStr (p_at_id, 2975),
                '_________________________________________________________________________________'));

        --надання / відмову в наданні соціальних послуг
        AddParam (
            'p4',
            CASE AtDocAtrStr (p_at_id, 2997)
                WHEN 'T' THEN '\ulнадання\ul0 / відмову в наданні'
                WHEN 'F' THEN 'надання / \ulвідмову в наданні\ul0'
                ELSE 'надання / відмову в наданні'
            END);

        AddParam ('p5',
                  COALESCE (AtDocAtrDt (p_at_id, 2961), '____________'));
        AddParam ('p6',
                  COALESCE (AtDocAtrStr (p_at_id, 2962), '____________'));
        --отримувач
        AddParam (
            'p7',
            COALESCE (
                CASE
                    WHEN At_Doc_Atr_Lst (p_at_id, '2972,2973,2974', NULL)
                             IS NOT NULL
                    THEN
                        At_Doc_Atr_Lst (p_at_id, '2972,2973,2974')
                END,
                '_________________________________________________________________________________'));
        --установа надавач послуг
        AddParam (
            'p8',
            COALESCE (Get_Nsp_Name (p_Rnspm_Id => c.At_Rnspm), --AtDocAtrStr(p_at_id, 3084),
                                                               space (80)));
        --cпосіб надання соціальних послуг
        AddParam ('p91', chk_val ('F', AtDocAtrStr (p_at_id, 2976)));
        AddParam ('p92', chk_val ('C', AtDocAtrStr (p_at_id, 2976)));
        AddParam ('p93', chk_val ('D', AtDocAtrStr (p_at_id, 2976)));
        --Причина відмови
        AddParam ('p10', COALESCE (AtDocAtrStr (p_at_id, 2977) /*Get_At_Reject_List(p_At_Id)*/
                                                              , space (30)));
        --підпис
        AddParam ('p11', AtDocAtrStr (p_at_id, 3085));
        AddParam ('p12', At_Doc_Atr_Lst (p_at_id, '2978,2979,2980'));

        AddParam ('p13', NVL (AtDocAtrDt (p_at_id, 5348), c_date_empty));


        -----------------------------------------
        rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                         p_rpt_blob   => l_result);
        replace_ekr (l_result);

        RETURN l_result;
    END ACT_DOC_851_R1_old;

    --96292 ПОВІДОМЛЕННЯ про надання / відмову в наданні соціальних послуг  (uss_esr.DNET$PAY_TERMINATE/FUNCTION Fill_Attrs_851)
    FUNCTION Act_Doc_851_R2 (p_At_Id IN NUMBER)
        RETURN BLOB
    IS
        CURSOR c_Act IS
            SELECT a.At_Rnspm,
                   a.At_Ap,
                   Ap.Ap_Id,
                   Ap.Ap_Is_Second
              FROM Act a, v_Appeal Ap
             WHERE a.At_Id = p_At_Id AND Ap.Ap_Id(+) = a.At_Ap;

        c          c_Act%ROWTYPE;

        l_Pib_Os   VARCHAR2 (32000);
        l_Str      VARCHAR2 (32000);

        l_Jbr_Id   NUMBER;
        l_Result   BLOB;
    BEGIN
        --check_at_signed_docs(p_at_id => p_at_id, p_ndt_id => 851);

        Rdm$rtfl_Univ.Initreport (p_Code     => 'ACT_DOC_851_R2',
                                  p_Bld_Tp   => Rdm$rtfl_Univ.c_Bld_Tp_Db);

        OPEN c_Act;

        FETCH c_Act INTO c;

        CLOSE c_Act;

        --------------------------------------------------------
        AddParam ('p1', At_Doc_Atr_Lst (p_At_Id, '2963,2964,2965'));
        AddParam ('p2',
                  Get_Adr (p_Ind     => AtDocAtrStr (p_At_Id, 2966),
                           p_Katot   => AtDocAtrStr (p_At_Id, 2967),
                           p_Strit   => AtDocAtrStr (p_At_Id, 2968),
                           p_Bild    => AtDocAtrStr (p_At_Id, 2969),
                           p_Korp    => AtDocAtrStr (p_At_Id, 2970),
                           p_Kv      => AtDocAtrStr (p_At_Id, 2971)));

        AddParam ('p3', AtDocAtrStr (p_At_Id, 2975));    --головна організація

        AddParam ('p5', COALESCE (AtDocAtrDt (p_at_id, 2961), Space (20)));
        AddParam ('p6', COALESCE (AtDocAtrStr (p_At_Id, 2962), Space (20)));

        --отримувач
        IF Get_Ap_Doc_Atr_Str (c.At_Ap, 1895) = 'FM'
        THEN                    --FM "моїй сім’ї" - виводити всіх членів сім'ї
            SELECT LISTAGG (i.Sci_Ln || ' ' || i.Sci_Fn || ' ' || i.Sci_Mn,
                            ', ')
                   WITHIN GROUP (ORDER BY
                                        i.Sci_Ln
                                     || ' '
                                     || i.Sci_Fn
                                     || ' '
                                     || i.Sci_Mn)
              INTO l_Pib_Os
              FROM Uss_Esr.Ap_Person         p,
                   Uss_Person.v_Sc_Change    Sc,
                   Uss_Person.v_Sc_Identity  i
             WHERE     p.App_Ap = c.Ap_Id
                   AND p.App_Tp IN ('FM', 'Z', 'FMS')
                   AND Sc.Scc_Id = p.App_Scc
                   AND i.Sci_Id = Sc.Scc_Sci;
        --l_Pib_Os := Get_Atperson(p_At => p_At_Id, p_Atp => Get_Atperson_Id(p_At_Id,'OS')).Ln;
        ELSE
            l_Pib_Os :=
                Get_Atperson (p_At    => p_At_Id,
                              p_Atp   => Get_Atperson_Id (p_At_Id, 'OS')).Pib; --At_Doc_Atr_Lst(p_At_Id, '2972,2973,2974')
        END IF;

        AddParam ('p7', COALESCE (l_Pib_Os, Space (77)));
        --установа надавач послуг
        AddParam (
            'p8',
            COALESCE (Get_Nsp_Name (p_Rnspm_Id => c.At_Rnspm), Space (77)));

        --1) про надання соціальних послуг:
        l_Str := q'[
    select  row_number() over(order by nst.nst_order)  as rn,
            nst.nst_name                               as c1,
            --Uss_Ndi.v_Ddn_Ss_Method
            Api$Act_Rpt.chk_val2(s.Ats_ss_method, 'F') as c2,
            Api$Act_Rpt.chk_val2(s.Ats_ss_method, 'C') as c3,
            Api$Act_Rpt.chk_val2(s.Ats_ss_method, 'D') as c4
    from uss_esr.at_service s,
         Uss_Ndi.v_Ndi_Service_Type nst
   where 1=1
     and s.history_status = 'A'
     and s.ats_st in ('PP', 'SG', 'P', 'R')
     and nst.nst_id = s.ats_nst
     and s.ats_at = :p_at_id
   order by rn
  ]';
        l_str :=
            REGEXP_REPLACE (l_str,
                            ':p_at_id',
                            p_at_id,
                            1,
                            0,
                            'i');
        Rdm$rtfl_Univ.Adddataset ('ds', l_Str);

        --2) про відмову в наданні соціальних послуг:
        AddParam ('p9', Atsrv_Nst_List (p_At_Id, 0, '; ' || c_Chr10));
        --Причина відмови
        AddParam ('p10', COALESCE (             /*AtDocAtrStr(p_At_Id, 2977)*/
                                   Get_At_Reject_List (p_At_Id), Space (30)));

        --підпис
        AddParam ('p11', NVL (AtDocAtrStr (p_At_Id, 3085), Space (20)));
        AddParam ('p12', At_Doc_Atr_Lst (p_At_Id, '2978,2979,2980'));

        AddParam ('p13',
                  NVL (AtDocAtrDt (p_at_id, 2961) /*nvl(Atdocatr(p_At_Id, 5348).Atda_Val_Dt, SYSDATE)*/
                                                 , c_Date_Empty) || ' р.');

        -----------------------------------------
        Rdm$rtfl_Univ.Get_Report_Result (p_Jbr_Id     => l_Jbr_Id,
                                         p_Rpt_Blob   => l_Result);
        Replace_Ekr (l_Result);

        RETURN l_Result;
    END Act_Doc_851_R2;

    --#91717 Клопотання про влаштування особи з інвалідністю, особи похилого віку до інтернатної(го) установи/закладу
    FUNCTION ACT_DOC_852_R1 (p_at_id IN NUMBER)
        RETURN BLOB
    IS
        CURSOR c_act IS
            SELECT ap.ap_id
              FROM act a, v_appeal ap
             WHERE a.at_id = p_at_id AND ap.ap_id = a.at_ap;

        c          c_act%ROWTYPE;

        l_str      VARCHAR2 (32000);

        l_jbr_id   NUMBER;
        l_result   BLOB;
    BEGIN
        rdm$rtfl_univ.initreport (p_code     => 'ACT_DOC_852_R1',
                                  p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);

        OPEN c_act;

        FETCH c_act INTO c;

        CLOSE c_act;

        --------------------------------------------------------

        AddParam ('p1', AtDocAtrStr (p_at_id, 2982));
        AddParam ('p2', At_Doc_Atr_Lst (p_at_id, '2983,2984,2985')); --заявник
        AddParam ('p3', AtDocAtrDt (p_at_id, 2986));
        AddParam ('p4', AtDocAtrStr (p_at_id, 2987));
        AddParam ('p5', AtDocAtrStr (p_at_id, 2988));    --організація надавач
        AddParam ('p6', At_Doc_Atr_Lst (p_at_id, '2989,2990,2991')); --отримувач

        l_str := AtDocAtrStr (p_at_id, 2992);

          SELECT LISTAGG (
                     UnderLine (t.dic_name, DECODE (l_str, t.dic_value, 1)),
                     '/')
                 WITHIN GROUP (ORDER BY dic_srtordr)
            INTO l_str
            FROM uss_ndi.v_ddn_ss_method t
           WHERE t.dic_st = 'A'
        ORDER BY t.dic_srtordr;

        AddParam ('p7', l_str);

        SELECT LISTAGG (ndt_name, ', ') WITHIN GROUP (ORDER BY ndt_order)
          INTO l_str
          FROM (SELECT DISTINCT dt.ndt_name, dt.ndt_order
                  FROM v_ap_document  d
                       JOIN uss_ndi.v_ndi_document_type dt
                           ON dt.ndt_id = d.apd_ndt
                 WHERE d.apd_ap = c.ap_id AND d.history_status = 'A');

        AddParam (
            'p8',
            COALESCE (l_str, 'пакет документів (зазначити повний перелік)'));

        --підпис
        AddParam (
            'p9',
            COALESCE (AtDocAtrStr (p_at_id, 2993), '__________________'));
        AddParam (
            'p10',
            COALESCE (
                CASE
                    WHEN At_Doc_Atr_Lst (p_at_id, '2994,2995,2996', NULL)
                             IS NOT NULL
                    THEN
                        At_Doc_Atr_Lst (p_at_id, '2994,2995,2996')
                END,
                '_______________________________'));

        AddParam ('p11', c_date_empty);

        -----------------------------------------
        rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                         p_rpt_blob   => l_result);
        replace_ekr (l_result);

        RETURN l_result;
    END ACT_DOC_852_R1;

    -- #91719 Повідомлення про направлення клопотання про влаштування особи з інвалідністю, особи похилого віку до інтернатної(го) установи/закладу
    FUNCTION ACT_DOC_853_R1 (p_at_id IN NUMBER)
        RETURN BLOB
    IS
        CURSOR c_act IS
            SELECT ap.ap_id
              FROM act a, v_appeal ap
             WHERE a.at_id = p_at_id AND ap.ap_id = a.at_ap;

        c          c_act%ROWTYPE;

        l_str      VARCHAR2 (32000);

        l_jbr_id   NUMBER;
        l_result   BLOB;
    BEGIN
        rdm$rtfl_univ.initreport (p_code     => 'ACT_DOC_853_R1',
                                  p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);

        OPEN c_act;

        FETCH c_act INTO c;

        CLOSE c_act;

        --------------------------------------------------------

        AddParam (
            'p1',
            NVL (At_Doc_Atr_Lst (p_at_id, '2998,2999,3000'),
                 '_______________________________________________')); --заявник
        AddParam ('p2',
                  NVL (Get_adr (p_ind     => AtDocAtrStr (p_at_id, 3001),
                                p_katot   => AtDocAtrStr (p_at_id, 3002),
                                p_strit   => AtDocAtrStr (p_at_id, 3003),
                                p_bild    => AtDocAtrStr (p_at_id, 3004),
                                p_korp    => AtDocAtrStr (p_at_id, 3005),
                                p_kv      => AtDocAtrStr (p_at_id, 3006)),
                       '_______________________________________________'));


        AddParam ('p3', AtDocAtrStr (p_at_id, 3007));    --організація місцева
        AddParam ('p4', AtDocAtrDt (p_at_id, 3008));                   --заява
        AddParam ('p5', AtDocAtrStr (p_at_id, 3009));

        AddParam ('p6', AtDocAtrStr (p_at_id, 3010)); --організація обласного рівня
        AddParam ('p7', AtDocAtrDt (p_at_id, 3011));
        AddParam ('p8', At_Doc_Atr_Lst (p_at_id, '3012,3013,3014')); --отримувач
        AddParam ('p9', AtDocAtrSum (p_at_id, 3015)); --середньомісячний сукупний дохід

        l_str := AtSrv_Nst_List (p_at_id, 1);
        AddParam ('p10', l_str);              --соціальна(і) послуга - перелік

        --cпосіб надання соціальних послуг
        AddParam ('p111', chk_val ('F', AtDocAtrStr (p_at_id, 3016)));
        AddParam ('p112', chk_val ('C', AtDocAtrStr (p_at_id, 3016)));
        AddParam ('p113', chk_val ('D', AtDocAtrStr (p_at_id, 3016)));
        AddParam (
            'p12',
            CASE
                WHEN AtDocAtrStr (p_at_id, 3016) = 'C'
                THEN
                    '\ulплатно\ul0 або з установленням диференційованої плати'
                WHEN AtDocAtrStr (p_at_id, 3016) = 'D'
                THEN
                    'платно або \ulз установленням диференційованої плати\ul0'
                ELSE
                    'платно або з установленням диференційованої плати'
            END);       -- критерії поки невідомі, виводиться без підкреслення
        --підпис
        AddParam (
            'p13',
            COALESCE (AtDocAtrStr (p_at_id, NULL), '__________________'));
        AddParam (
            'p14',
            COALESCE (
                CASE
                    WHEN At_Doc_Atr_Lst (p_at_id, '3017,3018,3019', NULL)
                             IS NOT NULL
                    THEN
                        At_Doc_Atr_Lst (p_at_id, '3017,3018,3019')
                END,
                '_______________________________'));

        -----------------------------------------
        rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                         p_rpt_blob   => l_result);
        replace_ekr (l_result);

        RETURN l_result;
    END ACT_DOC_853_R1;

    --#91721 ndt 854 «Путівка на влаштування до інтернатної(го) установи/закладу»  (uss_esr.DNET$PAY_TERMINATE/FUNCTION Fill_Attrs_854)
    FUNCTION ACT_DOC_854_R1 (p_at_id IN NUMBER)
        RETURN BLOB
    IS
        CURSOR c_act IS
            SELECT ap.ap_id
              FROM act a, v_appeal ap
             WHERE a.at_id = p_at_id AND ap.ap_id = a.at_ap;

        c          c_act%ROWTYPE;

        l_str      VARCHAR2 (32000);

        l_jbr_id   NUMBER;
        l_result   BLOB;
    BEGIN
        rdm$rtfl_univ.initreport (p_code     => 'ACT_DOC_854_R1',
                                  p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);

        OPEN c_act;

        FETCH c_act INTO c;

        CLOSE c_act;

        --------------------------------------------------------

        AddParam ('p0', NVL (AtDocAtrStr (p_at_id, 3020), '_______'));
        AddParam ('p1', AtDocAtrStr (p_at_id, 3021));            --організація
        AddParam (
            'p2',
            COALESCE (Get_adr (p_ind     => AtDocAtrStr (p_at_id, 3032),
                               p_katot   => AtDocAtrStr (p_at_id, 3033),
                               p_strit   => AtDocAtrStr (p_at_id, 3034),
                               p_bild    => AtDocAtrStr (p_at_id, 3035),
                               p_korp    => AtDocAtrStr (p_at_id, 3036),
                               p_kv      => AtDocAtrStr (p_at_id, 3037)),
                      '_________________________________________'));

        AddParam (
            'p3',
            COALESCE (Get_adr (p_ind     => AtDocAtrStr (p_at_id, 3038),
                               p_katot   => AtDocAtrStr (p_at_id, 3039),
                               p_strit   => AtDocAtrStr (p_at_id, 3040),
                               p_bild    => AtDocAtrStr (p_at_id, 3041),
                               p_korp    => AtDocAtrStr (p_at_id, 3042),
                               p_kv      => AtDocAtrStr (p_at_id, 3043)),
                      '_________________________________________'));

        AddParam ('p4', At_Doc_Atr_Lst (p_at_id, '3022,3023,3024')); --отримувач
        AddParam ('p5',
                  COALESCE (AtDocAtrDt (p_at_id, 3025), '________________')); --дата народження
        AddParam ('p6',
                  COALESCE (AtDocAtrStr (p_at_id, 3026), '________________')); --група інвалідності
        --cпосіб надання соціальних послуг  uss_ndi.V_DDN_SS_METHOD
        AddParam ('p71', chk_val ('F', AtDocAtrStr (p_at_id, 3027)));
        AddParam ('p72', chk_val ('C', AtDocAtrStr (p_at_id, 3027)));
        AddParam ('p73', chk_val ('D', AtDocAtrStr (p_at_id, 3027)));
        AddParam ('p8', AtDocAtrSum (p_at_id, 3028)); --середньомісячний сукупний дохід
        AddParam ('p9', AtDocAtrSum (p_at_id, 3029));
        AddParam ('p10', 'пенсії / \ul державної соціальної допомоги \ul0');
        AddParam ('p11', AtDocAtrStr (p_at_id, 3031));           --організація
        AddParam ('p12', '______');
        AddParam ('p13',
                  COALESCE (AtDocAtrDt (p_at_id, 3044), '________________'));
        AddParam ('p14',
                  COALESCE (AtDocAtrDt (p_at_id, 3045), '________________'));
        --постійно, тимчасово
        l_str := AtDocAtrStr (p_at_id, 3046);

        SELECT LISTAGG (
                   CASE l_str
                       WHEN dic_value THEN '\ul ' || dic_sname || '\ul0 '
                       ELSE dic_sname
                   END,
                   ' / ')
               WITHIN GROUP (ORDER BY dic_srtordr)
          INTO l_str
          FROM uss_ndi.v_ddn_rnsp_stay t;

        AddParam ('p15-0', l_str);

        AddParam ('p15',
                  COALESCE (AtDocAtrDt (p_at_id, 3047), '________________'));
        AddParam ('p16',
                  COALESCE (AtDocAtrDt (p_at_id, 3048), '________________'));
        AddParam ('p17',
                  COALESCE (AtDocAtrDt (p_at_id, 3049), '________________'));

        --підпис
        AddParam ('p20',
                  COALESCE (AtDocAtrStr (p_at_id, 3050), '________________'));
        AddParam (
            'p21',
            COALESCE (
                CASE
                    WHEN At_Doc_Atr_Lst (p_at_id, '3051,3052,3053', NULL)
                             IS NOT NULL
                    THEN
                        At_Doc_Atr_Lst (p_at_id, '3051,3052,3053')
                END,
                '_________________________'));
        AddParam ('p22',
                  COALESCE (AtDocAtrStr (p_at_id, 3055), '________________'));
        AddParam (
            'p23',
            COALESCE (
                CASE
                    WHEN At_Doc_Atr_Lst (p_at_id, '3056,3057,3058', NULL)
                             IS NOT NULL
                    THEN
                        At_Doc_Atr_Lst (p_at_id, '3056,3057,3058')
                END,
                '________________________'));
        AddParam (
            'p24',
            COALESCE (AtDocAtrDt (p_at_id, NULL), c_date_empty || 'року'));

        -----------------------------------------
        rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                         p_rpt_blob   => l_result);
        replace_ekr (l_result);

        RETURN l_result;
    END ACT_DOC_854_R1;

    --91436 Повідомлення СПСЗН про прийняття особи на обслуговування до інтернатного закладу
    FUNCTION ACT_DOC_855_R1 (p_at_id IN NUMBER)
        RETURN BLOB
    IS
        l_jbr_id   NUMBER;
        l_result   BLOB;
    BEGIN
        --check_at_signed_docs(p_at_id => p_at_id, p_ndt_id => 855);

        rdm$rtfl_univ.initreport (p_code     => 'ACT_DOC_855_R1',
                                  p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);
        --------------------------------------------------------

        AddParam ('p1', AtDocAtrStr (p_at_id, 4232));              --Путівка №
        AddParam ('p2', AtDocAtrDt (p_at_id, 4233));
        AddParam ('p3', AtDocAtrStr (p_at_id, 4234)); --найменування СПСЗН обласного рівня
        AddParam ('p4', At_Doc_Atr_Lst (p_at_id, '4235,4236,4237')); --отримувач
        AddParam ('p5', AtDocAtrStr (p_at_id, 4238)); --найменування інтернатної установи/закладу
        AddParam ('p6', AtDocAtrDt (p_at_id, 4239));             --дата наказу
        AddParam ('p7', AtDocAtrStr (p_at_id, 4240));               --№ наказу
        AddParam ('p9', AtDocAtrStr (p_at_id, 4241)); --найменування органу ПФУ/СПСЗН
        AddParam ('p9', AtDocAtrStr (p_at_id, 4242)); --Повідомлення направлено
        AddParam ('p10', At_Doc_Atr_Lst (p_at_id, '4243,4244,4245')); --ПІБ директора

        -----------------------------------------
        rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                         p_rpt_blob   => l_result);
        replace_ekr (l_result);

        RETURN l_result;
    END ACT_DOC_855_R1;

    --#91438 «Повідомлення органу ПФУ про прийняття на обслуговування до інтернатного закладу»
    FUNCTION ACT_DOC_856_R1 (p_at_id IN NUMBER)
        RETURN BLOB
    IS
        l_jbr_id   NUMBER;
        l_result   BLOB;
    BEGIN
        --check_at_signed_docs(p_at_id => p_at_id, p_ndt_id => 856);

        rdm$rtfl_univ.initreport (p_code     => 'ACT_DOC_856_R1',
                                  p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);
        --------------------------------------------------------

        AddParam ('p1',
                  Get_adr (p_ind     => AtDocAtrStr (p_at_id, 4247),
                           p_katot   => AtDocAtrStr (p_at_id, 4246),
                           p_strit   => AtDocAtrStr (p_at_id, 4248),
                           p_bild    => AtDocAtrStr (p_at_id, 4249),
                           p_korp    => AtDocAtrStr (p_at_id, 4250),
                           p_kv      => NULL)); ----Місце знаходження органу ПФУ/СППСЗН
        AddParam ('p2', AtDocAtrStr (p_at_id, 4251)); --найменування інтернатної установи/закладу
        AddParam ('p3',
                  Get_adr (p_ind     => AtDocAtrStr (p_at_id, 4253),
                           p_katot   => AtDocAtrStr (p_at_id, 4252),
                           p_strit   => AtDocAtrStr (p_at_id, 4254),
                           p_bild    => AtDocAtrStr (p_at_id, 4255),
                           p_korp    => AtDocAtrStr (p_at_id, 4256),
                           p_kv      => NULL)); --місцезнаходження інтернатної установи/закладу
        AddParam ('p4', AtDocAtrDt (p_at_id, 4257));             --дата наказу
        AddParam ('p5', AtDocAtrStr (p_at_id, 4258));
        AddParam ('p6', AtDocAtrDt (p_at_id, 4259)); --дата прийняття до інтернатної установи/закладу
        AddParam ('p7', At_Doc_Atr_Lst (p_at_id, '4260,4261,4262')); --отримувач
        AddParam ('p8', AtDocAtrDt (p_at_id, 4263));
        AddParam ('p9',
                  Get_adr (p_ind     => AtDocAtrStr (p_at_id, 4265),
                           p_katot   => AtDocAtrStr (p_at_id, 4264),
                           p_strit   => AtDocAtrStr (p_at_id, 4266),
                           p_bild    => AtDocAtrStr (p_at_id, 4267),
                           p_korp    => AtDocAtrStr (p_at_id, 4268),
                           p_kv      => AtDocAtrStr (p_at_id, 4269))); --отримувач - адреса
        AddParam ('p10', AtDocAtrStr (p_at_id, 4270));
        AddParam ('p11', AtDocAtrStr (p_at_id, 4271));
        AddParam ('p12', AtDocAtrStr (p_at_id, 4272));
        AddParam ('p13', At_Doc_Atr_Lst (p_at_id, '4273,4274,4275')); --прізвище отримувача / законного представника
        AddParam ('p14', AtDocAtrStr (p_at_id, 4276)); --заява особи чи її законного представника або заява керівника інтернатної(го) установи/закладу
        AddParam ('p15', At_Doc_Atr_Lst (p_at_id, '4277,42778,4279')); --ПІБ директора

        -----------------------------------------
        rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                         p_rpt_blob   => l_result);
        replace_ekr (l_result);

        RETURN l_result;
    END ACT_DOC_856_R1;


    -- #93371 «Звіт за результатами соціального супроводу сім’ї/особи»
    FUNCTION ACT_DOC_859_R1 (p_at_id IN NUMBER)
        RETURN BLOB
    IS
        --uss_esr.CMES$ACT_ZRSP

        CURSOR c_act IS
            SELECT a.at_num,
                   a.at_dt,
                   a.at_sc,
                   a.at_cu,
                   a.At_case_class,
                   a.At_action_start_dt,
                   a.At_action_stop_dt,
                   sc.sc_unique,
                   j.nsj_num
              FROM uss_esr.act  a
                   JOIN uss_esr.personalcase pc ON (pc.pc_id = a.at_pc)
                   JOIN uss_esr.At_Person p
                       ON (p.atp_at = a.at_id AND p.atp_sc = pc.pc_sc)
                   JOIN uss_person.v_socialcard sc ON (sc.sc_id = a.at_sc)
                   LEFT JOIN uss_esr.nsp_sc_journal j
                       ON (j.nsj_sc = a.at_sc AND j.nsj_st = 'KN')
             WHERE a.at_id = p_at_id;

        c          c_act%ROWTYPE;

        l_pib_os   VARCHAR2 (100);
        l_str      VARCHAR2 (32000);
        l_at_id    NUMBER;

        l_jbr_id   NUMBER;
        l_result   BLOB;
    BEGIN
        rdm$rtfl_univ.initreport (p_code     => 'ACT_DOC_859_R1',
                                  p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);

        ------------------------------------
        OPEN c_act;

        FETCH c_act INTO c;

        CLOSE c_act;

        l_pib_os := GetScPIB (c.at_sc);

        AddParam ('p1', c.nsj_num);
        AddParam ('p2', UnderLine (l_pib_os, 1));
        --Рівень складності випадку  Uss_Ndi.v_Ddn_Case_Class
        addparam ('p3_1', chk_val ('SM', c.at_case_class));
        addparam ('p3_2', chk_val ('MD', c.at_case_class));
        addparam ('p3_3', chk_val ('DF', c.at_case_class));
        addparam ('p3_4', chk_val ('EM', c.at_case_class));

        addparam (
            'p4',
            NVL2 (c.At_action_start_dt,
                  Date2Str (c.At_action_start_dt),
                  c_date_empty));
        addparam (
            'p5',
            NVL2 (c.At_action_stop_dt,
                  Date2Str (c.At_action_stop_dt),
                  c_date_empty));

        -- 1. Перелік наданих послуг: select * from USS_NDI.v_NDI_SERVICE_TYPE t where t.nst_ap_tp = 'G' order by t.nst_id;
        --l_at_id:= get_at_service_AtId(p_at_id => p_at_id); -- шукаємо at_service
        SELECT MAX (r.at_id)
          INTO l_at_id
          FROM act t JOIN act r ON (r.at_main_link = t.at_main_link)
         WHERE r.at_tp = 'TCTR' AND t.at_id = p_at_id AND r.at_st = 'DT';

        addparam ('a25-1', AtSrvChk (l_at_id, p_nst => 401));
        addparam ('a25-2', AtSrvChk (l_at_id, p_nst => 402));
        addparam ('a25-3', AtSrvChk (l_at_id, p_nst => 403));
        addparam ('a25-4', AtSrvChk (l_at_id, p_nst => 404));
        addparam ('a25-5', AtSrvChk (l_at_id, p_nst => 405));
        addparam ('a25-6', AtSrvChk (l_at_id, p_nst => 406));
        addparam ('a25-7', AtSrvChk (l_at_id, p_nst => 407));
        addparam ('a25-8', AtSrvChk (l_at_id, p_nst => 408));
        addparam ('a25-9', AtSrvChk (l_at_id, p_nst => 409));
        addparam ('a25-10', AtSrvChk (l_at_id, p_nst => 411));
        addparam ('a25-11', AtSrvChk (l_at_id, p_nst => 413));
        addparam ('a25-12', AtSrvChk (l_at_id, p_nst => 414));
        addparam ('a25-13', AtSrvChk (l_at_id, p_nst => 415));
        addparam ('a25-14', AtSrvChk (l_at_id, p_nst => 417));
        addparam ('a25-15', AtSrvChk (l_at_id, p_nst => 418));
        addparam ('a25-16', AtSrvChk (l_at_id, p_nst => 419));
        addparam ('a25-17', AtSrvChk (l_at_id, p_nst => 420));
        addparam ('a25-18', AtSrvChk (l_at_id, p_nst => 421));
        addparam ('a25-19', AtSrvChk (l_at_id, p_nst => 422));
        addparam ('a25-20', AtSrvChk (l_at_id, p_nst => 423));
        addparam ('a25-21', AtSrvChk (l_at_id, p_nst => 425));
        addparam ('a25-22', AtSrvChk (l_at_id, p_nst => 426));
        addparam ('a25-23', AtSrvChk (l_at_id, p_nst => 427));
        addparam ('a25-24', AtSrvChk (l_at_id, p_nst => 428));
        addparam ('a25-25', AtSrvChk (l_at_id, p_nst => 429));
        addparam ('a25-26', AtSrvChk (l_at_id, p_nst => 430));
        addparam ('a25-27', AtSrvChk (l_at_id, p_nst => 432));
        addparam ('a25-28', AtSrvChk (l_at_id, p_nst => 433));
        addparam ('a25-29', AtSrvChk (l_at_id, p_nst => 434));
        addparam ('a25-30', AtSrvChk (l_at_id, p_nst => 435));
        addparam ('a25-31', AtSrvChk (l_at_id, p_nst => 437));
        addparam ('a25-32', AtSrvChk (l_at_id, p_nst => 438));
        addparam ('a25-33', AtSrvChk (l_at_id, p_nst => 439));
        addparam ('a25-34', AtSrvChk (l_at_id, p_nst => 440));
        addparam ('a25-35', AtSrvChk (l_at_id, p_nst => 441));
        addparam ('a25-36', AtSrvChk (l_at_id, p_nst => 442));
        addparam ('a25-37', AtSrvChk (l_at_id, p_nst => 443));

        --2. Основні результати, визначені планом соціального супроводу, та рівні їх досягнення

        l_str :=
            q'[
    select
           row_number() over(order by nsa.nsa_order)  as dsr_1,
           --Зміст результату:
           atip.atip_desc,
           nvl(nsa.nsa_name, atip.atip_nsa_hand_name) as dsr_2,
           --Рівень досягнення  uss_ndi.v_ddn_atr_achiev_level
           uss_esr.Api$Act_Rpt.chk_val('DP', atr.atr_achievment_level) as dsr_31,
           uss_esr.Api$Act_Rpt.chk_val('DC', atr.atr_achievment_level) as dsr_32,
           uss_esr.Api$Act_Rpt.chk_val('ND', atr.atr_achievment_level) as dsr_33,
           atr.atr_result  as dsr_4  --Примітка
      from
           uss_esr.at_results atr,
           uss_esr.At_individual_plan atip,
           uss_ndi.v_ndi_service_type nst,
           uss_ndi.v_ndi_nst_activities nsa
     where 1=1
       and atr.atr_at = :p_at_id
       and atip.atip_id = atr.atr_atip
       and atip.history_status = 'A'
       and nst.nst_id = atip.atip_nst
       and nsa.nsa_id = atip.atip_nsa
    ]';
        l_str :=
            REGEXP_REPLACE (l_str,
                            ':p_at_id',
                            p_at_id,
                            1,
                            0,
                            'i');
        rdm$rtfl_univ.AddDataset ('ds_result', l_str);

        --3. Стан сім’ї/особи та здатність долати СЖО*
        --1 Стан задоволення потреб дитини/особи:  uss_ndi.V_DDN_SS_STSN
        addparam (
            'c3_11',
            chk_val ('SF', Get_Ftr (p_at_id, p_nda => 3059, p_nng => 188)));
        addparam (
            'c3_11_2',
            chk_val ('SF', Get_Ftr (p_at_id, p_nda => 3491, p_nng => 189)));
        addparam (
            'c3_12',
            chk_val ('AVG', Get_Ftr (p_at_id, p_nda => 3059, p_nng => 188)));
        addparam (
            'c3_12_2',
            chk_val ('AVG', Get_Ftr (p_at_id, p_nda => 3491, p_nng => 189)));
        addparam (
            'c3_13',
            chk_val ('NSF', Get_Ftr (p_at_id, p_nda => 3059, p_nng => 188)));
        addparam (
            'c3_13_2',
            chk_val ('NSF', Get_Ftr (p_at_id, p_nda => 3491, p_nng => 189)));
        addparam (
            'c3_14',
            chk_val ('THRT', Get_Ftr (p_at_id, p_nda => 3059, p_nng => 188)));
        addparam (
            'c3_14_2',
            chk_val ('THRT', Get_Ftr (p_at_id, p_nda => 3491, p_nng => 189)));
        --Стан особи/батька uss_ndi.V_DDN_SS_CAPABLE_1
        addparam (
            'c3_21',
            chk_val ('CPB', Get_Ftr (p_at_id, p_nda => 3444, p_nng => 188)));
        addparam (
            'c3_21_2',
            chk_val ('CPB', Get_Ftr (p_at_id, p_nda => 3492, p_nng => 189)));
        addparam (
            'c3_22',
            chk_val ('PRT', Get_Ftr (p_at_id, p_nda => 3444, p_nng => 188)));
        addparam (
            'c3_22_2',
            chk_val ('PRT', Get_Ftr (p_at_id, p_nda => 3492, p_nng => 189)));
        addparam (
            'c3_23',
            chk_val ('NOT', Get_Ftr (p_at_id, p_nda => 3444, p_nng => 188)));
        addparam (
            'c3_23_2',
            chk_val ('NOT', Get_Ftr (p_at_id, p_nda => 3492, p_nng => 189)));
        --Стан особи/матері uss_ndi.V_DDN_SS_CAPABLE_1
        addparam (
            'c3_31',
            chk_val ('CPB', Get_Ftr (p_at_id, p_nda => 3445, p_nng => 188)));
        addparam (
            'c3_31_2',
            chk_val ('CPB', Get_Ftr (p_at_id, p_nda => 3493, p_nng => 189)));
        addparam (
            'c3_32',
            chk_val ('PRT', Get_Ftr (p_at_id, p_nda => 3445, p_nng => 188)));
        addparam (
            'c3_32_2',
            chk_val ('PRT', Get_Ftr (p_at_id, p_nda => 3493, p_nng => 189)));
        addparam (
            'c3_33',
            chk_val ('NOT', Get_Ftr (p_at_id, p_nda => 3445, p_nng => 188)));
        addparam (
            'c3_33_2',
            chk_val ('NOT', Get_Ftr (p_at_id, p_nda => 3493, p_nng => 189)));
        --Вплив факторів сім’ї та середовища на задоволення потреб дитини/особи: uss_ndi.V_DDN_PS_NG_SGN
        addparam (
            'c3_41',
            chk_val ('PS', Get_Ftr (p_at_id, p_nda => 3466, p_nng => 188)));
        addparam (
            'c3_41_2',
            chk_val ('PS', Get_Ftr (p_at_id, p_nda => 3494, p_nng => 189)));
        addparam (
            'c3_42',
            chk_val ('NU', Get_Ftr (p_at_id, p_nda => 3466, p_nng => 188)));
        addparam (
            'c3_42_2',
            chk_val ('NU', Get_Ftr (p_at_id, p_nda => 3494, p_nng => 189)));
        addparam (
            'c3_43',
            chk_val ('NG', Get_Ftr (p_at_id, p_nda => 3466, p_nng => 188)));
        addparam (
            'c3_43_2',
            chk_val ('NG', Get_Ftr (p_at_id, p_nda => 3494, p_nng => 189)));
        --Участь у плануванні та виконанні заходів плану соціального супроводу: особи/батькав
        addparam ('c3_51', Get_Ftr_Chk (p_at_id, p_nda => 3488, p_nng => 188)); --так
        addparam ('c3_51_2',
                  Get_Ftr_Chk (p_at_id, p_nda => 3495, p_nng => 189));
        addparam ('c3_52', Get_Ftr_ChkF (p_at_id, p_nda => 3488, p_nng => 188)); --ні
        addparam ('c3_52_2',
                  Get_Ftr_ChkF (p_at_id, p_nda => 3495, p_nng => 189));
        --Участь у плануванні та виконанні заходів плану соціального супроводу: особи/матері
        addparam ('c3_53', Get_Ftr_Chk (p_at_id, p_nda => 3489, p_nng => 188)); --так
        addparam ('c3_53_2',
                  Get_Ftr_Chk (p_at_id, p_nda => 3496, p_nng => 189));
        addparam ('c3_54', Get_Ftr_ChkF (p_at_id, p_nda => 3489, p_nng => 188)); --ні
        addparam ('c3_54_2',
                  Get_Ftr_ChkF (p_at_id, p_nda => 3496, p_nng => 189));
        --Участь у плануванні та виконанні заходів плану соціального супроводу: дитини
        addparam ('c3_55', Get_Ftr_Chk (p_at_id, p_nda => 3490, p_nng => 188)); --так
        addparam ('c3_55_2',
                  Get_Ftr_Chk (p_at_id, p_nda => 3497, p_nng => 189));
        addparam ('c3_56', Get_Ftr_ChkF (p_at_id, p_nda => 3490, p_nng => 188)); --ні
        addparam ('c3_56_2',
                  Get_Ftr_ChkF (p_at_id, p_nda => 3497, p_nng => 189));

        AddParam ('rec_3_1', Get_Ftr_Nt (p_At_Id, p_Nda => 3491));
        AddParam ('rec_3_2', Get_Ftr_Nt (p_At_Id, p_Nda => 3492));
        AddParam ('rec_3_3', Get_Ftr_Nt (p_At_Id, p_Nda => 3493));
        AddParam ('rec_3_4', Get_Ftr_Nt (p_At_Id, p_Nda => 3494));
        AddParam ('rec_3_5_1', Get_Ftr_Nt (p_At_Id, p_Nda => 3495));
        AddParam ('rec_3_5_2', Get_Ftr_Nt (p_At_Id, p_Nda => 3496));
        AddParam ('rec_3_5_3', Get_Ftr_Nt (p_At_Id, p_Nda => 3497));

        --4. Організація ведення випадку
        addparam ('c4_1', Get_Ftr_Chk (p_at_id, p_nda => 3498));         --так
        addparam ('c4_1_2', Get_Ftr_ChkF (p_at_id, p_nda => 3498));       --ні
        addparam ('c4_2', Get_Ftr_Chk (p_at_id, p_nda => 3499));         --так
        addparam ('c4_2_2', Get_Ftr_ChkF (p_at_id, p_nda => 3499));       --ні
        addparam ('c4_3', Get_Ftr_Chk (p_at_id, p_nda => 3500));         --так
        addparam ('c4_3_2', Get_Ftr_ChkF (p_at_id, p_nda => 3500));       --ні
        addparam ('c4_4', Get_Ftr_Chk (p_at_id, p_nda => 3501));         --так
        addparam ('c4_4_2', Get_Ftr_ChkF (p_at_id, p_nda => 3501));       --ні
        addparam ('c4_5', Get_Ftr_Chk (p_at_id, p_nda => 3503));         --так
        addparam ('c4_5_2', Get_Ftr_ChkF (p_at_id, p_nda => 3503));       --ні
        addparam ('c4_6', Get_Ftr_Chk (p_at_id, p_nda => 3506));         --так
        addparam ('c4_6_2', Get_Ftr_ChkF (p_at_id, p_nda => 3506));       --ні
        addparam ('c4_7', Get_Ftr_Chk (p_at_id, p_nda => 3513));         --так
        addparam ('c4_7_2', Get_Ftr_ChkF (p_at_id, p_nda => 3513));       --ні
        addparam ('c4_8', Get_Ftr_Chk (p_at_id, p_nda => 3515));         --так
        addparam ('c4_8_2', Get_Ftr_ChkF (p_at_id, p_nda => 3515));       --ні
        addparam ('c4_9', Get_Ftr_Chk (p_at_id, p_nda => 3517));         --так
        addparam ('c4_9_2', Get_Ftr_ChkF (p_at_id, p_nda => 3517));       --ні
        addparam ('c4_10', Get_Ftr_Chk (p_at_id, p_nda => 3519));        --так
        addparam ('c4_10_2', Get_Ftr_ChkF (p_at_id, p_nda => 3519));      --ні
        addparam ('c4_11', Get_Ftr_Chk (p_at_id, p_nda => 3531));        --так
        addparam ('c4_11_2', Get_Ftr_ChkF (p_at_id, p_nda => 3531));      --ні
        addparam ('c4_12', Get_Ftr_Chk (p_at_id, p_nda => 3533));        --так
        addparam ('c4_12_2', Get_Ftr_ChkF (p_at_id, p_nda => 3533));      --ні
        addparam ('c4_13', Get_Ftr_Chk (p_at_id, p_nda => 3534));        --так
        addparam ('c4_13_2', Get_Ftr_ChkF (p_at_id, p_nda => 3534));      --ні
        addparam ('c4_14', Get_Ftr_Nt (p_at_id, p_nda => 3534)); --Якщо так, вказати, яких
        addparam ('c4_15', Get_Ftr_Chk (p_at_id, p_nda => 3535));        --так
        addparam ('c4_15_2', Get_Ftr_ChkF (p_at_id, p_nda => 3535));      --ні
        addparam ('c4_16', Get_Ftr_Nt (p_at_id, p_nda => 3535)); --Якщо так, вказати, яких
        addparam ('c4_17', Get_Ftr_Chk (p_at_id, p_nda => 3539));        --так
        addparam ('c4_17_2', Get_Ftr_ChkF (p_at_id, p_nda => 3539));      --ні
        addparam ('c4_18', Get_Ftr_Chk (p_at_id, p_nda => 3540));        --так
        addparam ('c4_18_2', Get_Ftr_ChkF (p_at_id, p_nda => 3540));      --ні
        --Стан задоволення потреб дитини/особи (за результатами супервізії) uss_ndi.V_DDN_STSFCN_SGN
        addparam ('c4_19_1', chk_val ('SF', Get_Ftr (p_at_id, p_nda => 3541)));
        addparam ('c4_19_2',
                  chk_val ('AVG', Get_Ftr (p_at_id, p_nda => 3541)));
        addparam ('c4_19_3',
                  chk_val ('NSF', Get_Ftr (p_at_id, p_nda => 3541)));
        --Соціальну підтримку сім’ї/особи завершено uss_ndi.V_DDN_SS_SUPP_CMPL
        addparam ('c4_20_1',
                  chk_val ('OVR', Get_Ftr (p_at_id, p_nda => 3542)));
        addparam ('c4_20_2',
                  chk_val ('MIN', Get_Ftr (p_at_id, p_nda => 3542)));
        addparam ('c4_21_3', chk_val ('N', Get_Ftr (p_at_id, p_nda => 3542))); --не подолано СЖО
        --у зв’язку з: uss_ndi.V_DDN_SS_NOT_OVRCM
        addparam ('c4_21_1',
                  chk_val ('REF', Get_Ftr (p_at_id, p_nda => 3543))); --письмовою відмовою отримувача
        addparam ('c4_21_2',
                  chk_val ('FAIL', Get_Ftr (p_at_id, p_nda => 3543))); --невиконанням отримувачем соціальних послуг
        addparam ('c4_21_3',
                  chk_val ('MOV', Get_Ftr (p_at_id, p_nda => 3543))); --переїздом отримувача соціальних послуг в іншу місцевість
        addparam ('c4_21_4',
                  chk_val ('ABSN', Get_Ftr (p_at_id, p_nda => 3543))); --відсутністю необхідних соціальних послуг, кваліфікованих спеціалістів
        addparam ('c4_21_5', Get_Ftr_Nt (p_at_id, p_nda => 3543)); --(вказати, яких)
        --інше
        addparam (
            'c4_21_6',
            CASE
                WHEN Get_Ftr_Nt (p_at_id, p_nda => 3544) IS NOT NULL
                THEN
                    c_check
            END);
        addparam ('c4_21_7', Get_Ftr_Nt (p_at_id, p_nda => 3544));

        --підписи
        addparam ('sgn1', NVL2 (c.at_dt, Date2Str (c.at_dt), c_date_empty));
        addparam ('sgn2', UnderLine (GetCuPIB (c.at_cu), 1));
        addparam ('sgn3', UnderLine (l_pib_os, 1));

        ------------------------------------
        rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                         p_rpt_blob   => l_result);
        replace_ekr (l_result);

        RETURN l_result;
    END;


    ----------------------------------------------------------------

    --Типовий договір про надання СП
    --Суто для заглушки. Після отримання постановки можна повністю змінювати реалізацію
    FUNCTION Build_Tctr (p_At_Id IN NUMBER)
        RETURN BLOB
    IS
        l_Jbr_Id   NUMBER;
        l_Result   BLOB;
    BEGIN
        Rdm$rtfl_Univ.Initreport (p_Code     => 'TCTR_FORM',
                                  p_Bld_Tp   => Rdm$rtfl_Univ.c_Bld_Tp_Db);

        FOR Rec IN (SELECT                                             /*a.**/
                           a.At_Num, a.At_Dt
                      FROM Act a
                     WHERE a.At_Id = p_At_Id)
        LOOP
            Rdm$rtfl_Univ.Addparam ('at_num', Rec.At_Num);
            Rdm$rtfl_Univ.Addparam ('at_dt',
                                    TO_CHAR (Rec.At_Dt, 'dd.mm.yyyy'));
            Rdm$rtfl_Univ.Get_Report_Result (p_Jbr_Id     => l_Jbr_Id,
                                             p_Rpt_Blob   => l_Result);

            RETURN l_Result;
        END LOOP;
    END;

    --Заглушка для актів
    --(може використовуватись в налаштуваннях ndi_at_print_form_cofing
    --поки не буде реалізовано відповідну процедуру для побудови форми)
    FUNCTION Build_Stub (p_At_Id IN NUMBER, p_bild_doc NUMBER:= 1)
        RETURN BLOB
    IS
        l_Jbr_Id   NUMBER;
        l_Result   BLOB;
    BEGIN
        IF p_bild_doc IS NULL
        THEN
            NULL;
        END IF;

        Rdm$rtfl_Univ.Initreport (p_Code     => 'AT_STUB',
                                  p_Bld_Tp   => Rdm$rtfl_Univ.c_Bld_Tp_Db);

        FOR Rec IN (SELECT                                             /*a.**/
                           a.At_Num, a.At_Dt
                      FROM Act a
                     WHERE a.At_Id = p_At_Id)
        LOOP
            Rdm$rtfl_Univ.Addparam ('at_num', Rec.At_Num);
            Rdm$rtfl_Univ.Addparam ('at_dt',
                                    TO_CHAR (Rec.At_Dt, 'dd.mm.yyyy'));
            Rdm$rtfl_Univ.Get_Report_Result (p_Jbr_Id     => l_Jbr_Id,
                                             p_Rpt_Blob   => l_Result);
        END LOOP;

        RETURN l_Result;
    END;

    FUNCTION getMonthName (p_mnum NUMBER, p_vidm CHAR:= 'N' -- N,R,D,Z,O,M,K (називний, родовий, давальний...)
                                                           )
        RETURN VARCHAR2
    IS
        l_mname   VARCHAR2 (16);
    BEGIN
        SELECT mon
          INTO l_mname
          FROM (SELECT CASE p_mnum
                           WHEN 1 THEN 'січень'
                           WHEN 2 THEN 'лютий'
                           WHEN 3 THEN 'березень'
                           WHEN 4 THEN 'квітень'
                           WHEN 5 THEN 'травень'
                           WHEN 6 THEN 'червень'
                           WHEN 7 THEN 'липень'
                           WHEN 8 THEN 'серпень'
                           WHEN 9 THEN 'вересень'
                           WHEN 10 THEN 'жовтень'
                           WHEN 11 THEN 'листопад'
                           WHEN 12 THEN 'грудень'
                           ELSE NULL
                       END    mon
                  FROM DUAL
                 WHERE NVL (p_vidm, 'N') = 'N'
                UNION ALL
                SELECT CASE p_mnum
                           WHEN 1 THEN 'січня'
                           WHEN 2 THEN 'лютого'
                           WHEN 3 THEN 'березня'
                           WHEN 4 THEN 'квітня'
                           WHEN 5 THEN 'травня'
                           WHEN 6 THEN 'червня'
                           WHEN 7 THEN 'липня'
                           WHEN 8 THEN 'серпня'
                           WHEN 9 THEN 'вересня'
                           WHEN 10 THEN 'жовтня'
                           WHEN 11 THEN 'листопада'
                           WHEN 12 THEN 'грудня'
                           ELSE NULL
                       END    mon
                  FROM DUAL
                 WHERE p_vidm = 'R') t;

        RETURN l_mname;
    END getMonthName;
END Api$Act_Rpt;
/