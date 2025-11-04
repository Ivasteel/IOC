/* Formatted on 8/12/2025 5:48:24 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.API$ACT_RPTADD
IS
    -- Author  : PAVLO
    -- Created : 22.01.2024 13:04:55
    -- Purpose : Підготовка друкованих форм для актів
    --в пакеті всі документи,починаючи з  NDT=860, БЕЗ індівідуальних планів(ACT_IP_*), плани у пакеті Api$Act_Rpt

    --повертає документ з заяви: p_type=1 паспорт p_type=2 ID картка p_type=3 Свідоцтво про народження
    FUNCTION Get_Passport (p_Ap_Id Appeal.Ap_Id%TYPE, p_Type NUMBER)
        RETURN VARCHAR2;

    -- #92295 "Рішення про припинення надання соціальних послуг"
    FUNCTION Act_Doc_860_R1 (p_At_Id IN NUMBER)
        RETURN BLOB;

    --#92559 «Інформація про припинення надання соціальних послуг»
    FUNCTION Act_Doc_861_R1 (p_At_Id IN NUMBER)
        RETURN BLOB;

    --#100225 "Повідомлення про припинення надання соціальних послуг"
    FUNCTION Act_Doc_862_R1 (p_At_Id IN NUMBER)
        RETURN BLOB;

    --#92201 «Повідомлення-попередження про припинення надання соціальних послуг»
    FUNCTION Act_Doc_863_R1 (p_At_Id IN NUMBER)
        RETURN BLOB;

    --#94117 АНКЕТА первинного оцінювання
    FUNCTION Act_Doc_866_R1 (p_At_Id IN NUMBER)
        RETURN BLOB;

    --#94118 009.1-872-Комплексне визначення ступеня індивідуальних потреб СП підтриманого проживання
    FUNCTION Act_Doc_872_R1 (p_At_Id IN NUMBER)
        RETURN BLOB;

    --#94119 ОЦІНКА ПОТРЕБ прийомної дитини, дитини-вихованця (для послуги 010.2)
    FUNCTION Act_Doc_875_R1 (p_At_Id IN NUMBER)
        RETURN BLOB;

    --#94120 Карта визначення індивідуальних потреб при працевлаштуванні
    FUNCTION Act_Doc_877_R1 (p_At_Id IN NUMBER)
        RETURN BLOB;

    --#94138 Карта визначення інд.потреб в наданні СП перекладу жестовою мовою
    FUNCTION Act_Doc_879_R1 (p_At_Id IN NUMBER)
        RETURN BLOB;

    --#94109 ОЦІНОЧНА ФОРМА ЗА РЕЗУЛЬТАТАМИ ІНФОРМАЦІЙНО-ОЦІНОЧНОЇ ЗУСТРІЧІ З МЕДІАТОРОМ
    FUNCTION Act_Doc_868_R1 (p_At_Id IN NUMBER)
        RETURN BLOB;

    --#94404 АКТ про результат візиту
    FUNCTION Act_Doc_869_R1 (p_At_Id IN NUMBER)
        RETURN BLOB;

    --#94127 015.3-891-Комплексне визначення ступеня інд.потреб отримувача СП денного догляду
    FUNCTION Act_Doc_891_R1 (p_At_Id IN NUMBER)
        RETURN BLOB;

    --#94122 013.0-882-КАРТА визначення індивідуальних потреб послуги соціальної адаптації
    FUNCTION Act_Doc_882_R1 (p_At_Id IN NUMBER)
        RETURN BLOB;

    --#94123 Оцінка потреб особи, яка постраждала від торгівлі людьми
    FUNCTION Act_Doc_885_R1 (p_At_Id IN NUMBER)
        RETURN BLOB;

    --#94123 Оцінка потреб отримувача соціальної послуги соціальної інтеграції та рівня його готовності до самостійного життя (комплексна оцінка)
    FUNCTION Act_Doc_886_R1 (p_At_Id IN NUMBER)
        RETURN BLOB;

    --#94126 015.2-889-Визначення ступеня інд.потреб Догляд стаціонарний
    FUNCTION Act_Doc_889_R1 (p_At_Id IN NUMBER)
        RETURN BLOB;

    --#94128 017.1-896-Комплексне визначення ступеня інд.потреб СП соціальної реабілітації
    FUNCTION Act_Doc_896_R1 (p_At_Id IN NUMBER)
        RETURN BLOB;

    --94135 Оцінювання індивідуальних потреб дитини з інвалідністю для послуги 018.1
    FUNCTION Act_Doc_898_R1 (p_At_Id IN NUMBER)
        RETURN BLOB;

    --#94250 Акт проведення оцінки рівня безпеки дитини для послуги 012.0
    FUNCTION Act_Doc_1000_R1 (p_At_Id IN NUMBER)
        RETURN BLOB;

    --#94137 Карта визначення СП фізичного супроводу для послуги 021.0
    FUNCTION Act_Doc_1002_R1 (p_At_Id IN NUMBER)
        RETURN BLOB;

    --#94136 КАРТКА ОЦІНЮВАННЯ індивідуальних потреб отримувача соціальної послуги 020.0
    FUNCTION Act_Doc_1005_R1 (p_At_Id IN NUMBER)
        RETURN BLOB;

    --#98708 015.1- Соціальна послуга Догляд вдома
    FUNCTION Act_Doc_1013_R1 (p_At_Id IN NUMBER)
        RETURN BLOB;
END Api$act_Rptadd;
/


/* Formatted on 8/12/2025 5:48:49 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.API$ACT_RPTADD
IS
    c_chr10        CONSTANT VARCHAR2 (10) := Api$act_Rpt.cnst_par;

    c_date_empty   CONSTANT VARCHAR2 (30) := '«____»____________20___';

    --c_date_empty2 constant varchar2(30) := '____.____ 20___';

    TYPE R_NSP IS RECORD
    (
        Nm         VARCHAR2 (200),
        Phone      VARCHAR2 (200),
        Email      VARCHAR2 (200),
        Address    VARCHAR2 (500)
    );

    --заміна c_ekr1/c_ekr2/c_ekr3 на ісходні символи
    PROCEDURE replace_ekr (p_result IN OUT BLOB)
    IS
    BEGIN
        uss_esr.Api$Act_Rpt.replace_ekr (p_result => p_result);
    END;

    FUNCTION NVL2 (val1 VARCHAR2, val2 VARCHAR2, val3 VARCHAR2:= NULL)
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN CASE WHEN val1 IS NOT NULL THEN val2 ELSE val3 END;
    END;

    FUNCTION GetScPIB (p_Sc_id NUMBER)
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN uss_esr.Api$Act_Rpt.GetScPIB (p_Sc_id);
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

    --прізвище та ініціали
    FUNCTION Underline (p_val VARCHAR2, p_mode IN NUMBER)
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN api$act_rpt.Underline (p_val, p_mode);
    END;

    --Власне ім’я прізвище
    FUNCTION Get_Ipr (p_Pib VARCHAR2)
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN Api$Act_Rpt.Get_IPr (p_Pib);
    END;

    PROCEDURE AddParam (p_Param_Name VARCHAR2, p_Param_Value VARCHAR2)
    IS
    BEGIN
        uss_esr.Api$Act_Rpt.AddParam (p_Param_Name    => p_Param_Name,
                                      p_Param_Value   => p_Param_Value);
    END;

    --повертає at_section_feature.atef_notes
    FUNCTION Get_Ftr_Nt (p_at_id   act.at_id%TYPE,
                         p_atp     at_person.atp_id%TYPE:= -1,
                         p_nda     NUMBER,
                         p_nng     NUMBER:= -1)
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN uss_esr.Api$Act_Rpt.Get_Ftr_Nt (p_at_id   => p_at_id,
                                               p_atp     => p_atp,
                                               p_nda     => p_nda,
                                               p_nng     => p_nng);
    END;

    --повертає at_section_feature.atef_feature
    FUNCTION Get_Ftr (p_at_id   act.at_id%TYPE,
                      p_atp     at_person.atp_id%TYPE:= -1,
                      p_nda     NUMBER,
                      p_nng     NUMBER:= -1)
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN uss_esr.Api$Act_Rpt.Get_Ftr (p_at_id   => p_at_id,
                                            p_atp     => p_atp,
                                            p_nda     => p_nda,
                                            p_nng     => p_nng);
    END;

    --прямокутник з галочкой / прямокутник без галочки
    FUNCTION Get_Ftr_Chk2 (p_at_id   act.at_id%TYPE,
                           p_atp     at_person.atp_id%TYPE:= -1,
                           p_nda     NUMBER,
                           p_nng     NUMBER:= -1,
                           p_chk     VARCHAR2:= 'T')
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN uss_esr.Api$Act_Rpt.Get_Ftr_Chk2 (p_at_id   => p_at_id,
                                                 p_atp     => p_atp,
                                                 p_nda     => p_nda,
                                                 p_nng     => p_nng,
                                                 p_chk     => p_chk);
    END;

    --повертає v_ndi_document_attr.nda_indicator1 у випадку, коли він зачекен
    FUNCTION Get_Ftr_Ind (p_at_id   act.at_id%TYPE,
                          p_atp     at_person.atp_id%TYPE:= -1,
                          p_nda     NUMBER,
                          p_nng     NUMBER:= -1,
                          p_chk     VARCHAR2:= 'T')
        RETURN VARCHAR2                                               --number
    IS
    BEGIN
        RETURN uss_esr.Api$act_Rpt.Get_Ftr_Ind (p_At_Id   => p_At_Id,
                                                p_Atp     => p_Atp,
                                                p_Nda     => p_Nda,
                                                p_Nng     => p_Nng,
                                                p_Chk     => p_Chk);
    END;

    FUNCTION get_AtPerson_id (p_at            NUMBER,
                              p_App_Tp        VARCHAR2,
                              p_App_Tp_only   INTEGER:= NULL)
        RETURN NUMBER
    IS
    BEGIN
        RETURN uss_esr.Api$Act_Rpt.get_AtPerson_id (
                   p_at            => p_at,
                   p_App_Tp        => p_App_Tp,
                   p_App_Tp_only   => p_App_Tp_only);
    END;

    FUNCTION get_AtPerson (p_at NUMBER, p_atp NUMBER)
        RETURN uss_esr.api$act_rpt.R_Person_for_act
    IS
    BEGIN
        RETURN uss_esr.Api$Act_Rpt.get_AtPerson (p_at => p_at, p_atp => p_atp);
    END;

    --підписант акта
    FUNCTION get_signers_wucu_pib (p_at_id      NUMBER,
                                   p_ati_tp     VARCHAR2,
                                   p_ati_cuwu   NUMBER:= NULL,
                                   p_ndt        NUMBER:= NULL)
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN uss_esr.Api$Act_Rpt.get_signers_wucu_pib (
                   p_at_id      => p_at_id,
                   p_ati_tp     => p_ati_tp,
                   p_ati_cuwu   => p_ati_cuwu,
                   p_ndt        => p_ndt);
    END;

    --повертає документ з заяви: p_type=1 паспорт p_type=2 ID картка p_type=3 Свідоцтво про народження
    FUNCTION Get_Passport (p_Ap_Id Appeal.Ap_Id%TYPE, p_Type NUMBER)
        RETURN VARCHAR2
    IS
        l_Nda_Num   NUMBER;
        l_Nda_Who   NUMBER;
        l_Nda_Dt    NUMBER;
        l_Nda_Dt2   NUMBER;

        l_Str1      VARCHAR2 (500);
        l_Str2      VARCHAR2 (500);
        l_Str3      VARCHAR2 (500);
        l_Str4      VARCHAR2 (500);
    BEGIN
        CASE p_Type
            --паспорт
            WHEN 1
            THEN
                l_Nda_Num := 3;
                l_Nda_Who := 7;
                l_Nda_Dt := 5;
            --ID картка
            WHEN 2
            THEN
                l_Nda_Num := 9;
                l_Nda_Who := 13;
                l_Nda_Dt := 14;
                l_Nda_Dt2 := 10;
            --Свідоцтво про народження
            WHEN 3
            THEN
                l_Nda_Num := 90;
                l_Nda_Who := 93;
                l_Nda_Dt := 94;
            ELSE
                NULL;
        END CASE;

        l_Str1 := Api$act_Rpt.Get_Ap_Doc_Atr_Str (p_Ap_Id, l_Nda_Num); --номер

        IF l_Str1 IS NULL
        THEN
            RETURN NULL;
        END IF;

        l_Str2 := Api$act_Rpt.Get_Ap_Doc_Atr_Str (p_Ap_Id, l_Nda_Who);
        l_Str3 :=
            TO_CHAR (Api$act_Rpt.Get_Ap_Doc_Atr_Str (p_Ap_Id, l_Nda_Dt),
                     'dd.mm.yyyy');
        l_Str4 :=
            TO_CHAR (Api$act_Rpt.Get_Ap_Doc_Atr_Str (p_Ap_Id, l_Nda_Dt2),
                     'dd.mm.yyyy');

        l_Str1 :=
               l_Str1
            || NVL2 (l_Str2, ' видан ' || l_Str2)
            || NVL2 (l_Str3, ' ' || l_Str3 || ' р.')
            || NVL2 (l_Str4, ' дійсний до ' || l_Str4 || ' р.');
        RETURN l_Str1;
    END Get_Passport;

    --підписант акта p_order = 1 - перший підпеисант 2-другий підписант
    FUNCTION Get_At_Signers (p_At_Id NUMBER, p_Order NUMBER)
        RETURN VARCHAR2
    IS
        CURSOR c IS
            SELECT MAX (
                       DECODE (
                           Rn,
                           1, NVL (Api$act_Rpt.Getcupib (Ati_Cu),
                                   Tools.Getuserpib (Ati_Wu))))
                       FIRST_VALUE,
                   MAX (
                       DECODE (
                           Rn,
                           Cnt, NVL (Api$act_Rpt.Getcupib (Ati_Cu),
                                     Tools.Getuserpib (Ati_Wu))))
                       LAST_VALUE
              FROM (SELECT s.Ati_Wu,
                           s.Ati_Cu,
                           ROW_NUMBER ()
                               OVER (ORDER BY NVL (s.Ati_Order, s.Ati_Id))
                               Rn,
                           COUNT (*) OVER ()
                               Cnt
                      FROM At_Signers s
                     WHERE s.Ati_At = p_At_Id AND s.History_Status = 'A');

        l_Sng1   VARCHAR2 (100);
        l_Sng2   VARCHAR2 (100);
    BEGIN
        OPEN c;

        FETCH c INTO l_Sng1, l_Sng2;

        CLOSE c;

        RETURN CASE p_Order WHEN 1 THEN l_Sng1 WHEN 2 THEN l_Sng2 END;
    END;

    /*info:    надавач послуги назва, телефон, адреса
      author:  pvl
    */
    FUNCTION Get_Nsp_Rec (p_Rnspm_Id Uss_Rnsp.v_Rnsp.Rnspm_Id%TYPE)
        RETURN r_Nsp
    IS
        CURSOR Cur IS
            SELECT TRIM (
                       REPLACE (
                           (CASE r.Rnspm_Tp
                                WHEN 'O'
                                THEN
                                    COALESCE (r.Rnsps_Last_Name,
                                              r.Rnsps_First_Name)
                                ELSE
                                       r.Rnsps_Last_Name
                                    || ' '
                                    || r.Rnsps_First_Name
                                    || ' '
                                    || r.Rnsps_Middle_Name
                            END),
                           '  '))    Nm,
                   r.Rnspo_Email,
                   r.Rnspo_Phone,
                   r.Rnspa_Kaot,
                   r.Rnspa_Index,
                   r.Rnspa_Street,
                   r.Rnspa_Building,
                   r.Rnspa_Korp,
                   r.Rnspa_Appartement
              FROM Uss_Rnsp.v_Rnsp r
             WHERE r.Rnspm_Id = p_Rnspm_Id;

        c        Cur%ROWTYPE;

        l_kt     VARCHAR2 (500);
        RESULT   r_Nsp;
    BEGIN
        OPEN Cur;

        FETCH Cur INTO c;

        CLOSE Cur;

        l_kt := Api$act_Rpt.Get_Katottg_Info (p_Kaot_Id => c.Rnspa_Kaot);

        Result.Nm := c.Nm;
        Result.Phone := c.Rnspo_Phone;
        Result.Email := c.Rnspo_Email;
        Result.Address :=
            Api$act_Rpt.Get_Adr (p_Ind     => c.Rnspa_Index,
                                 p_Katot   => l_kt,
                                 p_Strit   => c.Rnspa_Street,
                                 p_Bild    => c.Rnspa_Building,
                                 p_Korp    => c.Rnspa_Korp,
                                 p_Kv      => c.Rnspa_Appartement);
        RETURN RESULT;
    END;

    --p_nst = '123, 3451'
    FUNCTION Get_Nst_Lst (p_Nst VARCHAR2, p_Dlm VARCHAR2:= ', ')
        RETURN VARCHAR2
    IS
        l_Res   VARCHAR2 (1000);
    BEGIN
        SELECT LISTAGG (St.Nst_Name, p_Dlm)
                   WITHIN GROUP (ORDER BY St.Nst_Order)
          INTO l_Res
          FROM Uss_Ndi.v_Ndi_Service_Type St, XMLTABLE (p_Nst) t
         WHERE St.Nst_Id IN TO_NUMBER (t.COLUMN_VALUE);

        RETURN l_Res;
    END;

    FUNCTION get_reason_not_pay_name (p_rnp_id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Str   VARCHAR2 (4000);
    BEGIN
        SELECT MAX (t.rnp_name)
          INTO l_str
          FROM uss_ndi.v_ndi_reason_not_pay t
         WHERE t.rnp_id = p_rnp_id;

        RETURN l_str;
    END;

    --причина припинення надання соціальних послуг
    FUNCTION Get_Reason_Not_Pay_Doc (p_Ap NUMBER)
        RETURN VARCHAR2
    IS
        l_Str   VARCHAR2 (32000);
    BEGIN
        SELECT MAX (t.Rnp_Name)
          INTO l_Str
          FROM Ap_Document                   d,
               Ap_Document_Attr              Da,
               Uss_Ndi.v_Ndi_Reason_Not_Pay  t
         WHERE     d.Apd_Ap = p_Ap
               AND d.History_Status = 'A'
               AND d.Apd_Id = Da.Apda_Apd
               AND Da.History_Status = 'A'
               AND Da.Apda_Nda IN (3076, 3066)
               AND t.Rnp_Id = Da.Apda_Val_String;

        RETURN l_Str;
    END;

    --причина припинення надання соціальних послуг
    FUNCTION Get_At_Rnp (p_At_Id NUMBER)
        RETURN VARCHAR2
    IS
        l_Str   VARCHAR2 (32000);
    BEGIN
        SELECT MAX (t.Rnp_Name)
          INTO l_Str
          FROM act  a
               JOIN Uss_Ndi.v_Ndi_Reason_Not_Pay t ON (t.rnp_id = a.at_rnp)
         WHERE a.at_id = p_At_Id;

        RETURN l_Str;
    END;


    --Фахівець
    FUNCTION Get_Sctn_Specialist (p_At_Id NUMBER, p_Ate_Nng_Ank NUMBER --nng_id з розділу "Анкета визначення рейтингу соціальних потреб..."
                                                                      )
        RETURN At_Other_Spec%ROWTYPE
    IS
        l_Res   At_Other_Spec%ROWTYPE;
    BEGIN
        SELECT Osp.*
          INTO l_Res
          FROM Uss_Esr.At_Section s, Uss_Esr.At_Other_Spec Osp
         WHERE     1 = 1
               AND s.Ate_At = p_At_Id
               AND s.Ate_Nng = p_Ate_Nng_Ank
               AND Osp.Atop_Id = s.Ate_Atop
         FETCH FIRST ROW ONLY;

        RETURN l_res;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    -- #92295 "Рішення про припинення надання соціальних послуг"
    --USS_ESR.Cmes$act_Rstopss
    FUNCTION Act_Doc_860_R1 (p_At_Id IN NUMBER)
        RETURN BLOB
    IS
        CURSOR c_At IS
            SELECT a.At_Dt,
                   a.At_Num,
                   a.At_Sc,
                   a.At_Ap,
                   a.At_Rnspm,
                   a.At_Cu,
                   a.At_Wu,
                   o.Org_Name,
                   (SELECT Rn.Rnp_Name
                      FROM Uss_Ndi.v_Ndi_Reason_Not_Pay Rn
                     WHERE Rn.Rnp_Id = a.At_Rnp)    AS Term_Reason
              FROM Act a, v_Opfu o
             WHERE a.At_Id = p_At_Id AND o.Org_Id = a.At_Org;

        c          c_At%ROWTYPE;

        l_Str      VARCHAR2 (32000);

        l_Jbr_Id   NUMBER;
        l_Result   BLOB;
    BEGIN
        Rdm$rtfl_Univ.Initreport (p_Code     => 'ACT_DOC_860_R1',
                                  p_Bld_Tp   => Rdm$rtfl_Univ.c_Bld_Tp_Db);

        ------------------------------------

        OPEN c_At;

        FETCH c_At INTO c;

        CLOSE c_At;

        /*
        --вичитка з акту
        AddParam('p1', To_Char(c.At_Dt, 'dd.mm.yyyy'));
        AddParam('p2', c.At_Num);
        AddParam('p3', c.Org_Name);
        AddParam('p4', Getscpib(c.At_Sc));
        --надавач соцпослуг
        AddParam('p5', Api$act_Rpt.Get_Nsp_Name(p_Rnspm_Id => c.At_Rnspm));

        --Перелік соціальних послуг
        \*select listagg(to_char(rn) || ') ' || nst_name, ';' || chr(10)) within group (order by rn)
        into l_str
        from (select row_number() over (order by st.nst_order) as rn, st.nst_name
                from v_ap_service s
                join uss_ndi.v_ndi_service_type st on st.nst_id = s.aps_nst
               where s.aps_ap = c.ap_id
                 and s.history_status = 'A');*\
        l_Str := Api$act_Rpt.Atsrv_Nst_List(p_At_Id => p_At_Id, p_Tp => 0, p_Dlm => '; ' || c_Chr10);
        AddParam('p6', l_Str);
        AddParam('p7', Coalesce(Api$act_Rpt.Get_At_Reject_List(p_At_Id), '______________________________')); --причини
        AddParam('p9', Coalesce(Get_At_Signers(p_At_Id, 1),  '_________________________')); --sign_first_pib
        AddParam('p10', Coalesce(Get_At_Signers(p_At_Id, 2), '_________________________')); --sign_last_pib

        AddParam('p11', Nvl(To_Char(c.At_Dt, 'dd.mm.yyyy'), c_Date_Empty || ' року'));*/

        /*
        --вичитка з документів
        AddParam('p1', Api$act_Rpt.AtDocAtrDt(p_At_Id, 3080));
        AddParam('p2', Api$act_Rpt.AtDocAtrStr(p_At_Id, 3081));
        AddParam('p3', Api$act_Rpt.AtDocAtrStr(p_At_Id, 3086));
        AddParam('p4', Api$act_Rpt.At_Doc_Atr_Lst(p_At_Id, '3087,3088,3089'));
        --надавач соцпослуг
        AddParam('p5', Api$act_Rpt.AtDocAtrStr(p_At_Id, 3090));

        --Перелік соціальних послуг
        --l_Str := Api$act_Rpt.Atsrv_Nst_List(p_At_Id => p_At_Id, p_Tp => 0, p_Dlm => '; ' || c_Chr10);
        l_Str := Get_Nst(Api$act_Rpt.AtDocAtrStr(p_At_Id, 3091         ), '; ' || c_Chr10);
        AddParam('p6', l_Str);
        AddParam('p7', nvl(Api$act_Rpt.Get_At_Reject_List(p_At_Id), '______________________________')); --причини

        --спеціалист
        AddParam('p9-1', Api$act_Rpt.AtDocAtrStr(p_At_Id, 3093));
        l_str:= Api$act_Rpt.At_Doc_Atr_Lst(p_At_Id, '3094,3095');
        AddParam('p9',  nvl2(REPLACE(l_str, ''), l_str, '_________________________'));
        --керівник
        AddParam('p10-1', Api$act_Rpt.AtDocAtrStr(p_At_Id, 3096));
        l_str:= Api$act_Rpt.At_Doc_Atr_Lst(p_At_Id, '3097,3098');
        AddParam('p10', nvl2(REPLACE(l_str, ''), l_str, '_________________________'));

        AddParam('p11', Nvl(To_Char(c.At_Dt, 'dd.mm.yyyy'), c_Date_Empty || ' року'));*/

        --вичитка комбінована
        Addparam ('p1', Api$act_Rpt.AtDocAtrDt (p_At_Id, 3080) /*To_Char(c.At_Dt, 'dd.mm.yyyy')*/
                                                              );
        Addparam ('p2', c.At_Num);
        Addparam ('p3', c.Org_Name);
        Addparam (
            'p4',                                        /*Getscpib(c.At_Sc)*/
               api$act_rpt.AtDocAtrStr (p_At_Id, 3087)
            || ' '
            || api$act_rpt.AtDocAtrStr (p_At_Id, 3088)
            || ' '
            || api$act_rpt.AtDocAtrStr (p_At_Id, 3089));
        --надавач соцпослуг
        Addparam ('p5', Api$act_Rpt.Get_Nsp_Name (p_Rnspm_Id => c.At_Rnspm));

        --Перелік соціальних послуг
        /*select listagg(to_char(rn) || ') ' || nst_name, ';' || chr(10)) within group (order by rn)
        into l_str
        from (select row_number() over (order by st.nst_order) as rn, st.nst_name
                from at_service s,
                     uss_ndi.v_ndi_service_type st
               where s.ats_at = p_at_id
                 AND st.nst_id = s.ats_nst
                 and s.history_status = 'A');*/
        l_Str :=
            Api$act_Rpt.Atsrv_Nst_List (p_At_Id   => p_At_Id,
                                        p_Tp      => 3,
                                        p_Dlm     => '; ' || c_Chr10);
        Addparam ('p6', l_Str);
        --Addparam('p7', nvl(Get_Reason_Not_Pay_doc(p_ap => c.at_ap), Get_At_Rnp(p_At_Id)), '______________________________')); --причини   Api$act_Rpt.Get_At_Reject_List(p_At_Id) ??
        Addparam (
            'p7',
            COALESCE (
                get_reason_not_pay_name (
                    api$act_rpt.Atdocatrstr (p_At_Id, 3092)),
                '______________________________')); --причини   Api$act_Rpt.Get_At_Reject_List(p_At_Id) ??
        --спеціалист
        Addparam ('p9-1', Api$act_Rpt.Atdocatrstr (p_At_Id, 3093));
        l_Str := Api$act_Rpt.At_Doc_Atr_Lst (p_At_Id, '3094,3095');
        /*Addparam('p9',
                 Coalesce(Get_Ipr(Api$act.Get_At_Spec_Name(c.At_Wu, c.At_Cu)), Nvl2(REPLACE(l_Str, ''), l_Str),
                           '_________________________'));*/
        l_Str := Api$act_Rpt.At_Doc_Atr_Lst (p_At_Id, '3094,3095');
        Addparam (
            'p9',
            NVL2 (REPLACE (l_Str, ' '), l_Str, '_________________________'));

        --керівник
        Addparam ('p10-1', Api$act_Rpt.Atdocatrstr (p_At_Id, 3096));
        l_Str := Api$act_Rpt.At_Doc_Atr_Lst (p_At_Id, '3097,3098');
        Addparam (
            'p10',
            NVL2 (REPLACE (l_Str, ' '), l_Str, '_________________________'));

        Addparam (
            'p11',
            NVL (TO_CHAR (SYSDATE                                  /*c.At_Dt*/
                                 , 'dd.mm.yyyy'), c_Date_Empty || ' року'));

        ------------------------------------
        Rdm$rtfl_Univ.Get_Report_Result (p_Jbr_Id     => l_Jbr_Id,
                                         p_Rpt_Blob   => l_Result);
        Replace_Ekr (l_Result);

        RETURN l_Result;
    END;

    /*info:    «Інформація про припинення надання соціальних послуг»
      request: #92559, #100402
    */
    FUNCTION Act_Doc_861_R1 (p_At_Id IN NUMBER)
        RETURN BLOB
    IS
        CURSOR c_Act IS
            SELECT a.At_Org,
                   a.At_Rnspm,
                   a.At_Live_Address,
                   a.At_Action_Stop_Dt,
                   a.At_Ap,
                   Rnp.Rnp_Name,
                   A1.At_Num,
                   A1.At_Dt,
                   A2.At_Num     AS at_num_pdsp,
                   A2.At_Dt      AS at_dt_pdsp
              FROM Act  a
                   LEFT JOIN at_links l
                       ON (l.atk_at = a.at_id AND l.atk_tp = 'TCTR')
                   LEFT JOIN Act A1 ON (a1.at_id = l.atk_link_at)      -- tctr
                   LEFT JOIN act a2 ON (a2.at_id = a1.at_main_link)    -- pdsp
                   LEFT JOIN Uss_Ndi.v_Ndi_Reason_Not_Pay Rnp
                       ON (rnp.rnp_id = a.at_rnp)
             WHERE a.At_Id = p_At_Id;

        c            c_Act%ROWTYPE;

        l_Atp_o      NUMBER := Get_Atperson_Id (p_At_Id, 'OS');    --отримувач
        l_Prs_o      Api$act_Rpt.r_Person_For_Act
                         := Get_Atperson (p_At_Id, l_Atp_o);
        --l_Atp_z NUMBER := Get_Atperson_Id(p_At_Id, 'Z'); --заявник
        --l_Prs_z Api$act_Rpt.r_Person_For_Act := Get_Atperson(p_At_Id, l_Atp_z);

        l_Nsp        r_Nsp;
        l_Boss_Pib   VARCHAR2 (100);

        l_Jbr_Id     NUMBER;
        l_Result     BLOB;
    BEGIN
        Rdm$rtfl_Univ.Initreport (p_Code     => 'ACT_DOC_861_R1',
                                  p_Bld_Tp   => Rdm$rtfl_Univ.c_Bld_Tp_Db);

        ------------------------------------
        OPEN c_Act;

        FETCH c_Act INTO c;

        CLOSE c_Act;

        --надавач соцпослуг
        l_Nsp := Get_Nsp_Rec (p_Rnspm_Id => c.At_Rnspm);

        Addparam ('p1', Tools.Getorgname (c.At_Org));
        Addparam ('p2', l_Nsp.Nm);
        Addparam ('p3', l_Nsp.Address);
        Addparam ('p4', l_Nsp.Phone);
        Addparam ('p5', l_Nsp.Email);

        --AddParam('p6', Api$act_Rpt.Atdocatrstr(p_At_Id, 3071));
        Addparam ('p7', TO_CHAR (c.At_Dt_Pdsp, 'dd.mm.yyyy') /*Api$act_Rpt.Atdocatrdt(p_At_Id, 3072)*/
                                                            );
        Addparam ('p8', c.at_num_pdsp /*Api$act_Rpt.Atdocatrstr(p_At_Id, 3073)*/
                                     );
        Addparam ('p9', l_Prs_o.Pib);
        Addparam ('p10', c.At_Num);
        Addparam ('p11', TO_CHAR (c.At_Dt, 'dd.mm.yyyy'));
        Addparam ('p12',
                  Api$act_Rpt.Atsrv_Nst_List (p_At_Id, 3, '; ' || c_Chr10)); -- Перелік соціальних послуг
        Addparam (
            'p13',
            NVL (
                get_reason_not_pay_name (
                    Api$act_Rpt.Atdocatrstr (p_At_Id, 3076)) /*Get_Reason_Not_Pay_Doc(p_Ap => c.At_Ap)*/
                                                            ,
                c.Rnp_Name));                            --підстава припинення
        Addparam ('p14', Api$act_Rpt.Atdocatrstr (p_At_Id, 3077));
        --AddParam('p15', To_Char(c.At_Action_Stop_Dt, 'dd.mm.yyyy'));
        --підписант  Керівник надавача соціальних послуг
        Addparam ('p16', Api$act_Rpt.Atdocatrstr (p_At_Id, 8312));    --посада
        --l_Boss_Pib := Get_Signers_Wucu_Pib(p_At_Id => p_At_Id, p_Ati_Tp => 'PR', p_Ati_Cuwu => 2, p_Ndt => 861);
        l_Boss_Pib := Api$act_Rpt.At_Doc_Atr_Lst (p_At_Id, 8313);
        Addparam ('p17', l_Boss_Pib);

        ------------------------------------
        Rdm$rtfl_Univ.Get_Report_Result (p_Jbr_Id     => l_Jbr_Id,
                                         p_Rpt_Blob   => l_Result);
        Replace_Ekr (l_Result);

        RETURN l_Result;
    END Act_Doc_861_R1;

    --#100225 "Повідомлення про припинення надання соціальних послуг"
    FUNCTION Act_Doc_862_R1 (p_At_Id IN NUMBER)
        RETURN BLOB
    IS
        CURSOR c_At IS
            SELECT a.At_Dt,
                   a.At_Num,
                   a.at_tp,
                   a.At_Sc,
                   a.At_Ap,
                   a.At_Rnspm,
                   o.Org_Name,
                   (SELECT Rn.Rnp_Name
                      FROM Uss_Ndi.v_Ndi_Reason_Not_Pay Rn
                     WHERE Rn.Rnp_Id = a.At_Rnp)    AS Term_Reason
              FROM Act a, v_Opfu o
             WHERE a.At_Id = p_At_Id AND o.Org_Id = a.At_Org;

        c            c_At%ROWTYPE;

        l_Str        VARCHAR2 (32000);

        --l_Prs_z Api$act_Rpt.r_Person_For_Act; --замовник;
        l_Prs_o      Api$act_Rpt.r_Person_For_Act;                 --отримувач

        l_Jbr_Id     NUMBER;
        l_Result     BLOB;
        l_tctr_id    NUMBER;
        l_tctr_ap    NUMBER;
        l_app_id     NUMBER;
        l_tctr_num   VARCHAR2 (100);
    BEGIN
        Rdm$rtfl_Univ.Initreport (p_Code     => 'ACT_DOC_862_R1',
                                  p_Bld_Tp   => Rdm$rtfl_Univ.c_Bld_Tp_Db);

        ------------------------------------

        OPEN c_At;

        FETCH c_At INTO c;

        CLOSE c_At;

        l_tctr_num := Api$appeal.Get_Ap_Doc_Str (c.at_ap, 'TCTRNUM');

          SELECT MAX (a.At_Id), MAX (a.At_Ap), MAX (q.app_id)
            INTO l_Tctr_Id, l_tctr_ap, l_app_id
            FROM Act a
                 JOIN Ap_Person p
                     ON     p.App_Ap = c.at_ap
                        AND p.App_Tp IN ('Z', 'OS')
                        AND p.History_Status = 'A'
                 JOIN ap_person q
                     ON (q.app_ap = a.at_ap AND q.app_sc = p.app_sc)
           WHERE     a.At_Num = l_tctr_num
                 AND a.At_Tp = 'TCTR'
                 AND a.At_Sc = p.App_Sc
                 AND a.At_St IN ('DT')
        ORDER BY a.At_Dt DESC--FETCH FIRST ROW ONLY
                             ;

        --l_Prs_z := Get_Atperson(p_At_Id, Get_Atperson_Id(p_At_Id, 'Z'));
        l_Prs_o := Get_Atperson (p_At_Id, Get_Atperson_Id (p_At_Id, 'OS'));

        AddParam (
            'p1',
            COALESCE (l_Prs_o.Pib,
                      '___________________________________________'));

        -- адреса з документа 605
        l_Str :=
            Api$act_Rpt.Get_Adr (
                p_Ind   =>
                    Api$act_Rpt.Get_Ap_Doc_Atr_Str (c.At_Ap,
                                                    1625,
                                                    l_Prs_o.Atp_App),
                p_Katot   =>
                    Api$act_Rpt.Get_Ap_Doc_Atr_Str (c.At_Ap,
                                                    1618,
                                                    l_Prs_o.Atp_App),
                p_Strit   =>
                    NVL (
                        Api$act_Rpt.Get_Ap_Doc_Atr_Str (c.At_Ap,
                                                        1632,
                                                        l_Prs_o.Atp_App),
                        Api$act_Rpt.Get_Ap_Doc_Atr_Str (c.At_Ap,
                                                        1640,
                                                        l_Prs_o.Atp_App)),
                p_Bild   =>
                    Api$act_Rpt.Get_Ap_Doc_Atr_Str (c.At_Ap,
                                                    1648,
                                                    l_Prs_o.Atp_App),
                p_Korp   =>
                    Api$act_Rpt.Get_Ap_Doc_Atr_Str (c.At_Ap,
                                                    1654,
                                                    l_Prs_o.Atp_App),
                p_Kv   =>
                    Api$act_Rpt.Get_Ap_Doc_Atr_Str (c.At_Ap,
                                                    1659,
                                                    l_Prs_o.Atp_App));

        IF (l_str IS NULL AND l_tctr_ap IS NOT NULL)
        THEN
            l_Str :=
                Api$act_Rpt.Get_Adr (
                    p_Ind   =>
                        Api$act_Rpt.Get_Ap_Doc_Atr_Str (l_tctr_ap,
                                                        1625,
                                                        l_app_id),
                    p_Katot   =>
                        Api$act_Rpt.Get_Ap_Doc_Atr_Str (l_tctr_ap,
                                                        1618,
                                                        l_app_id),
                    p_Strit   =>
                        NVL (
                            Api$act_Rpt.Get_Ap_Doc_Atr_Str (l_tctr_ap,
                                                            1632,
                                                            l_app_id),
                            Api$act_Rpt.Get_Ap_Doc_Atr_Str (l_tctr_ap,
                                                            1640,
                                                            l_app_id)),
                    p_Bild   =>
                        Api$act_Rpt.Get_Ap_Doc_Atr_Str (l_tctr_ap,
                                                        1648,
                                                        l_app_id),
                    p_Korp   =>
                        Api$act_Rpt.Get_Ap_Doc_Atr_Str (l_tctr_ap,
                                                        1654,
                                                        l_app_id),
                    p_Kv   =>
                        Api$act_Rpt.Get_Ap_Doc_Atr_Str (l_tctr_ap,
                                                        1659,
                                                        l_app_id));
        END IF;

        AddParam (
            'p2',
            NVL (l_Str, '______________________________________________'));
        AddParam (
            'p3',
            CASE
                WHEN c.at_tp = 'PPNP'
                THEN
                    uss_esr.Api$act_Rpt.Get_Nsp_Name (c.At_Rnspm)
                ELSE
                    c.Org_Name
            END);
        AddParam ('p4', Api$act_Rpt.AtDocAtrDt (p_At_Id, 3109) /* To_Char(c.At_Dt, 'dd.mm.yyyy')*/
                                                              );
        AddParam (
            'p5',
            CASE
                WHEN c.at_tp = 'PPNP'
                THEN
                    Api$act_rpt.Atdocatrstr (p_At_Id, 3110)
                ELSE
                    c.At_Num
            END);
        AddParam ('p6', l_Prs_o.Pib);
        AddParam ('p7', uss_esr.Api$act_Rpt.Get_Nsp_Name (c.At_Rnspm));
        --підстава припинення
        --AddParam('p8', Nvl(nvl(Get_Reason_Not_Pay_doc(p_ap => c.at_ap), get_at_rnp(p_At_Id)), '____________________________________')); --Api$act_Rpt.Get_At_Reject_List(p_At_Id)
        Addparam (
            'p8',
            COALESCE (
                get_reason_not_pay_name (
                    api$act_rpt.Atdocatrstr (p_At_Id, 3115)),
                '____________________________________'));

        --керівник
        AddParam ('p9_1', Api$act_Rpt.AtDocAtrStr (p_At_Id, 3116));
        l_str := Api$act_Rpt.At_Doc_Atr_Lst (p_At_Id, '3117,3118'); --Get_At_Signers(p_At_Id, 1)
        AddParam ('p9_2', l_str);
        AddParam ('p10', TO_CHAR (SYSDATE, 'dd.mm.yyyy') || ' року');

        ------------------------------------
        Rdm$rtfl_Univ.Get_Report_Result (p_Jbr_Id     => l_Jbr_Id,
                                         p_Rpt_Blob   => l_Result);
        Replace_Ekr (l_Result);

        RETURN l_Result;
    END Act_Doc_862_R1;

    --#92201 «Повідомлення-попередження про припинення надання соціальних послуг»
    FUNCTION Act_Doc_863_R1 (p_At_Id IN NUMBER)
        RETURN BLOB
    IS
        CURSOR c_Act IS
            SELECT a.At_Rnspm,
                   a.At_Live_Address,
                   a.At_Sc,
                   a.At_Action_Stop_Dt,
                   a.At_Notes,
                   A1.At_Dt      Dt7,
                   A1.At_Num     Num8,
                   Rnp.Rnp_Name,
                   p.atp_id
              FROM Act                           a,
                   Act                           A1,
                   Uss_Ndi.v_Ndi_Reason_Not_Pay  Rnp,
                   at_person                     p
             WHERE     a.At_Id = p_At_Id
                   AND A1.At_Id = a.At_Main_Link
                   AND p.atp_sc(+) = a.at_sc
                   AND p.atp_at(+) = a.at_id
                   AND Rnp.Rnp_Id(+) = a.At_Rnp;

        c            c_Act%ROWTYPE;

        l_Prs_z      Api$act_Rpt.r_Person_For_Act;                 --замовник;
        l_Prs_o      Api$act_Rpt.r_Person_For_Act;                 --отримувач

        l_Boss_Pib   VARCHAR2 (100);

        l_Jbr_Id     NUMBER;
        l_Result     BLOB;
    BEGIN
        Rdm$rtfl_Univ.Initreport (p_Code     => 'ACT_DOC_863_R1',
                                  p_Bld_Tp   => Rdm$rtfl_Univ.c_Bld_Tp_Db);

        ------------------------------------
        OPEN c_Act;

        FETCH c_Act INTO c;

        CLOSE c_Act;

        l_Prs_z := Get_Atperson (p_At_Id, c.atp_id /*Get_Atperson_Id(p_At_Id, 'Z')*/
                                                  );
        l_Prs_o := Get_Atperson (p_At_Id, Get_Atperson_Id (p_At_Id, 'OS'));

        AddParam ('p1', l_Prs_z.Pib);
        AddParam ('p2', c.At_Live_Address /*Nvl(l_Prs_z.Live_Address, c.At_Live_Address)*/
                                         );
        AddParam ('p3', l_Prs_z.Phone);
        AddParam ('p4', l_Prs_z.Email);
        AddParam ('p5', Api$act_Rpt.Get_Nsp_Name (p_Rnspm_Id => c.At_Rnspm)); --надавач соц.послуг
        AddParam ('p6', l_Prs_z.Pib);
        --AddParam('p6', api$act_rpt.AtDocAtrStr(p_At_Id, 3111) || ' ' || api$act_rpt.AtDocAtrStr(p_At_Id, 3112) || ' ' || api$act_rpt.AtDocAtrStr(p_At_Id, 3113)/*l_Prs_o.Pib*/); --отримувач
        AddParam ('p7', TO_CHAR (c.Dt7, 'dd.mm.yyyy'));
        AddParam ('p8', c.Num8);
        AddParam ('p9', c.Rnp_Name);
        AddParam ('p10', c.At_Action_Stop_Dt);
        --керівник
        AddParam ('p11-1', Api$act_Rpt.Atdocatrstr (p_At_Id, 8314));
        --l_Boss_pib:= get_signers_wucu_pib(p_at_id => p_at_id, p_ati_tp => 'PR', p_ati_cuwu => 2, p_ndt => 863);
        l_Boss_Pib := Api$act_Rpt.At_Doc_Atr_Lst (p_At_Id, '8315');
        AddParam ('p11-2', l_Boss_Pib);
        AddParam ('p12', TO_CHAR (SYSDATE, 'dd.mm.yyyy') || ' року');

        ------------------------------------
        Rdm$rtfl_Univ.Get_Report_Result (p_Jbr_Id     => l_Jbr_Id,
                                         p_Rpt_Blob   => l_Result);
        Replace_Ekr (l_Result);

        RETURN l_Result;
    END Act_Doc_863_R1;

    --#94117 АНКЕТА первинного оцінювання    для послуги 005.0
    FUNCTION ACT_DOC_866_R1 (p_at_id IN NUMBER)
        RETURN BLOB
    IS
        CURSOR c_at IS
            SELECT a.at_dt,
                   a.at_sc,
                   a.at_wu,
                   a.at_cu
              FROM act a
             WHERE a.at_id = p_at_id;

        c          c_at%ROWTYPE;

        lO         NUMBER;                                         --отримувач
        p          Api$Act_Rpt.R_Person_for_act;


        l_jbr_id   NUMBER;
        l_result   BLOB;
        l_str      VARCHAR (250);
    BEGIN
        rdm$rtfl_univ.initreport (p_code     => 'ACT_DOC_866_R1',
                                  p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);

        ------------------------------------
        OPEN c_at;

        FETCH c_at INTO c;

        CLOSE c_at;

        lO := Api$Act_Rpt.get_AtPersonSc_id (p_at_id, c.at_sc);
        p := get_AtPerson (p_at_id, lO);

        addparam ('p1', p.LN);
        addparam ('p2', p.fn);
        addparam ('p3', p.mn);
        addparam ('p4', Get_Ftr_Nt (p_at_id, p_nda => 1590));
        addparam ('p5', p.birth_dt_str);
        addparam ('p6', Get_Ftr_Nt (p_at_id, p_nda => 1597));

        addparam ('p7', p.fact_address);            --Останнє місце проживання
        addparam ('p8', p.live_address);          --Останнє місце (реєстрації)
        addparam ('p9', Api$Act_Rpt.Gender (p.sex));
        addparam ('p10', p.atp_citizenship);
        addparam ('p11', Get_Ftr_Nt (p_at_id, p_nda => 1598));

        l_str := Get_Ftr (p_at_id, p_nda => 1603);

        SELECT MAX (t.DIC_NAME)
          INTO l_str
          FROM uss_ndi.V_DDN_LVL_EDCT t
         WHERE t.DIC_VALUE = l_str;

        addparam (
            'p12',
               l_str
            || CASE
                   WHEN     l_str IS NOT NULL
                        AND Get_Ftr_Nt (p_at_id, p_nda => 1603) IS NOT NULL
                   THEN
                       ', '
                   ELSE
                       ' '
               END
            || Get_Ftr_Nt (p_at_id, p_nda => 1603));
        addparam ('p13', Get_Ftr_Nt (p_at_id, p_nda => 1604));
        addparam ('p14', p.work_place);
        addparam ('p15', Get_Ftr_Nt (p_at_id, p_nda => 1609));
        addparam ('p16', Get_Ftr_Nt (p_at_id, p_nda => 1610));
        addparam ('p17', Get_Ftr_Nt (p_at_id, p_nda => 1616));
        addparam ('p18', Get_Ftr_Nt (p_at_id, p_nda => 1617));
        addparam ('p19', Get_Ftr_Nt (p_at_id, p_nda => 1623));
        addparam ('p20', Get_Ftr_Nt (p_at_id, p_nda => 1624));
        addparam ('p21', NULL); --Якого виду допомоги потребує:  не заповнюється
        addparam ('p22', api$act_rpt.Get_Ftr_Chk (p_at_id, p_nda => 1630));
        addparam ('p23', api$act_rpt.Get_Ftr_Chk (p_at_id, p_nda => 1631));
        addparam ('p24', api$act_rpt.Get_Ftr_Chk (p_at_id, p_nda => 1638));
        addparam ('p25', api$act_rpt.Get_Ftr_Chk (p_at_id, p_nda => 1639));
        addparam ('p26', api$act_rpt.Get_Ftr_Chk (p_at_id, p_nda => 1646));
        addparam ('p27', api$act_rpt.Get_Ftr_Chk (p_at_id, p_nda => 1647));
        addparam ('p28', Get_Ftr_Nt (p_at_id, p_nda => 1652));
        addparam ('p29', api$act_rpt.Get_Ftr_Chk (p_at_id, p_nda => 1653));
        addparam ('p30', Get_Ftr_Nt (p_at_id, p_nda => 1657));
        addparam ('p31', Get_Ftr_Nt (p_at_id, p_nda => 1658));
        addparam ('p32', Get_Ftr_Nt (p_at_id, p_nda => 1662));


        AddParam ('sng1',
                  Underline (Api$act.Get_At_Spec_Name (c.at_wu, c.at_cu), 1)); --Працівник, який заповнював анкету
        AddParam ('sng2', NVL (Api$Act_Rpt.Date2Str (c.at_dt), c_date_empty));
        AddParam ('sng3', Underline (p.pib, 1));                   --отримувач
        AddParam ('sng4', NVL (Api$Act_Rpt.Date2Str (c.at_dt), c_date_empty));
        AddParam (
            'sgn_mark',
            api$act_rpt.get_sign_mark (p_at_id, p.Atp_Id, '_____________'));


        ------------------------------------
        rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                         p_rpt_blob   => l_result);
        replace_ekr (l_result);

        RETURN l_result;
    END;

    --#94118 009.1-872-Комплексне визначення ступеня індивідуальних потреб СП підтриманого проживання
    FUNCTION ACT_DOC_872_R1 (p_at_id IN NUMBER)
        RETURN BLOB
    IS
        CURSOR c_at IS
            SELECT a.at_dt,
                   a.at_sc,
                   a.At_rnspm,
                   a.at_wu,
                   a.at_cu,
                   a.at_ap
              FROM act a
             WHERE a.at_id = p_at_id;

        c          c_at%ROWTYPE;

        l_str      VARCHAR2 (32000);

        l_jbr_id   NUMBER;
        l_result   BLOB;
    BEGIN
        rdm$rtfl_univ.initreport (p_code     => 'ACT_DOC_872_R1',
                                  p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);

        ------------------------------------
        OPEN c_at;

        FETCH c_at INTO c;

        CLOSE c_at;


        --Таблиця 2 Шкала оцінювання можливості виконання елементарних дій
        AddParam ('t2.1.1', Get_Ftr_Ind (p_at_id, p_nda => 5858)); --1 Прийом їжі
        AddParam ('t2.1.2', Get_Ftr_Ind (p_at_id, p_nda => 5859));
        AddParam ('t2.1.3', Get_Ftr_Ind (p_at_id, p_nda => 5860));
        AddParam ('t2.1.4', Get_Ftr_Ind (p_at_id, p_nda => 5861));
        AddParam ('t2.1.5', Get_Ftr_Ind (p_at_id, p_nda => 5862));
        AddParam ('t2.1.6', Get_Ftr_Ind (p_at_id, p_nda => 5863));
        AddParam ('t2.1.7', Get_Ftr_Ind (p_at_id, p_nda => 5864));
        AddParam ('t2.1.8', Get_Ftr_Ind (p_at_id, p_nda => 5865));
        AddParam ('t2.1.9', Get_Ftr_Ind (p_at_id, p_nda => 5866));
        AddParam ('t2.2.1', Get_Ftr_Ind (p_at_id, p_nda => 5867)); --2 Купання
        AddParam ('t2.2.2', Get_Ftr_Ind (p_at_id, p_nda => 5868));
        AddParam ('t2.2.3', Get_Ftr_Ind (p_at_id, p_nda => 5869));
        AddParam ('t2.2.4', Get_Ftr_Ind (p_at_id, p_nda => 5870));
        AddParam ('t2.2.5', Get_Ftr_Ind (p_at_id, p_nda => 5871));
        AddParam ('t2.2.6', Get_Ftr_Ind (p_at_id, p_nda => 5872));
        AddParam ('t2.3.1', Get_Ftr_Ind (p_at_id, p_nda => 5873)); --3 Особистий туалет
        AddParam ('t2.3.2', Get_Ftr_Ind (p_at_id, p_nda => 5874));
        AddParam ('t2.3.3', Get_Ftr_Ind (p_at_id, p_nda => 5875));
        AddParam ('t2.3.4', Get_Ftr_Ind (p_at_id, p_nda => 5876));
        AddParam ('t2.3.5', Get_Ftr_Ind (p_at_id, p_nda => 5877));
        AddParam ('t2.3.6', Get_Ftr_Ind (p_at_id, p_nda => 5878));
        AddParam ('t2.4.1', Get_Ftr_Ind (p_at_id, p_nda => 5879)); --4 Одягання і взування
        AddParam ('t2.4.2', Get_Ftr_Ind (p_at_id, p_nda => 5880));
        AddParam ('t2.4.3', Get_Ftr_Ind (p_at_id, p_nda => 5881));
        AddParam ('t2.4.4', Get_Ftr_Ind (p_at_id, p_nda => 5882));
        AddParam ('t2.4.5', Get_Ftr_Ind (p_at_id, p_nda => 5883));
        AddParam ('t2.4.6', Get_Ftr_Ind (p_at_id, p_nda => 5884));
        AddParam ('t2.4.7', Get_Ftr_Ind (p_at_id, p_nda => 5885));
        AddParam ('t2.4.8', Get_Ftr_Ind (p_at_id, p_nda => 5886));
        AddParam ('t2.5.1', Get_Ftr_Ind (p_at_id, p_nda => 5887)); --5 Контроль дефекації
        AddParam ('t2.5.2', Get_Ftr_Ind (p_at_id, p_nda => 5888));
        AddParam ('t2.5.3', Get_Ftr_Ind (p_at_id, p_nda => 5889));
        AddParam ('t2.5.4', Get_Ftr_Ind (p_at_id, p_nda => 5890));
        AddParam ('t2.5.5', Get_Ftr_Ind (p_at_id, p_nda => 5891));
        AddParam ('t2.5.6', Get_Ftr_Ind (p_at_id, p_nda => 5892));
        AddParam ('t2.6.1', Get_Ftr_Ind (p_at_id, p_nda => 5893)); --6 Контроль сечовиділення
        AddParam ('t2.6.2', Get_Ftr_Ind (p_at_id, p_nda => 5894));
        AddParam ('t2.6.3', Get_Ftr_Ind (p_at_id, p_nda => 5895));
        AddParam ('t2.6.4', Get_Ftr_Ind (p_at_id, p_nda => 5896));
        AddParam ('t2.6.5', Get_Ftr_Ind (p_at_id, p_nda => 5897));
        AddParam ('t2.6.6', Get_Ftr_Ind (p_at_id, p_nda => 5898));
        AddParam ('t2.7.1', Get_Ftr_Ind (p_at_id, p_nda => 5899)); --7 Відвідування і здійснення туалету
        AddParam ('t2.7.2', Get_Ftr_Ind (p_at_id, p_nda => 5900));
        AddParam ('t2.7.3', Get_Ftr_Ind (p_at_id, p_nda => 5901));
        AddParam ('t2.7.4', Get_Ftr_Ind (p_at_id, p_nda => 5902));
        AddParam ('t2.7.5', Get_Ftr_Ind (p_at_id, p_nda => 5903));
        AddParam ('t2.7.6', Get_Ftr_Ind (p_at_id, p_nda => 5904));
        AddParam ('t2.7.7', Get_Ftr_Ind (p_at_id, p_nda => 5905));
        AddParam ('t2.8.1', Get_Ftr_Ind (p_at_id, p_nda => 5906)); --8 Вставання й перехід з ліжка
        AddParam ('t2.8.2', Get_Ftr_Ind (p_at_id, p_nda => 5907));
        AddParam ('t2.8.3', Get_Ftr_Ind (p_at_id, p_nda => 5908));
        AddParam ('t2.8.4', Get_Ftr_Ind (p_at_id, p_nda => 5909));
        AddParam ('t2.8.5', Get_Ftr_Ind (p_at_id, p_nda => 5910));
        AddParam ('t2.8.6', Get_Ftr_Ind (p_at_id, p_nda => 5911));
        AddParam ('t2.8.7', Get_Ftr_Ind (p_at_id, p_nda => 5912));
        AddParam ('t2.8.8', Get_Ftr_Ind (p_at_id, p_nda => 5913));
        AddParam ('t2.9.1', Get_Ftr_Ind (p_at_id, p_nda => 5914)); --9 Пересування
        AddParam ('t2.9.2', Get_Ftr_Ind (p_at_id, p_nda => 5915));
        AddParam ('t2.9.3', Get_Ftr_Ind (p_at_id, p_nda => 5916));
        AddParam ('t2.9.4', Get_Ftr_Ind (p_at_id, p_nda => 5917));
        AddParam ('t2.9.5', Get_Ftr_Ind (p_at_id, p_nda => 5918));
        AddParam ('t2.9.6', Get_Ftr_Ind (p_at_id, p_nda => 5919));
        AddParam ('t2.9.7', Get_Ftr_Ind (p_at_id, p_nda => 5920));
        AddParam ('t2.9.8', Get_Ftr_Ind (p_at_id, p_nda => 5921));
        AddParam ('t2.10.1', Get_Ftr_Ind (p_at_id, p_nda => 5922)); --10 Підіймання сходами
        AddParam ('t2.10.2', Get_Ftr_Ind (p_at_id, p_nda => 5923));
        AddParam ('t2.10.3', Get_Ftr_Ind (p_at_id, p_nda => 5924));
        AddParam ('t2.10.4', Get_Ftr_Ind (p_at_id, p_nda => 5925));
        AddParam ('t2.10.5', Get_Ftr_Ind (p_at_id, p_nda => 5926));
        AddParam ('t2.10.6', Get_Ftr_Ind (p_at_id, p_nda => 5927));
        --Сума балів
        AddParam (
            't2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 541).ate_indicator_value1);

        --Таблиця 3 Шкала оцінювання можливості виконання складних дій
        AddParam ('t3.1.1', Get_Ftr_Ind (p_at_id, p_nda => 5928));         --1
        AddParam ('t3.1.2', Get_Ftr_Ind (p_at_id, p_nda => 5929));
        AddParam ('t3.1.3', Get_Ftr_Ind (p_at_id, p_nda => 5930));
        AddParam ('t3.1.4', Get_Ftr_Ind (p_at_id, p_nda => 5931));
        AddParam ('t3.1.5', Get_Ftr_Ind (p_at_id, p_nda => 5932));
        AddParam ('t3.2.1', Get_Ftr_Ind (p_at_id, p_nda => 5933));         --2
        AddParam ('t3.2.2', Get_Ftr_Ind (p_at_id, p_nda => 5934));
        AddParam ('t3.2.3', Get_Ftr_Ind (p_at_id, p_nda => 5935));
        AddParam ('t3.2.4', Get_Ftr_Ind (p_at_id, p_nda => 5936));
        AddParam ('t3.2.5', Get_Ftr_Ind (p_at_id, p_nda => 5937));
        AddParam ('t3.3.1', Get_Ftr_Ind (p_at_id, p_nda => 5938));         --3
        AddParam ('t3.3.2', Get_Ftr_Ind (p_at_id, p_nda => 5939));
        AddParam ('t3.3.3', Get_Ftr_Ind (p_at_id, p_nda => 5940));
        AddParam ('t3.3.4', Get_Ftr_Ind (p_at_id, p_nda => 5941));
        AddParam ('t3.4.1', Get_Ftr_Ind (p_at_id, p_nda => 5942));         --4
        AddParam ('t3.4.2', Get_Ftr_Ind (p_at_id, p_nda => 5943));
        AddParam ('t3.4.3', Get_Ftr_Ind (p_at_id, p_nda => 5944));
        AddParam ('t3.4.4', Get_Ftr_Ind (p_at_id, p_nda => 5945));
        AddParam ('t3.4.5', Get_Ftr_Ind (p_at_id, p_nda => 5946));
        AddParam ('t3.5.1', Get_Ftr_Ind (p_at_id, p_nda => 5947));         --5
        AddParam ('t3.5.2', Get_Ftr_Ind (p_at_id, p_nda => 5948));
        AddParam ('t3.5.3', Get_Ftr_Ind (p_at_id, p_nda => 5949));
        AddParam ('t3.5.4', Get_Ftr_Ind (p_at_id, p_nda => 5950));
        AddParam ('t3.5.5', Get_Ftr_Ind (p_at_id, p_nda => 5951));
        AddParam ('t3.6.1', Get_Ftr_Ind (p_at_id, p_nda => 5952));         --6
        AddParam ('t3.6.2', Get_Ftr_Ind (p_at_id, p_nda => 5953));
        AddParam ('t3.6.3', Get_Ftr_Ind (p_at_id, p_nda => 5954));
        AddParam ('t3.6.4', Get_Ftr_Ind (p_at_id, p_nda => 5955));
        AddParam ('t3.7.1', Get_Ftr_Ind (p_at_id, p_nda => 5956));         --7
        AddParam ('t3.7.2', Get_Ftr_Ind (p_at_id, p_nda => 5957));
        AddParam ('t3.7.3', Get_Ftr_Ind (p_at_id, p_nda => 5958));
        AddParam ('t3.7.4', Get_Ftr_Ind (p_at_id, p_nda => 5959));
        AddParam ('t3.7.5', Get_Ftr_Ind (p_at_id, p_nda => 5960));
        AddParam ('t3.8.1', Get_Ftr_Ind (p_at_id, p_nda => 5961));         --8
        AddParam ('t3.8.2', Get_Ftr_Ind (p_at_id, p_nda => 5962));
        AddParam ('t3.8.3', Get_Ftr_Ind (p_at_id, p_nda => 5963));
        AddParam ('t3.8.4', Get_Ftr_Ind (p_at_id, p_nda => 5964));
        AddParam ('t3.9.1', Get_Ftr_Ind (p_at_id, p_nda => 5965));         --9
        AddParam ('t3.9.2', Get_Ftr_Ind (p_at_id, p_nda => 5966));
        AddParam ('t3.9.3', Get_Ftr_Ind (p_at_id, p_nda => 5967));
        AddParam ('t3.9.4', Get_Ftr_Ind (p_at_id, p_nda => 5968));
        --Сума балів
        AddParam (
            't3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 541).ate_indicator_value2);

        --Таблиця 4 Шкала оцінювання навичок проживання за основними категоріями
        --1 Управління фінансами
        AddParam ('t4.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5969));
        AddParam ('t4.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5970));
        AddParam ('t4.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5971));
        AddParam ('t4.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5972));
        AddParam ('t4.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5973));
        AddParam ('t4.6', Get_Ftr_Chk2 (p_at_id, p_nda => 5974));
        AddParam ('t4.7', Get_Ftr_Chk2 (p_at_id, p_nda => 5975));
        AddParam ('t4.8', Get_Ftr_Chk2 (p_at_id, p_nda => 5976));
        AddParam ('t4.9', Get_Ftr_Chk2 (p_at_id, p_nda => 5977));
        AddParam ('t4.10', Get_Ftr_Chk2 (p_at_id, p_nda => 5978));
        AddParam ('t4.11', Get_Ftr_Chk2 (p_at_id, p_nda => 5979));
        AddParam ('t4.12', Get_Ftr_Chk2 (p_at_id, p_nda => 5980));
        AddParam ('t4.13', Get_Ftr_Chk2 (p_at_id, p_nda => 5981));
        AddParam ('t4.14', Get_Ftr_Chk2 (p_at_id, p_nda => 5982));
        AddParam ('t4.15', Get_Ftr_Chk2 (p_at_id, p_nda => 5983));
        AddParam ('t4.16', Get_Ftr_Chk2 (p_at_id, p_nda => 5984));
        AddParam ('t4.17', Get_Ftr_Chk2 (p_at_id, p_nda => 5985));
        AddParam ('t4.18', Get_Ftr_Chk2 (p_at_id, p_nda => 5986));
        AddParam ('t4.19', Get_Ftr_Chk2 (p_at_id, p_nda => 5987));
        AddParam ('t4.20', Get_Ftr_Chk2 (p_at_id, p_nda => 5988));
        AddParam ('t4.21', Get_Ftr_Chk2 (p_at_id, p_nda => 5989));
        AddParam ('t4.22', Get_Ftr_Chk2 (p_at_id, p_nda => 5990));
        AddParam ('t4.23', Get_Ftr_Chk2 (p_at_id, p_nda => 5991));
        AddParam ('t4.24', Get_Ftr_Chk2 (p_at_id, p_nda => 5992));
        AddParam ('t4.25', Get_Ftr_Chk2 (p_at_id, p_nda => 5993));
        --Організація харчування
        AddParam ('t4.26', Get_Ftr_Chk2 (p_at_id, p_nda => 5994));
        AddParam ('t4.27', Get_Ftr_Chk2 (p_at_id, p_nda => 5995));
        AddParam ('t4.28', Get_Ftr_Chk2 (p_at_id, p_nda => 5996));
        AddParam ('t4.29', Get_Ftr_Chk2 (p_at_id, p_nda => 5997));
        AddParam ('t4.30', Get_Ftr_Chk2 (p_at_id, p_nda => 5998));
        AddParam ('t4.31', Get_Ftr_Chk2 (p_at_id, p_nda => 5999));
        AddParam ('t4.32', Get_Ftr_Chk2 (p_at_id, p_nda => 6000));
        AddParam ('t4.33', Get_Ftr_Chk2 (p_at_id, p_nda => 6001));
        AddParam ('t4.34', Get_Ftr_Chk2 (p_at_id, p_nda => 6002));
        AddParam ('t4.35', Get_Ftr_Chk2 (p_at_id, p_nda => 6003));
        AddParam ('t4.36', Get_Ftr_Chk2 (p_at_id, p_nda => 6004));
        AddParam ('t4.37', Get_Ftr_Chk2 (p_at_id, p_nda => 6005));
        AddParam ('t4.38', Get_Ftr_Chk2 (p_at_id, p_nda => 6006));
        AddParam ('t4.39', Get_Ftr_Chk2 (p_at_id, p_nda => 6007));
        AddParam ('t4.40', Get_Ftr_Chk2 (p_at_id, p_nda => 6008));
        AddParam ('t4.41', Get_Ftr_Chk2 (p_at_id, p_nda => 6009));
        AddParam ('t4.42', Get_Ftr_Chk2 (p_at_id, p_nda => 6010));
        AddParam ('t4.43', Get_Ftr_Chk2 (p_at_id, p_nda => 6011));
        AddParam ('t4.44', Get_Ftr_Chk2 (p_at_id, p_nda => 6012));
        AddParam ('t4.45', Get_Ftr_Chk2 (p_at_id, p_nda => 6013));
        AddParam ('t4.46', Get_Ftr_Chk2 (p_at_id, p_nda => 6014));
        AddParam ('t4.47', Get_Ftr_Chk2 (p_at_id, p_nda => 6015));
        AddParam ('t4.48', Get_Ftr_Chk2 (p_at_id, p_nda => 6016));
        AddParam ('t4.49', Get_Ftr_Chk2 (p_at_id, p_nda => 6017));
        AddParam ('t4.50', Get_Ftr_Chk2 (p_at_id, p_nda => 6018));
        --Зовнішній вигляд, дотримання правил особистої гігієни
        AddParam ('t4.51', Get_Ftr_Chk2 (p_at_id, p_nda => 6019));
        AddParam ('t4.52', Get_Ftr_Chk2 (p_at_id, p_nda => 6020));
        AddParam ('t4.53', Get_Ftr_Chk2 (p_at_id, p_nda => 6021));
        AddParam ('t4.54', Get_Ftr_Chk2 (p_at_id, p_nda => 6022));
        AddParam ('t4.55', Get_Ftr_Chk2 (p_at_id, p_nda => 6023));
        AddParam ('t4.56', Get_Ftr_Chk2 (p_at_id, p_nda => 6024));
        AddParam ('t4.57', Get_Ftr_Chk2 (p_at_id, p_nda => 6025));
        AddParam ('t4.58', Get_Ftr_Chk2 (p_at_id, p_nda => 6026));
        AddParam ('t4.59', Get_Ftr_Chk2 (p_at_id, p_nda => 6027));
        AddParam ('t4.60', Get_Ftr_Chk2 (p_at_id, p_nda => 6028));
        AddParam ('t4.61', Get_Ftr_Chk2 (p_at_id, p_nda => 6029));
        AddParam ('t4.62', Get_Ftr_Chk2 (p_at_id, p_nda => 6030));
        AddParam ('t4.63', Get_Ftr_Chk2 (p_at_id, p_nda => 6031));
        AddParam ('t4.64', Get_Ftr_Chk2 (p_at_id, p_nda => 6032));
        AddParam ('t4.65', Get_Ftr_Chk2 (p_at_id, p_nda => 6033));
        AddParam ('t4.66', Get_Ftr_Chk2 (p_at_id, p_nda => 6034));
        AddParam ('t4.67', Get_Ftr_Chk2 (p_at_id, p_nda => 6035));
        AddParam ('t4.68', Get_Ftr_Chk2 (p_at_id, p_nda => 6036));
        AddParam ('t4.69', Get_Ftr_Chk2 (p_at_id, p_nda => 6037));
        AddParam ('t4.70', Get_Ftr_Chk2 (p_at_id, p_nda => 6038));
        AddParam ('t4.71', Get_Ftr_Chk2 (p_at_id, p_nda => 6039));
        AddParam ('t4.72', Get_Ftr_Chk2 (p_at_id, p_nda => 6040));
        AddParam ('t4.73', Get_Ftr_Chk2 (p_at_id, p_nda => 6041));
        AddParam ('t4.74', Get_Ftr_Chk2 (p_at_id, p_nda => 6042));
        AddParam ('t4.75', Get_Ftr_Chk2 (p_at_id, p_nda => 6043));
        --Здоров’я
        AddParam ('t4.76', Get_Ftr_Chk2 (p_at_id, p_nda => 6044));
        AddParam ('t4.77', Get_Ftr_Chk2 (p_at_id, p_nda => 6045));
        AddParam ('t4.78', Get_Ftr_Chk2 (p_at_id, p_nda => 6046));
        AddParam ('t4.79', Get_Ftr_Chk2 (p_at_id, p_nda => 6047));
        AddParam ('t4.80', Get_Ftr_Chk2 (p_at_id, p_nda => 6048));
        AddParam ('t4.81', Get_Ftr_Chk2 (p_at_id, p_nda => 6049));
        AddParam ('t4.82', Get_Ftr_Chk2 (p_at_id, p_nda => 6050));
        AddParam ('t4.83', Get_Ftr_Chk2 (p_at_id, p_nda => 6051));
        AddParam ('t4.84', Get_Ftr_Chk2 (p_at_id, p_nda => 6052));
        AddParam ('t4.85', Get_Ftr_Chk2 (p_at_id, p_nda => 6053));
        AddParam ('t4.86', Get_Ftr_Chk2 (p_at_id, p_nda => 6054));
        AddParam ('t4.87', Get_Ftr_Chk2 (p_at_id, p_nda => 6055));
        AddParam ('t4.88', Get_Ftr_Chk2 (p_at_id, p_nda => 6056));
        AddParam ('t4.89', Get_Ftr_Chk2 (p_at_id, p_nda => 6057));
        AddParam ('t4.90', Get_Ftr_Chk2 (p_at_id, p_nda => 6058));
        AddParam ('t4.91', Get_Ftr_Chk2 (p_at_id, p_nda => 6059));
        AddParam ('t4.92', Get_Ftr_Chk2 (p_at_id, p_nda => 6060));
        AddParam ('t4.93', Get_Ftr_Chk2 (p_at_id, p_nda => 6061));
        AddParam ('t4.94', Get_Ftr_Chk2 (p_at_id, p_nda => 6062));
        AddParam ('t4.95', Get_Ftr_Chk2 (p_at_id, p_nda => 6063));
        AddParam ('t4.96', Get_Ftr_Chk2 (p_at_id, p_nda => 6064));
        AddParam ('t4.97', Get_Ftr_Chk2 (p_at_id, p_nda => 6065));
        AddParam ('t4.98', Get_Ftr_Chk2 (p_at_id, p_nda => 6066));
        AddParam ('t4.99', Get_Ftr_Chk2 (p_at_id, p_nda => 6067));
        AddParam ('t4.100', Get_Ftr_Chk2 (p_at_id, p_nda => 6068));
        --Утримання помешкання
        AddParam ('t4.101', Get_Ftr_Chk2 (p_at_id, p_nda => 6069));
        AddParam ('t4.102', Get_Ftr_Chk2 (p_at_id, p_nda => 6070));
        AddParam ('t4.103', Get_Ftr_Chk2 (p_at_id, p_nda => 6071));
        AddParam ('t4.104', Get_Ftr_Chk2 (p_at_id, p_nda => 6072));
        AddParam ('t4.105', Get_Ftr_Chk2 (p_at_id, p_nda => 6073));
        AddParam ('t4.106', Get_Ftr_Chk2 (p_at_id, p_nda => 6074));
        AddParam ('t4.107', Get_Ftr_Chk2 (p_at_id, p_nda => 6075));
        AddParam ('t4.108', Get_Ftr_Chk2 (p_at_id, p_nda => 6076));
        AddParam ('t4.109', Get_Ftr_Chk2 (p_at_id, p_nda => 6077));
        AddParam ('t4.110', Get_Ftr_Chk2 (p_at_id, p_nda => 6078));
        AddParam ('t4.111', Get_Ftr_Chk2 (p_at_id, p_nda => 6079));
        AddParam ('t4.112', Get_Ftr_Chk2 (p_at_id, p_nda => 6080));
        AddParam ('t4.113', Get_Ftr_Chk2 (p_at_id, p_nda => 6081));
        AddParam ('t4.114', Get_Ftr_Chk2 (p_at_id, p_nda => 6082));
        AddParam ('t4.115', Get_Ftr_Chk2 (p_at_id, p_nda => 6083));
        AddParam ('t4.116', Get_Ftr_Chk2 (p_at_id, p_nda => 6084));
        AddParam ('t4.117', Get_Ftr_Chk2 (p_at_id, p_nda => 6085));
        AddParam ('t4.118', Get_Ftr_Chk2 (p_at_id, p_nda => 6086));
        AddParam ('t4.119', Get_Ftr_Chk2 (p_at_id, p_nda => 6087));
        AddParam ('t4.120', Get_Ftr_Chk2 (p_at_id, p_nda => 6088));
        AddParam ('t4.121', Get_Ftr_Chk2 (p_at_id, p_nda => 6089));
        AddParam ('t4.122', Get_Ftr_Chk2 (p_at_id, p_nda => 6090));
        AddParam ('t4.123', Get_Ftr_Chk2 (p_at_id, p_nda => 6091));
        AddParam ('t4.124', Get_Ftr_Chk2 (p_at_id, p_nda => 6092));
        AddParam ('t4.125', Get_Ftr_Chk2 (p_at_id, p_nda => 6093));
        --Обізнаність у сфері нерухомості
        AddParam ('t4.126', Get_Ftr_Chk2 (p_at_id, p_nda => 6094));
        AddParam ('t4.127', Get_Ftr_Chk2 (p_at_id, p_nda => 6095));
        AddParam ('t4.128', Get_Ftr_Chk2 (p_at_id, p_nda => 6096));
        AddParam ('t4.129', Get_Ftr_Chk2 (p_at_id, p_nda => 6097));
        AddParam ('t4.130', Get_Ftr_Chk2 (p_at_id, p_nda => 6098));
        AddParam ('t4.131', Get_Ftr_Chk2 (p_at_id, p_nda => 6099));
        AddParam ('t4.132', Get_Ftr_Chk2 (p_at_id, p_nda => 6100));
        AddParam ('t4.133', Get_Ftr_Chk2 (p_at_id, p_nda => 6101));
        AddParam ('t4.134', Get_Ftr_Chk2 (p_at_id, p_nda => 6102));
        AddParam ('t4.135', Get_Ftr_Chk2 (p_at_id, p_nda => 6103));
        AddParam ('t4.136', Get_Ftr_Chk2 (p_at_id, p_nda => 6104));
        AddParam ('t4.137', Get_Ftr_Chk2 (p_at_id, p_nda => 6105));
        AddParam ('t4.138', Get_Ftr_Chk2 (p_at_id, p_nda => 6106));
        AddParam ('t4.139', Get_Ftr_Chk2 (p_at_id, p_nda => 6107));
        AddParam ('t4.140', Get_Ftr_Chk2 (p_at_id, p_nda => 6108));
        AddParam ('t4.141', Get_Ftr_Chk2 (p_at_id, p_nda => 6109));
        AddParam ('t4.142', Get_Ftr_Chk2 (p_at_id, p_nda => 6110));
        AddParam ('t4.143', Get_Ftr_Chk2 (p_at_id, p_nda => 6111));
        AddParam ('t4.144', Get_Ftr_Chk2 (p_at_id, p_nda => 6112));
        AddParam ('t4.145', Get_Ftr_Chk2 (p_at_id, p_nda => 6113));
        AddParam ('t4.146', Get_Ftr_Chk2 (p_at_id, p_nda => 6114));
        AddParam ('t4.147', Get_Ftr_Chk2 (p_at_id, p_nda => 6115));
        AddParam ('t4.148', Get_Ftr_Chk2 (p_at_id, p_nda => 6116));
        AddParam ('t4.149', Get_Ftr_Chk2 (p_at_id, p_nda => 6117));
        AddParam ('t4.150', Get_Ftr_Chk2 (p_at_id, p_nda => 6118));
        --Користування транспортом
        AddParam ('t4.151', Get_Ftr_Chk2 (p_at_id, p_nda => 6119));
        AddParam ('t4.152', Get_Ftr_Chk2 (p_at_id, p_nda => 6120));
        AddParam ('t4.153', Get_Ftr_Chk2 (p_at_id, p_nda => 6121));
        AddParam ('t4.154', Get_Ftr_Chk2 (p_at_id, p_nda => 6122));
        AddParam ('t4.155', Get_Ftr_Chk2 (p_at_id, p_nda => 6123));
        AddParam ('t4.156', Get_Ftr_Chk2 (p_at_id, p_nda => 6124));
        AddParam ('t4.157', Get_Ftr_Chk2 (p_at_id, p_nda => 6125));
        AddParam ('t4.158', Get_Ftr_Chk2 (p_at_id, p_nda => 6126));
        AddParam ('t4.159', Get_Ftr_Chk2 (p_at_id, p_nda => 6127));
        AddParam ('t4.160', Get_Ftr_Chk2 (p_at_id, p_nda => 6128));
        AddParam ('t4.161', Get_Ftr_Chk2 (p_at_id, p_nda => 6129));
        AddParam ('t4.162', Get_Ftr_Chk2 (p_at_id, p_nda => 6130));
        AddParam ('t4.163', Get_Ftr_Chk2 (p_at_id, p_nda => 6131));
        AddParam ('t4.164', Get_Ftr_Chk2 (p_at_id, p_nda => 6132));
        AddParam ('t4.165', Get_Ftr_Chk2 (p_at_id, p_nda => 6133));
        AddParam ('t4.166', Get_Ftr_Chk2 (p_at_id, p_nda => 6134));
        AddParam ('t4.167', Get_Ftr_Chk2 (p_at_id, p_nda => 6135));
        AddParam ('t4.168', Get_Ftr_Chk2 (p_at_id, p_nda => 6136));
        AddParam ('t4.169', Get_Ftr_Chk2 (p_at_id, p_nda => 6137));
        AddParam ('t4.170', Get_Ftr_Chk2 (p_at_id, p_nda => 6138));
        AddParam ('t4.171', Get_Ftr_Chk2 (p_at_id, p_nda => 6139));
        AddParam ('t4.172', Get_Ftr_Chk2 (p_at_id, p_nda => 6140));
        AddParam ('t4.173', Get_Ftr_Chk2 (p_at_id, p_nda => 6141));
        AddParam ('t4.174', Get_Ftr_Chk2 (p_at_id, p_nda => 6142));
        AddParam ('t4.175', Get_Ftr_Chk2 (p_at_id, p_nda => 6143));
        --Організація навчального процесу
        AddParam ('t4.176', Get_Ftr_Chk2 (p_at_id, p_nda => 6144));
        AddParam ('t4.177', Get_Ftr_Chk2 (p_at_id, p_nda => 6145));
        AddParam ('t4.178', Get_Ftr_Chk2 (p_at_id, p_nda => 6146));
        AddParam ('t4.179', Get_Ftr_Chk2 (p_at_id, p_nda => 6147));
        AddParam ('t4.180', Get_Ftr_Chk2 (p_at_id, p_nda => 6148));
        AddParam ('t4.181', Get_Ftr_Chk2 (p_at_id, p_nda => 6149));
        AddParam ('t4.182', Get_Ftr_Chk2 (p_at_id, p_nda => 6150));
        AddParam ('t4.183', Get_Ftr_Chk2 (p_at_id, p_nda => 6151));
        AddParam ('t4.184', Get_Ftr_Chk2 (p_at_id, p_nda => 6152));
        AddParam ('t4.185', Get_Ftr_Chk2 (p_at_id, p_nda => 6153));
        AddParam ('t4.186', Get_Ftr_Chk2 (p_at_id, p_nda => 6154));
        AddParam ('t4.187', Get_Ftr_Chk2 (p_at_id, p_nda => 6155));
        AddParam ('t4.188', Get_Ftr_Chk2 (p_at_id, p_nda => 6156));
        AddParam ('t4.189', Get_Ftr_Chk2 (p_at_id, p_nda => 6157));
        AddParam ('t4.190', Get_Ftr_Chk2 (p_at_id, p_nda => 6158));
        AddParam ('t4.191', Get_Ftr_Chk2 (p_at_id, p_nda => 6159));
        AddParam ('t4.192', Get_Ftr_Chk2 (p_at_id, p_nda => 6160));
        AddParam ('t4.193', Get_Ftr_Chk2 (p_at_id, p_nda => 6161));
        AddParam ('t4.194', Get_Ftr_Chk2 (p_at_id, p_nda => 6162));
        AddParam ('t4.195', Get_Ftr_Chk2 (p_at_id, p_nda => 6163));
        AddParam ('t4.196', Get_Ftr_Chk2 (p_at_id, p_nda => 6164));
        AddParam ('t4.197', Get_Ftr_Chk2 (p_at_id, p_nda => 6165));
        AddParam ('t4.198', Get_Ftr_Chk2 (p_at_id, p_nda => 6166));
        AddParam ('t4.199', Get_Ftr_Chk2 (p_at_id, p_nda => 6167));
        AddParam ('t4.200', Get_Ftr_Chk2 (p_at_id, p_nda => 6168));
        --Навички пошуку роботи
        AddParam ('t4.201', Get_Ftr_Chk2 (p_at_id, p_nda => 6169));
        AddParam ('t4.202', Get_Ftr_Chk2 (p_at_id, p_nda => 6170));
        AddParam ('t4.203', Get_Ftr_Chk2 (p_at_id, p_nda => 6171));
        AddParam ('t4.204', Get_Ftr_Chk2 (p_at_id, p_nda => 6172));
        AddParam ('t4.205', Get_Ftr_Chk2 (p_at_id, p_nda => 6173));
        AddParam ('t4.206', Get_Ftr_Chk2 (p_at_id, p_nda => 6174));
        AddParam ('t4.207', Get_Ftr_Chk2 (p_at_id, p_nda => 6175));
        AddParam ('t4.208', Get_Ftr_Chk2 (p_at_id, p_nda => 6176));
        AddParam ('t4.209', Get_Ftr_Chk2 (p_at_id, p_nda => 6177));
        AddParam ('t4.210', Get_Ftr_Chk2 (p_at_id, p_nda => 6178));
        AddParam ('t4.211', Get_Ftr_Chk2 (p_at_id, p_nda => 6179));
        AddParam ('t4.212', Get_Ftr_Chk2 (p_at_id, p_nda => 6180));
        AddParam ('t4.213', Get_Ftr_Chk2 (p_at_id, p_nda => 6181));
        AddParam ('t4.214', Get_Ftr_Chk2 (p_at_id, p_nda => 6182));
        AddParam ('t4.215', Get_Ftr_Chk2 (p_at_id, p_nda => 6183));
        AddParam ('t4.216', Get_Ftr_Chk2 (p_at_id, p_nda => 6184));
        AddParam ('t4.217', Get_Ftr_Chk2 (p_at_id, p_nda => 6185));
        AddParam ('t4.218', Get_Ftr_Chk2 (p_at_id, p_nda => 6186));
        AddParam ('t4.219', Get_Ftr_Chk2 (p_at_id, p_nda => 6187));
        AddParam ('t4.220', Get_Ftr_Chk2 (p_at_id, p_nda => 6188));
        AddParam ('t4.221', Get_Ftr_Chk2 (p_at_id, p_nda => 6189));
        AddParam ('t4.222', Get_Ftr_Chk2 (p_at_id, p_nda => 6190));
        AddParam ('t4.223', Get_Ftr_Chk2 (p_at_id, p_nda => 6191));
        AddParam ('t4.224', Get_Ftr_Chk2 (p_at_id, p_nda => 6192));
        AddParam ('t4.225', Get_Ftr_Chk2 (p_at_id, p_nda => 6193));
        --Організація роботи (зайнятості)
        AddParam ('t4.226', Get_Ftr_Chk2 (p_at_id, p_nda => 6194));
        AddParam ('t4.227', Get_Ftr_Chk2 (p_at_id, p_nda => 6195));
        AddParam ('t4.228', Get_Ftr_Chk2 (p_at_id, p_nda => 6196));
        AddParam ('t4.229', Get_Ftr_Chk2 (p_at_id, p_nda => 6197));
        AddParam ('t4.230', Get_Ftr_Chk2 (p_at_id, p_nda => 6198));
        AddParam ('t4.231', Get_Ftr_Chk2 (p_at_id, p_nda => 6199));
        AddParam ('t4.232', Get_Ftr_Chk2 (p_at_id, p_nda => 6200));
        AddParam ('t4.233', Get_Ftr_Chk2 (p_at_id, p_nda => 6201));
        AddParam ('t4.234', Get_Ftr_Chk2 (p_at_id, p_nda => 6202));
        AddParam ('t4.235', Get_Ftr_Chk2 (p_at_id, p_nda => 6203));
        AddParam ('t4.236', Get_Ftr_Chk2 (p_at_id, p_nda => 6204));
        AddParam ('t4.237', Get_Ftr_Chk2 (p_at_id, p_nda => 6205));
        AddParam ('t4.238', Get_Ftr_Chk2 (p_at_id, p_nda => 6206));
        AddParam ('t4.239', Get_Ftr_Chk2 (p_at_id, p_nda => 6207));
        AddParam ('t4.240', Get_Ftr_Chk2 (p_at_id, p_nda => 6208));
        AddParam ('t4.241', Get_Ftr_Chk2 (p_at_id, p_nda => 6209));
        AddParam ('t4.242', Get_Ftr_Chk2 (p_at_id, p_nda => 6210));
        AddParam ('t4.243', Get_Ftr_Chk2 (p_at_id, p_nda => 6211));
        AddParam ('t4.244', Get_Ftr_Chk2 (p_at_id, p_nda => 6212));
        AddParam ('t4.245', Get_Ftr_Chk2 (p_at_id, p_nda => 6213));
        AddParam ('t4.246', Get_Ftr_Chk2 (p_at_id, p_nda => 6214));
        AddParam ('t4.247', Get_Ftr_Chk2 (p_at_id, p_nda => 6215));
        AddParam ('t4.248', Get_Ftr_Chk2 (p_at_id, p_nda => 6216));
        AddParam ('t4.249', Get_Ftr_Chk2 (p_at_id, p_nda => 6217));
        AddParam ('t4.250', Get_Ftr_Chk2 (p_at_id, p_nda => 6218));
        --Дотримання правил безпеки та поведінки
        AddParam ('t4.251', Get_Ftr_Chk2 (p_at_id, p_nda => 6219));
        AddParam ('t4.252', Get_Ftr_Chk2 (p_at_id, p_nda => 6220));
        AddParam ('t4.253', Get_Ftr_Chk2 (p_at_id, p_nda => 6221));
        AddParam ('t4.254', Get_Ftr_Chk2 (p_at_id, p_nda => 6222));
        AddParam ('t4.255', Get_Ftr_Chk2 (p_at_id, p_nda => 6223));
        AddParam ('t4.256', Get_Ftr_Chk2 (p_at_id, p_nda => 6224));
        AddParam ('t4.257', Get_Ftr_Chk2 (p_at_id, p_nda => 6225));
        AddParam ('t4.258', Get_Ftr_Chk2 (p_at_id, p_nda => 6226));
        AddParam ('t4.259', Get_Ftr_Chk2 (p_at_id, p_nda => 6227));
        AddParam ('t4.260', Get_Ftr_Chk2 (p_at_id, p_nda => 6228));
        AddParam ('t4.261', Get_Ftr_Chk2 (p_at_id, p_nda => 6229));
        AddParam ('t4.262', Get_Ftr_Chk2 (p_at_id, p_nda => 6230));
        AddParam ('t4.263', Get_Ftr_Chk2 (p_at_id, p_nda => 6231));
        AddParam ('t4.264', Get_Ftr_Chk2 (p_at_id, p_nda => 6232));
        AddParam ('t4.265', Get_Ftr_Chk2 (p_at_id, p_nda => 6233));
        AddParam ('t4.266', Get_Ftr_Chk2 (p_at_id, p_nda => 6234));
        AddParam ('t4.267', Get_Ftr_Chk2 (p_at_id, p_nda => 6235));
        AddParam ('t4.268', Get_Ftr_Chk2 (p_at_id, p_nda => 6236));
        AddParam ('t4.269', Get_Ftr_Chk2 (p_at_id, p_nda => 6237));
        AddParam ('t4.270', Get_Ftr_Chk2 (p_at_id, p_nda => 6238));
        AddParam ('t4.271', Get_Ftr_Chk2 (p_at_id, p_nda => 6239));
        AddParam ('t4.272', Get_Ftr_Chk2 (p_at_id, p_nda => 6240));
        AddParam ('t4.273', Get_Ftr_Chk2 (p_at_id, p_nda => 6241));
        AddParam ('t4.274', Get_Ftr_Chk2 (p_at_id, p_nda => 6242));
        AddParam ('t4.275', Get_Ftr_Chk2 (p_at_id, p_nda => 6243));
        --Знання ресурсів громади
        AddParam ('t4.276', Get_Ftr_Chk2 (p_at_id, p_nda => 6244));
        AddParam ('t4.277', Get_Ftr_Chk2 (p_at_id, p_nda => 6245));
        AddParam ('t4.278', Get_Ftr_Chk2 (p_at_id, p_nda => 6246));
        AddParam ('t4.279', Get_Ftr_Chk2 (p_at_id, p_nda => 6247));
        AddParam ('t4.280', Get_Ftr_Chk2 (p_at_id, p_nda => 6248));
        AddParam ('t4.281', Get_Ftr_Chk2 (p_at_id, p_nda => 6249));
        AddParam ('t4.282', Get_Ftr_Chk2 (p_at_id, p_nda => 6250));
        AddParam ('t4.283', Get_Ftr_Chk2 (p_at_id, p_nda => 6251));
        AddParam ('t4.284', Get_Ftr_Chk2 (p_at_id, p_nda => 6252));
        AddParam ('t4.285', Get_Ftr_Chk2 (p_at_id, p_nda => 6253));
        AddParam ('t4.286', Get_Ftr_Chk2 (p_at_id, p_nda => 6254));
        AddParam ('t4.287', Get_Ftr_Chk2 (p_at_id, p_nda => 6255));
        AddParam ('t4.288', Get_Ftr_Chk2 (p_at_id, p_nda => 6256));
        AddParam ('t4.289', Get_Ftr_Chk2 (p_at_id, p_nda => 6257));
        AddParam ('t4.290', Get_Ftr_Chk2 (p_at_id, p_nda => 6258));
        AddParam ('t4.291', Get_Ftr_Chk2 (p_at_id, p_nda => 6259));
        AddParam ('t4.292', Get_Ftr_Chk2 (p_at_id, p_nda => 6260));
        AddParam ('t4.293', Get_Ftr_Chk2 (p_at_id, p_nda => 6261));
        AddParam ('t4.294', Get_Ftr_Chk2 (p_at_id, p_nda => 6262));
        AddParam ('t4.295', Get_Ftr_Chk2 (p_at_id, p_nda => 6263));
        AddParam ('t4.296', Get_Ftr_Chk2 (p_at_id, p_nda => 6264));
        AddParam ('t4.297', Get_Ftr_Chk2 (p_at_id, p_nda => 6265));
        AddParam ('t4.298', Get_Ftr_Chk2 (p_at_id, p_nda => 6266));
        AddParam ('t4.299', Get_Ftr_Chk2 (p_at_id, p_nda => 6267));
        AddParam ('t4.300', Get_Ftr_Chk2 (p_at_id, p_nda => 6268));
        --Міжособистісні відносини
        AddParam ('t4.301', Get_Ftr_Chk2 (p_at_id, p_nda => 6269));
        AddParam ('t4.302', Get_Ftr_Chk2 (p_at_id, p_nda => 6270));
        AddParam ('t4.303', Get_Ftr_Chk2 (p_at_id, p_nda => 6271));
        AddParam ('t4.304', Get_Ftr_Chk2 (p_at_id, p_nda => 6272));
        AddParam ('t4.305', Get_Ftr_Chk2 (p_at_id, p_nda => 6273));
        AddParam ('t4.306', Get_Ftr_Chk2 (p_at_id, p_nda => 6274));
        AddParam ('t4.307', Get_Ftr_Chk2 (p_at_id, p_nda => 6275));
        AddParam ('t4.308', Get_Ftr_Chk2 (p_at_id, p_nda => 6276));
        AddParam ('t4.309', Get_Ftr_Chk2 (p_at_id, p_nda => 6277));
        AddParam ('t4.310', Get_Ftr_Chk2 (p_at_id, p_nda => 6278));
        AddParam ('t4.311', Get_Ftr_Chk2 (p_at_id, p_nda => 6279));
        AddParam ('t4.312', Get_Ftr_Chk2 (p_at_id, p_nda => 6280));
        AddParam ('t4.313', Get_Ftr_Chk2 (p_at_id, p_nda => 6281));
        AddParam ('t4.314', Get_Ftr_Chk2 (p_at_id, p_nda => 6282));
        AddParam ('t4.315', Get_Ftr_Chk2 (p_at_id, p_nda => 6283));
        AddParam ('t4.316', Get_Ftr_Chk2 (p_at_id, p_nda => 6284));
        AddParam ('t4.317', Get_Ftr_Chk2 (p_at_id, p_nda => 6285));
        AddParam ('t4.318', Get_Ftr_Chk2 (p_at_id, p_nda => 6286));
        AddParam ('t4.319', Get_Ftr_Chk2 (p_at_id, p_nda => 6287));
        AddParam ('t4.320', Get_Ftr_Chk2 (p_at_id, p_nda => 6288));
        AddParam ('t4.321', Get_Ftr_Chk2 (p_at_id, p_nda => 6289));
        AddParam ('t4.322', Get_Ftr_Chk2 (p_at_id, p_nda => 6290));
        AddParam ('t4.323', Get_Ftr_Chk2 (p_at_id, p_nda => 6291));
        AddParam ('t4.324', Get_Ftr_Chk2 (p_at_id, p_nda => 6292));
        AddParam ('t4.325', Get_Ftr_Chk2 (p_at_id, p_nda => 6293));
        --Обізнаність у юридичній сфері
        AddParam ('t4.326', Get_Ftr_Chk2 (p_at_id, p_nda => 6294));
        AddParam ('t4.327', Get_Ftr_Chk2 (p_at_id, p_nda => 6295));
        AddParam ('t4.328', Get_Ftr_Chk2 (p_at_id, p_nda => 6296));
        AddParam ('t4.329', Get_Ftr_Chk2 (p_at_id, p_nda => 6297));
        AddParam ('t4.330', Get_Ftr_Chk2 (p_at_id, p_nda => 6298));
        AddParam ('t4.331', Get_Ftr_Chk2 (p_at_id, p_nda => 6299));
        AddParam ('t4.332', Get_Ftr_Chk2 (p_at_id, p_nda => 6300));
        AddParam ('t4.333', Get_Ftr_Chk2 (p_at_id, p_nda => 6301));
        AddParam ('t4.334', Get_Ftr_Chk2 (p_at_id, p_nda => 6302));
        AddParam ('t4.335', Get_Ftr_Chk2 (p_at_id, p_nda => 6303));
        AddParam ('t4.336', Get_Ftr_Chk2 (p_at_id, p_nda => 6304));
        AddParam ('t4.337', Get_Ftr_Chk2 (p_at_id, p_nda => 6305));
        AddParam ('t4.338', Get_Ftr_Chk2 (p_at_id, p_nda => 6306));
        AddParam ('t4.339', Get_Ftr_Chk2 (p_at_id, p_nda => 6307));
        AddParam ('t4.340', Get_Ftr_Chk2 (p_at_id, p_nda => 6308));
        AddParam ('t4.341', Get_Ftr_Chk2 (p_at_id, p_nda => 6309));
        AddParam ('t4.342', Get_Ftr_Chk2 (p_at_id, p_nda => 6310));
        AddParam ('t4.343', Get_Ftr_Chk2 (p_at_id, p_nda => 6311));
        AddParam ('t4.344', Get_Ftr_Chk2 (p_at_id, p_nda => 6312));
        AddParam ('t4.345', Get_Ftr_Chk2 (p_at_id, p_nda => 6313));
        AddParam ('t4.346', Get_Ftr_Chk2 (p_at_id, p_nda => 6314));
        AddParam ('t4.347', Get_Ftr_Chk2 (p_at_id, p_nda => 6315));
        AddParam ('t4.348', Get_Ftr_Chk2 (p_at_id, p_nda => 6316));
        AddParam ('t4.349', Get_Ftr_Chk2 (p_at_id, p_nda => 6317));
        AddParam ('t4.350', Get_Ftr_Chk2 (p_at_id, p_nda => 6318));

        --Таблиця 5 Картка визначення індивідуальних потреб отримувача соціальної послуги (ітоги з Таблиці 4)
        --1 Управління фінансами
        AddParam (
            't51.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 552).ate_indicator_value1); --Нульовий
        AddParam (
            't51.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 553).ate_indicator_value1); --Базовий
        AddParam (
            't51.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 554).ate_indicator_value1); --Задовільний
        AddParam (
            't51.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 555).ate_indicator_value1); --Добрий
        AddParam (
            't51.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 556).ate_indicator_value1); --Високий
        --2 організація харчування
        AddParam (
            't52.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 557).ate_indicator_value1); --Нульовий
        AddParam (
            't52.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 558).ate_indicator_value1); --Базовий
        AddParam (
            't52.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 559).ate_indicator_value1); --Задовільний
        AddParam (
            't52.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 560).ate_indicator_value1); --Добрий
        AddParam (
            't52.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 561).ate_indicator_value1); --Високий
        --3 Зовнішній вигляд
        AddParam (
            't53.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 562).ate_indicator_value1); --Нульовий
        AddParam (
            't53.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 563).ate_indicator_value1); --Базовий
        AddParam (
            't53.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 564).ate_indicator_value1); --Задовільний
        AddParam (
            't53.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 565).ate_indicator_value1); --Добрий
        AddParam (
            't53.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 566).ate_indicator_value1); --Високий
        --4 здоров’я
        AddParam (
            't54.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 567).ate_indicator_value1); --Нульовий
        AddParam (
            't54.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 568).ate_indicator_value1); --Базовий
        AddParam (
            't54.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 569).ate_indicator_value1); --Задовільний
        AddParam (
            't54.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 570).ate_indicator_value1); --Добрий
        AddParam (
            't54.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 571).ate_indicator_value1); --Високий
        --5 утримання помешкання
        AddParam (
            't55.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 572).ate_indicator_value1); --Нульовий
        AddParam (
            't55.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 573).ate_indicator_value1); --Базовий
        AddParam (
            't55.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 574).ate_indicator_value1); --Задовільний
        AddParam (
            't55.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 575).ate_indicator_value1); --Добрий
        AddParam (
            't55.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 576).ate_indicator_value1); --Високий
        --6 обізнаність у сфері нерухомості
        AddParam (
            't56.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 577).ate_indicator_value1); --Нульовий
        AddParam (
            't56.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 578).ate_indicator_value1); --Базовий
        AddParam (
            't56.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 579).ate_indicator_value1); --Задовільний
        AddParam (
            't56.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 580).ate_indicator_value1); --Добрий
        AddParam (
            't56.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 581).ate_indicator_value1); --Високий
        --7 користування транспортом
        AddParam (
            't57.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 582).ate_indicator_value1); --Нульовий
        AddParam (
            't57.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 583).ate_indicator_value1); --Базовий
        AddParam (
            't57.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 584).ate_indicator_value1); --Задовільний
        AddParam (
            't57.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 585).ate_indicator_value1); --Добрий
        AddParam (
            't57.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 586).ate_indicator_value1); --Високий
        --8 організація навчального процесу
        AddParam (
            't58.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 587).ate_indicator_value1); --Нульовий
        AddParam (
            't58.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 588).ate_indicator_value1); --Базовий
        AddParam (
            't58.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 589).ate_indicator_value1); --Задовільний
        AddParam (
            't58.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 590).ate_indicator_value1); --Добрий
        AddParam (
            't58.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 591).ate_indicator_value1); --Високий
        --9 навички пошуку роботи
        AddParam (
            't59.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 592).ate_indicator_value1); --Нульовий
        AddParam (
            't59.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 593).ate_indicator_value1); --Базовий
        AddParam (
            't59.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 594).ate_indicator_value1); --Задовільний
        AddParam (
            't59.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 595).ate_indicator_value1); --Добрий
        AddParam (
            't59.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 596).ate_indicator_value1); --Високий
        --10 організація роботи
        AddParam (
            't510.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 597).ate_indicator_value1); --Нульовий
        AddParam (
            't510.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 598).ate_indicator_value1); --Базовий
        AddParam (
            't510.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 599).ate_indicator_value1); --Задовільний
        AddParam (
            't510.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 600).ate_indicator_value1); --Добрий
        AddParam (
            't510.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 601).ate_indicator_value1); --Високий
        --11  дотримання правил безпеки та поведінка
        AddParam (
            't511.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 602).ate_indicator_value1); --Нульовий
        AddParam (
            't511.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 603).ate_indicator_value1); --Базовий
        AddParam (
            't511.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 604).ate_indicator_value1); --Задовільний
        AddParam (
            't511.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 605).ate_indicator_value1); --Добрий
        AddParam (
            't511.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 606).ate_indicator_value1); --Високий
        --12 знання ресурсів громади
        AddParam (
            't512.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 607).ate_indicator_value1); --Нульовий
        AddParam (
            't512.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 608).ate_indicator_value1); --Базовий
        AddParam (
            't512.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 609).ate_indicator_value1); --Задовільний
        AddParam (
            't512.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 610).ate_indicator_value1); --Добрий
        AddParam (
            't512.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 611).ate_indicator_value1); --Високий
        --13 міжособистісні відносини
        AddParam (
            't513.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 612).ate_indicator_value1); --Нульовий
        AddParam (
            't513.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 613).ate_indicator_value1); --Базовий
        AddParam (
            't513.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 614).ate_indicator_value1); --Задовільний
        AddParam (
            't513.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 615).ate_indicator_value1); --Добрий
        AddParam (
            't513.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 616).ate_indicator_value1); --Високий
        --14 обізнаність у юридичній сфері
        AddParam (
            't514.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 617).ate_indicator_value1); --Нульовий
        AddParam (
            't514.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 618).ate_indicator_value1); --Базовий
        AddParam (
            't514.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 619).ate_indicator_value1); --Задовільний
        AddParam (
            't514.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 620).ate_indicator_value1); --Добрий
        AddParam (
            't514.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 621).ate_indicator_value1); --Високий
        --Загальна кількість балів nng_id=622
        AddParam ('t51', Get_Ftr_Nt (p_at_id, p_nda => 6319));
        AddParam ('t52', Get_Ftr_Nt (p_at_id, p_nda => 6320));
        AddParam ('t53', Get_Ftr_Nt (p_at_id, p_nda => 6321));
        AddParam ('t54', Get_Ftr_Nt (p_at_id, p_nda => 6322));
        AddParam ('t55', Get_Ftr_Nt (p_at_id, p_nda => 6323));
        AddParam ('t56', Get_Ftr_Nt (p_at_id, p_nda => 6324));
        AddParam ('t57', Get_Ftr_Nt (p_at_id, p_nda => 6325));
        AddParam ('t58', Get_Ftr_Nt (p_at_id, p_nda => 6326));
        AddParam ('t59', Get_Ftr_Nt (p_at_id, p_nda => 6327));
        AddParam ('t510', Get_Ftr_Nt (p_at_id, p_nda => 6328));
        AddParam ('t511', Get_Ftr_Nt (p_at_id, p_nda => 6329));
        AddParam ('t512', Get_Ftr_Nt (p_at_id, p_nda => 6330));
        AddParam ('t513', Get_Ftr_Nt (p_at_id, p_nda => 6331));
        AddParam ('t514', Get_Ftr_Nt (p_at_id, p_nda => 6332));

        --Висновок.
        AddParam ('v1', GetScPIB (c.at_sc));    --Отримувач соціальної послуги
        AddParam (
            'v2',
            NVL (
                Api$Act_Rpt.v_ddn (
                    'uss_ndi.V_DDN_SS_LEVEL_HAS_SKL',
                    Api$Act_Rpt.Get_Ftr (p_at_id, p_nda => 6333)),
                '______'));                                         --на рівні
        AddParam (
            'v3',
            NVL (
                TO_CHAR (
                    Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 622).ate_indicator_value1),
                '______'));                                     --усього балів
        AddParam (
            'v4',
            NVL (
                TO_CHAR (
                    Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 622).ate_indicator_value2),
                '______'));                               --в середньому годин

        --Особи, які брали участь в оцінюванні
        l_str := q'[
    select p.pib                  as c1,
           p.Relation_Tp          as c2,
           null                   as c3,
           api$act_rpt.get_sign_mark(:p_at_id, p.atp_id, '') as c4
      from table(uss_esr.Api$Act_Rpt.At_Person_for_act(:p_at_id)) p
     where 1=1
       and p.atp_app_tp not in ('OS', 'AP')
     union
     select atop_ln || ' ' || atop_fn || ' ' || atop_mn as c1,
            atop_position as c2,
            '' as c3,
            '' as c4
       from uss_esr.at_other_spec t
      where t.atop_at = :p_at_id
        and history_status = 'A'
    ]';

        l_str :=
            REGEXP_REPLACE (l_str,
                            ':p_at_id',
                            p_at_id,
                            1,
                            0,
                            'i');
        l_str :=
            REGEXP_REPLACE (
                l_str,
                'null',
                CHR (39) || TO_CHAR (c.at_dt, 'dd.mm.yyyy') || CHR (39),
                1,
                0,
                'i');
        rdm$rtfl_univ.AddDataset ('ds', l_str);

        AddParam ('sgn1',
                  api$act_rpt.Underline (Api$Act_Rpt.GetCuPIB (c.at_cu), 1)); --Особа, яка провела оцінювання
        AddParam ('sgn2',
                  api$act_rpt.Underline (TO_CHAR (c.at_dt, 'dd.mm.yyyy'), 1));

        ------------------------------------
        rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                         p_rpt_blob   => l_result);
        replace_ekr (l_result);

        RETURN l_result;
    END ACT_DOC_872_R1;

    --#94119 ОЦІНКА ПОТРЕБ прийомної дитини, дитини-вихованця (для послуги 010.2)
    FUNCTION ACT_DOC_875_R1 (p_at_id IN NUMBER)
        RETURN BLOB
    IS
        --пов'язан з документом ACT_IP_DOC_876_R1
        CURSOR c_at IS
            SELECT a.at_dt,
                   a.at_sc,
                   a.at_wu,
                   a.at_cu
              FROM act a
             WHERE a.at_id = p_at_id;

        c          c_at%ROWTYPE;

        lO         NUMBER;                                         --отримувач
        p          Api$Act_Rpt.R_Person_for_act;


        l_jbr_id   NUMBER;
        l_result   BLOB;
    BEGIN
        rdm$rtfl_univ.initreport (p_code     => 'ACT_DOC_875_R1',
                                  p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);

        ------------------------------------
        OPEN c_at;

        FETCH c_at INTO c;

        CLOSE c_at;

        lO := Api$Act_Rpt.get_AtPersonSc_id (p_at_id, c.at_sc);
        p := get_AtPerson (p_at_id, lO);

        addparam ('1', p.LN);
        addparam ('2', p.fn);
        addparam ('3', p.mn);
        addparam ('4', p.birth_dt_str);
        addparam ('5', TRUNC (MONTHS_BETWEEN (SYSDATE, p.birth_dt) / 12));
        addparam ('6', Get_Ftr_Nt (p_at_id, p_nda => 2834));
        addparam ('7', Get_Ftr_Nt (p_at_id, p_nda => 2835));
        --таблиця "Складові оцінювання"
        --Стан на момент оцінки
        addparam ('t1', Get_Ftr_Nt (p_at_id, p_nda => 1495));
        addparam ('t2', Get_Ftr_Nt (p_at_id, p_nda => 1496));
        addparam ('t3', Get_Ftr_Nt (p_at_id, p_nda => 1497));
        addparam ('t4', Get_Ftr_Nt (p_at_id, p_nda => 1502));
        addparam ('t5', Get_Ftr_Nt (p_at_id, p_nda => 1503));
        addparam ('t6', Get_Ftr_Nt (p_at_id, p_nda => 1504));
        addparam ('t7', Get_Ftr_Nt (p_at_id, p_nda => 1509));
        addparam ('t8', Get_Ftr_Nt (p_at_id, p_nda => 1510));
        addparam ('t9', Get_Ftr_Nt (p_at_id, p_nda => 1511));
        addparam ('t10', Get_Ftr_Nt (p_at_id, p_nda => 1516));
        addparam ('t11', Get_Ftr_Nt (p_at_id, p_nda => 1517));
        addparam ('t12', Get_Ftr_Nt (p_at_id, p_nda => 1518));
        addparam ('t13', Get_Ftr_Nt (p_at_id, p_nda => 1523));
        addparam ('t14', Get_Ftr_Nt (p_at_id, p_nda => 1524));
        addparam ('t15', Get_Ftr_Nt (p_at_id, p_nda => 1525));
        addparam ('t16', Get_Ftr_Nt (p_at_id, p_nda => 1530));
        addparam ('t17', Get_Ftr_Nt (p_at_id, p_nda => 1531));
        addparam ('t18', Get_Ftr_Nt (p_at_id, p_nda => 1532));
        addparam ('t19', Get_Ftr_Nt (p_at_id, p_nda => 1538));
        addparam ('t20', Get_Ftr_Nt (p_at_id, p_nda => 1539));
        --Конкретні потреби дитини (за результатами оцінки)
        addparam ('t1-1', Get_Ftr_Nt (p_at_id, p_nda => 1540));
        addparam ('t2-1', Get_Ftr_Nt (p_at_id, p_nda => 1546));
        addparam ('t3-1', Get_Ftr_Nt (p_at_id, p_nda => 1547));
        addparam ('t4-1', Get_Ftr_Nt (p_at_id, p_nda => 1548));
        addparam ('t5-1', Get_Ftr_Nt (p_at_id, p_nda => 1554));
        addparam ('t6-1', Get_Ftr_Nt (p_at_id, p_nda => 1555));
        addparam ('t7-1', Get_Ftr_Nt (p_at_id, p_nda => 1556));
        addparam ('t8-1', Get_Ftr_Nt (p_at_id, p_nda => 1561));
        addparam ('t9-1', Get_Ftr_Nt (p_at_id, p_nda => 1562));
        addparam ('t10-1', Get_Ftr_Nt (p_at_id, p_nda => 1563));
        addparam ('t11-1', Get_Ftr_Nt (p_at_id, p_nda => 1567));
        addparam ('t12-1', Get_Ftr_Nt (p_at_id, p_nda => 1568));
        addparam ('t13-1', Get_Ftr_Nt (p_at_id, p_nda => 1569));
        addparam ('t14-1', Get_Ftr_Nt (p_at_id, p_nda => 1574));
        addparam ('t15-1', Get_Ftr_Nt (p_at_id, p_nda => 1575));
        addparam ('t16-1', Get_Ftr_Nt (p_at_id, p_nda => 1576));
        addparam ('t17-1', Get_Ftr_Nt (p_at_id, p_nda => 1582));
        addparam ('t18-1', Get_Ftr_Nt (p_at_id, p_nda => 1583));
        addparam ('t19-1', Get_Ftr_Nt (p_at_id, p_nda => 1584));
        addparam ('t20-1', Get_Ftr_Nt (p_at_id, p_nda => 1589));

        AddParam ('sng1', Api$act.Get_At_Spec_Name (c.at_wu, c.at_cu)); --П.І.Б. фахівця центру
        AddParam (
            'sng2',
            NVL (Api$Act_Rpt.Date2Str (c.at_dt),
                 '____  ________________20_____'));

        ------------------------------------
        rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                         p_rpt_blob   => l_result);
        replace_ekr (l_result);

        RETURN l_result;
    END;

    --#94120 Карта визначення індивідуальних потреб при працевлаштуванні
    FUNCTION ACT_DOC_877_R1 (p_at_id IN NUMBER)
        RETURN BLOB
    IS
        CURSOR c_at IS
            SELECT a.at_dt,
                   a.at_sc,
                   a.at_wu,
                   a.at_cu,
                   a.At_rnspm
              FROM act a
             WHERE a.at_id = p_at_id;

        c          c_at%ROWTYPE;

        p          Api$Act_Rpt.R_Person_for_act;                   --отримувач

        l_str      VARCHAR2 (32000);

        l_jbr_id   NUMBER;
        l_result   BLOB;
    BEGIN
        rdm$rtfl_univ.initreport (p_code     => 'ACT_DOC_877_R1',
                                  p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);

        ------------------------------------
        OPEN c_at;

        FETCH c_at INTO c;

        CLOSE c_at;

        p :=
            get_AtPerson (p_at    => p_at_id,
                          p_atp   => get_AtPerson_id (p_at_id, 'OS'));

        AddParam ('1', Api$Act_Rpt.Get_Nsp_Name (p_rnspm_id => c.At_rnspm)); --назва надавача
        AddParam ('2', TO_CHAR (c.at_dt, 'dd.mm.yyyy'));

        AddParam ('11', p.pib);
        AddParam ('12', p.birth_dt_str);
        AddParam ('13', p.live_address);
        --Освіта uss_ndi.V_DDN_SS_EDUCATION
        AddParam ('14-1', Get_Ftr_Chk2 (p_at_id, p_nda => 3122, p_chk => 'HE'));
        AddParam ('14-2', Get_Ftr_Chk2 (p_at_id, p_nda => 3122, p_chk => 'PE'));
        AddParam ('14-3', Get_Ftr_Chk2 (p_at_id, p_nda => 3122, p_chk => 'GE'));
        AddParam ('14-4', Get_Ftr_Chk2 (p_at_id, p_nda => 3122, p_chk => 'BE'));
        --Правовий статус uss_ndi.V_DDN_SS_CAPABLE_2
        AddParam ('15-1', Get_Ftr_Chk2 (p_at_id, p_nda => 3123, p_chk => 'CP'));
        AddParam ('15-2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 3123, p_chk => 'LCP'));
        AddParam ('15-3',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 3123, p_chk => 'NCP'));
        --Категорії осіб
        AddParam ('16-1', Get_Ftr_Chk2 (p_at_id, p_nda => 3124, p_chk => 'T')); --відбула покарання
        AddParam ('16-2', Get_Ftr_Chk2 (p_at_id, p_nda => 3124, p_chk => 'F'));
        --з інвалідністю
        AddParam ('17', Get_Ftr_Nt (p_at_id, p_nda => 3125));
        AddParam ('18', Get_Ftr_Nt (p_at_id, p_nda => 3126));

        --Обмеження життєдіяльності uss_ndi.V_DDN_SS_LIMIT_LIFE
        --1
        AddParam ('t1-1', Get_Ftr_Chk2 (p_at_id, p_nda => 3127, p_chk => 'ME'));
        AddParam ('t1-2', Get_Ftr_Chk2 (p_at_id, p_nda => 3128, p_chk => 'ME'));
        AddParam ('t1-3', Get_Ftr_Chk2 (p_at_id, p_nda => 3129, p_chk => 'ME'));
        AddParam ('t1-4', Get_Ftr_Chk2 (p_at_id, p_nda => 3221, p_chk => 'ME'));
        AddParam ('t1-5', Get_Ftr_Chk2 (p_at_id, p_nda => 3278, p_chk => 'ME'));
        AddParam ('t1-6', Get_Ftr_Chk2 (p_at_id, p_nda => 3300, p_chk => 'ME'));
        AddParam ('t1-7', Get_Ftr_Chk2 (p_at_id, p_nda => 3312, p_chk => 'ME'));
        AddParam ('t1-8', Get_Ftr_Chk2 (p_at_id, p_nda => 3329, p_chk => 'ME'));
        --2
        AddParam ('t1-1-1',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 3127, p_chk => 'E'));
        AddParam ('t1-2-1',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 3128, p_chk => 'E'));
        AddParam ('t1-3-1',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 3129, p_chk => 'E'));
        AddParam ('t1-4-1',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 3221, p_chk => 'E'));
        AddParam ('t1-5-1',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 3278, p_chk => 'E'));
        AddParam ('t1-6-1',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 3300, p_chk => 'E'));
        AddParam ('t1-7-1',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 3312, p_chk => 'E'));
        AddParam ('t1-8-1',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 3329, p_chk => 'E'));
        --3
        AddParam ('t1-1-2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 3127, p_chk => 'SE'));
        AddParam ('t1-2-2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 3128, p_chk => 'SE'));
        AddParam ('t1-3-2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 3129, p_chk => 'SE'));
        AddParam ('t1-4-2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 3221, p_chk => 'SE'));
        AddParam ('t1-5-2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 3278, p_chk => 'SE'));
        AddParam ('t1-6-2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 3300, p_chk => 'SE'));
        AddParam ('t1-7-2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 3312, p_chk => 'SE'));
        AddParam ('t1-8-2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 3329, p_chk => 'SE'));

        --Реабілітаційний потенціал uss_ndi.V_DDN_SS_REHABILIT_PTN
        AddParam ('20-1', Get_Ftr_Chk2 (p_at_id, p_nda => 3345, p_chk => 'H'));
        AddParam ('20-2', Get_Ftr_Chk2 (p_at_id, p_nda => 3345, p_chk => 'M'));
        AddParam ('20-3', Get_Ftr_Chk2 (p_at_id, p_nda => 3345, p_chk => 'L'));
        AddParam ('21', Get_Ftr_Nt (p_at_id, p_nda => 3545));
        AddParam ('22', Get_Ftr_Nt (p_at_id, p_nda => 3546));
        AddParam ('23', Get_Ftr_Nt (p_at_id, p_nda => 3551));
        --Пересування uss_ndi.V_DDN_SS_MOVEMENT
        AddParam ('24-1', Get_Ftr_Chk2 (p_at_id, p_nda => 3555, p_chk => 'IN'));
        AddParam ('24-2', Get_Ftr_Chk2 (p_at_id, p_nda => 3555, p_chk => 'AP'));
        AddParam ('24-3', Get_Ftr_Chk2 (p_at_id, p_nda => 3555, p_chk => 'GD'));
        --uss_ndi.V_DDN_SS_USE_P_TRANSPORT
        AddParam ('25-1', Get_Ftr_Chk2 (p_at_id, p_nda => 3556, p_chk => 'T'));
        AddParam ('25-2', Get_Ftr_Chk2 (p_at_id, p_nda => 3556, p_chk => 'F'));

        --II. Сім’я та оточення
        --Сімейний стан  uss_ndi.V_DDN_SS_MARITAL_STT
        AddParam ('26-1', Get_Ftr_Chk2 (p_at_id, p_nda => 3557, p_chk => 'M'));
        AddParam ('26-2', Get_Ftr_Chk2 (p_at_id, p_nda => 3557, p_chk => 'W'));
        AddParam ('26-3', Get_Ftr_Chk2 (p_at_id, p_nda => 3557, p_chk => 'S'));
        AddParam ('26-4', Get_Ftr_Chk2 (p_at_id, p_nda => 3557, p_chk => 'D'));
        AddParam ('27', Get_Ftr_Nt (p_at_id, p_nda => 3558)); --Наявність працездатних
        --Можливість скористатися допомогою
        AddParam ('28', Get_Ftr_Nt (p_at_id, p_nda => 3550));
        AddParam ('29', Get_Ftr_Nt (p_at_id, p_nda => 3560));
        AddParam ('30', Get_Ftr_Nt (p_at_id, p_nda => 3561));

        --ІІІ. Інформація щодо працевлаштування
        AddParam ('31', Get_Ftr_Nt (p_at_id, p_nda => 3562));
        --Наявність фаху
        AddParam ('32-1', Get_Ftr_Chk2 (p_at_id, p_nda => 3563, p_chk => 'T'));
        AddParam ('32-2', Get_Ftr_Nt (p_at_id, p_nda => 3563));
        AddParam ('32-3', Get_Ftr_Chk2 (p_at_id, p_nda => 3563, p_chk => 'F'));
        --Загальний стаж роботи
        AddParam ('34-1', Get_Ftr_Chk2 (p_at_id, p_nda => 3564, p_chk => 'T'));
        AddParam ('34-2', Get_Ftr_Nt (p_at_id, p_nda => 3564));
        AddParam ('34-3', Get_Ftr_Chk2 (p_at_id, p_nda => 3564, p_chk => 'F'));
        --Чи проходив попередню професійну реабілітацію
        AddParam ('36-1', Get_Ftr_Chk2 (p_at_id, p_nda => 3569, p_chk => 'T'));
        AddParam ('36-2', Get_Ftr_Chk2 (p_at_id, p_nda => 3569, p_chk => 'F'));
        AddParam ('36-3', Get_Ftr_Nt (p_at_id, p_nda => 3569));

        AddParam ('38', Get_Ftr_Nt (p_at_id, p_nda => 3570));
        --Який графік роботи найбільш прийнятний uss_ndi.V_DDN_SS_WORK_SCHDL
        AddParam ('39-1', Get_Ftr_Chk2 (p_at_id, p_nda => 3571, p_chk => 'FD'));
        AddParam ('39-2', Get_Ftr_Chk2 (p_at_id, p_nda => 3571, p_chk => 'PD'));
        AddParam ('39-3', Get_Ftr_Chk2 (p_at_id, p_nda => 3571, p_chk => 'PW'));
        AddParam ('39-4', Get_Ftr_Chk2 (p_at_id, p_nda => 3571, p_chk => 'SH'));
        AddParam ('39-5', Get_Ftr_Chk2 (p_at_id, p_nda => 3571, p_chk => 'FR'));
        AddParam ('39-6', Get_Ftr_Chk2 (p_at_id, p_nda => 3571, p_chk => 'HM'));
        --потреба в перервах
        AddParam ('40-1', Get_Ftr_Chk2 (p_at_id, p_nda => 3587, p_chk => 'T'));
        AddParam ('40-2', Get_Ftr_Chk2 (p_at_id, p_nda => 3587, p_chk => 'F'));
        AddParam ('41', Get_Ftr_Nt (p_at_id, p_nda => 3588));
        AddParam ('42', Get_Ftr_Nt (p_at_id, p_nda => 3589));
        AddParam ('43', Get_Ftr_Nt (p_at_id, p_nda => 3590));
        AddParam ('44', Get_Ftr_Nt (p_at_id, p_nda => 3597));

        --ІV. Висновки
        --Трудовий потенціал отримувача СП uss_ndi.V_DDN_SS_REHABILIT_PTN
        AddParam ('50-1', Get_Ftr_Chk2 (p_at_id, p_nda => 3598, p_chk => 'H'));
        AddParam ('50-2', Get_Ftr_Chk2 (p_at_id, p_nda => 3598, p_chk => 'M'));
        AddParam ('50-3', Get_Ftr_Chk2 (p_at_id, p_nda => 3598, p_chk => 'L'));

        --Можливі варіанти працевлаштування uss_ndi.V_DDN_SS_EMPL_OPTIONS
        AddParam ('t2-1', Api$Act_Rpt.AtFtrIsNotNull (p_at_id, p_nda => 3600));
        AddParam ('t2-1-1',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 3600, p_chk => 'F'));
        AddParam ('t2-1-2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 3600, p_chk => 'T'));
        AddParam ('t2-2', Api$Act_Rpt.AtFtrIsNotNull (p_at_id, p_nda => 3602));
        AddParam ('t2-2-1',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 3602, p_chk => 'F'));
        AddParam ('t2-2-2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 3602, p_chk => 'T'));
        AddParam ('t2-3', Api$Act_Rpt.AtFtrIsNotNull (p_at_id, p_nda => 3603));
        AddParam ('t2-3-1',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 3603, p_chk => 'F'));
        AddParam ('t2-3-2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 3603, p_chk => 'T'));
        AddParam ('t2-4', Api$Act_Rpt.AtFtrIsNotNull (p_at_id, p_nda => 3604));
        AddParam ('t2-4-1',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 3604, p_chk => 'F'));
        AddParam ('t2-4-2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 3604, p_chk => 'T'));
        AddParam ('t2-5', Api$Act_Rpt.AtFtrIsNotNull (p_at_id, p_nda => 3605));
        AddParam ('t2-5-1',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 3605, p_chk => 'F'));
        AddParam ('t2-5-2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 3605, p_chk => 'T'));
        AddParam ('t2-6', Api$Act_Rpt.AtFtrIsNotNull (p_at_id, p_nda => 3606));
        AddParam ('t2-6-1',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 3606, p_chk => 'F'));
        AddParam ('t2-6-2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 3606, p_chk => 'T'));
        AddParam ('t2-7', Api$Act_Rpt.AtFtrIsNotNull (p_at_id, p_nda => 3607));
        AddParam ('t2-7-1',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 3607, p_chk => 'F'));
        AddParam ('t2-7-2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 3607, p_chk => 'T'));
        --Потреба в додаткових соціальних послугах uss_ndi.V_DDN_SS_PLACE_ADD_SP
        AddParam ('t3-1', Api$Act_Rpt.AtFtrIsNotNull (p_at_id, p_nda => 3608));
        AddParam ('t3-1-1', Get_Ftr_Nt (p_at_id, p_nda => 3608));
        AddParam ('t3-1-2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 3608, p_chk => 'RC'));
        AddParam ('t3-1-3',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 3608, p_chk => 'OTHER'));
        AddParam ('t3-2', Api$Act_Rpt.AtFtrIsNotNull (p_at_id, p_nda => 3622));
        AddParam ('t3-2-1', Get_Ftr_Nt (p_at_id, p_nda => 3622));
        AddParam ('t3-2-2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 3622, p_chk => 'RC'));
        AddParam ('t3-2-3',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 3622, p_chk => 'OTHER'));
        AddParam ('t3-3', Api$Act_Rpt.AtFtrIsNotNull (p_at_id, p_nda => 3623));
        AddParam ('t3-3-1', Get_Ftr_Nt (p_at_id, p_nda => 3623));
        AddParam ('t3-3-2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 3623, p_chk => 'RC'));
        AddParam ('t3-3-3',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 3623, p_chk => 'OTHER'));
        AddParam ('t3-4', Api$Act_Rpt.AtFtrIsNotNull (p_at_id, p_nda => 3624));
        AddParam ('t3-4-1', Get_Ftr_Nt (p_at_id, p_nda => 3624));
        AddParam ('t3-4-2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 3624, p_chk => 'RC'));
        AddParam ('t3-4-3',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 3624, p_chk => 'OTHER'));
        AddParam ('t3-5', Api$Act_Rpt.AtFtrIsNotNull (p_at_id, p_nda => 3625));
        AddParam ('t3-5-1', Get_Ftr_Nt (p_at_id, p_nda => 3625));
        AddParam ('t3-5-2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 3625, p_chk => 'RC'));
        AddParam ('t3-5-3',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 3625, p_chk => 'OTHER'));
        AddParam ('t3-6', Api$Act_Rpt.AtFtrIsNotNull (p_at_id, p_nda => 3626));
        AddParam ('t3-6-1', Get_Ftr_Nt (p_at_id, p_nda => 3626));
        AddParam ('t3-6-2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 3626, p_chk => 'RC'));
        AddParam ('t3-6-3',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 3626, p_chk => 'OTHER'));
        AddParam ('t3-7', Api$Act_Rpt.AtFtrIsNotNull (p_at_id, p_nda => 3627));
        AddParam ('t3-7-1', Get_Ftr_Nt (p_at_id, p_nda => 3627));
        AddParam ('t3-7-2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 3627, p_chk => 'RC'));
        AddParam ('t3-7-3',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 3627, p_chk => 'OTHER'));
        AddParam ('t3', Get_Ftr_Nt (p_at_id, p_nda => 3628));
        --Потреби у професійному навчанні, перепідготовці: uss_ndi.V_DDN_SS_NEED_PROF_TRN
        AddParam ('60-1',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 3629, p_chk => 'PPT'));
        AddParam ('60-2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 3629, p_chk => 'PRT'));
        AddParam ('60-3',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 3629, p_chk => 'RTS'));
        AddParam ('60-4', Get_Ftr_Chk2 (p_at_id, p_nda => 3629, p_chk => 'CT'));
        AddParam ('61', Get_Ftr_Nt (p_at_id, p_nda => 3630));
        --інтегроване навчання
        l_str :=
            CASE
                WHEN    Api$Act_Rpt.Get_Ftr (p_at_id => p_at_id, p_nda => 3631)
                     || Api$Act_Rpt.Get_Ftr (p_at_id => p_at_id, p_nda => 3632)
                     || Api$Act_Rpt.Get_Ftr (p_at_id => p_at_id, p_nda => 3633)
                         IS NOT NULL
                THEN
                    'T'
            END;
        AddParam ('62-1', Api$Act_Rpt.chk_val2 (l_str, 'T'));
        AddParam ('62-2', Get_Ftr_Chk2 (p_at_id, p_nda => 3631));
        AddParam ('62-3', Get_Ftr_Chk2 (p_at_id, p_nda => 3632));
        AddParam ('62-4', Get_Ftr_Chk2 (p_at_id, p_nda => 3633));
        AddParam ('63', Get_Ftr_Chk2 (p_at_id, p_nda => 3634));
        AddParam ('64', Get_Ftr_Chk2 (p_at_id, p_nda => 3635));
        AddParam ('65-1', Get_Ftr_Chk2 (p_at_id, p_nda => 3636));
        AddParam ('65-2', Get_Ftr_Nt (p_at_id, p_nda => 3636));
        --Форми занять у процесі професійного навчання та на семінарах:
        AddParam ('66', Get_Ftr_Chk2 (p_at_id, p_nda => 3637));
        AddParam ('67-1', Get_Ftr_Chk2 (p_at_id, p_nda => 3638));
        AddParam ('67-2', Get_Ftr_Chk2 (p_at_id, p_nda => 3646));
        AddParam ('68-1', Get_Ftr_Chk2 (p_at_id, p_nda => 3647));
        AddParam ('68-2', Get_Ftr_Chk2 (p_at_id, p_nda => 3649));
        AddParam ('68-3', Get_Ftr_Chk2 (p_at_id, p_nda => 3650));
        AddParam ('69-1', Get_Ftr_Chk2 (p_at_id, p_nda => 3651));
        AddParam ('69-2', Get_Ftr_Chk2 (p_at_id, p_nda => 3655));
        AddParam ('70-1', Get_Ftr_Chk2 (p_at_id, p_nda => 3656));
        AddParam ('70-2', Get_Ftr_Nt (p_at_id, p_nda => 3656));
        AddParam ('71', Get_Ftr_Nt (p_at_id, p_nda => 3664));
        AddParam ('72', Get_Ftr_Nt (p_at_id, p_nda => 3666));
        AddParam ('73', Get_Ftr_Nt (p_at_id, p_nda => 3667));
        AddParam ('74', Get_Ftr_Nt (p_at_id, p_nda => 3675));

        --підписи
        AddParam ('sgn1', Api$Act_Rpt.GetPIB (p.pib));
        AddParam ('sgn2',
                  Api$Act_Rpt.GetPIB (get_signers_wucu_pib (p_at_id, 'PR')));

        AddParam (
            'sgn_mark',
            api$act_rpt.get_sign_mark (p_at_id,
                                       p.atp_id,
                                       '______________________'));
        ------------------------------------
        rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                         p_rpt_blob   => l_result);
        replace_ekr (l_result);

        RETURN l_result;
    END;

    --#94138 Карта визначення інд.потреб в наданні СП перекладу жестовою мовою
    FUNCTION ACT_DOC_879_R1 (p_at_id IN NUMBER)
        RETURN BLOB
    IS
        CURSOR c_at IS
            SELECT a.at_dt,
                   a.at_sc,
                   a.At_rnspm,
                   a.at_wu,
                   a.at_cu,
                   a.at_ap
              FROM act a
             WHERE a.at_id = p_at_id;

        c          c_at%ROWTYPE;

        l_str      VARCHAR2 (32000);
        l_bal      NUMBER;

        p          Api$Act_Rpt.R_Person_for_act;                   --отримувач

        l_jbr_id   NUMBER;
        l_result   BLOB;
    BEGIN
        rdm$rtfl_univ.initreport (p_code     => 'ACT_DOC_879_R1',
                                  p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);

        ------------------------------------
        OPEN c_at;

        FETCH c_at INTO c;

        CLOSE c_at;

        p :=
            get_AtPerson (p_at    => p_at_id,
                          p_atp   => get_AtPerson_id (p_at_id, 'OS'));

        AddParam (
            '1',
            Underline (Api$Act_Rpt.Get_Nsp_Name (p_rnspm_id => c.At_rnspm), 1)); --назва надавача
        AddParam ('2', Underline (Api$Act_Rpt.Date2Str (c.at_dt), 1));

        AddParam ('3', Underline (p.pib, 1));
        AddParam ('4', Underline (p.birth_dt_str, 1));
        AddParam (
            '5',
            Underline (
                p.live_address || NVL2 (p.phone, ', тел. ' || p.phone),
                1));
        AddParam ('6-1', Api$Act_Rpt.chk_val2 (p.sex, 'M'));           --стать
        AddParam ('6-2', Api$Act_Rpt.chk_val2 (p.sex, 'F'));
        --Правовий статус uss_ndi.V_DDN_SS_CAPABLE_2
        AddParam ('7-1', Get_Ftr_Chk2 (p_at_id, p_nda => 3982, p_chk => 'CP'));
        AddParam ('7-2', Get_Ftr_Chk2 (p_at_id, p_nda => 3982, p_chk => 'LCP'));
        AddParam ('7-3', Get_Ftr_Chk2 (p_at_id, p_nda => 3982, p_chk => 'NCP'));
        --Наявність групи інвалідності uss_ndi.V_DDN_SCY_GROUP
        l_str := Api$Act_Rpt.Get_Ftr (p_at_id => p_at_id, p_nda => 3983);
        AddParam (
            '8-1',
            Api$Act_Rpt.chk_val2 ('1', Api$Act_Rpt.is_disabled (l_str))); --так
        AddParam ('8-2', NVL (Api$Act_Rpt.DisabledGrp (l_str, 0), '______')); --група інв.
        AddParam (
            '8-3',
            Api$Act_Rpt.chk_val2 ('0', Api$Act_Rpt.is_disabled (l_str))); --ніт
        --Наявність технічних засобів реабілітації
        AddParam ('9-1', Get_Ftr_Chk2 (p_at_id, p_nda => 3984));
        AddParam ('9-2', Get_Ftr_Chk2 (p_at_id, p_nda => 3985));
        AddParam ('9-3', Get_Ftr_Chk2 (p_at_id, p_nda => 3986));
        AddParam ('9-4', Get_Ftr_Chk2 (p_at_id, p_nda => 3987));
        --володіння жестовою мовою uss_ndi.V_DDN_SS_LEVEL_SIGN_LNG
        AddParam ('10-1', Get_Ftr_Chk2 (p_at_id, p_nda => 3988, p_chk => 'O'));
        AddParam ('10-2', Get_Ftr_Chk2 (p_at_id, p_nda => 3988, p_chk => 'PO'));

        --II. Сім’я та оточення
        --Сімейний стан uss_ndi.V_DDN_SS_MARITAL_STT
        AddParam ('2.1-1', Get_Ftr_Chk2 (p_at_id, p_nda => 3989, p_chk => 'M'));
        AddParam ('2.1-2', Get_Ftr_Chk2 (p_at_id, p_nda => 3989, p_chk => 'W'));
        AddParam ('2.1-3', Get_Ftr_Chk2 (p_at_id, p_nda => 3989, p_chk => 'S'));
        AddParam ('2.1-4', Get_Ftr_Chk2 (p_at_id, p_nda => 3989, p_chk => 'D'));
        --Найближче оточення
        AddParam ('2.2-1', Get_Ftr_Chk2 (p_at_id, p_nda => 3990));
        AddParam ('2.2-2', Get_Ftr_Chk2 (p_at_id, p_nda => 3993));
        AddParam ('2.2-3', Get_Ftr_Chk2 (p_at_id, p_nda => 3994));

        AddParam ('2.3-1', Get_Ftr_Chk2 (p_at_id, p_nda => 3995));
        AddParam ('2.3-2', Get_Ftr_Chk2 (p_at_id, p_nda => 3995, p_chk => 'F'));

        --ІІІ. Види перекладу
        AddParam ('3.1-1', Get_Ftr_Chk2 (p_at_id, p_nda => 3996));
        AddParam ('3.1-2', Get_Ftr_Chk2 (p_at_id, p_nda => 3997));
        AddParam ('3.1-3', Get_Ftr_Chk2 (p_at_id, p_nda => 3998));
        AddParam ('3.2', Underline (Get_Ftr_Nt (p_at_id, p_nda => 8584), 1) /*Api$Act_Rpt.get_AtSctNt(p_at_id, p_nng => 409)*/
                                                                           ); --мовою(-ами) володіє

        --ІV. Оцінка потреби отримувача в соціальній послузі перекладу жестовою мовою
        --1. Ступінь індивідуальної потреби отримувача
        AddParam ('t1.1.1', Get_Ftr_Ind (p_at_id, p_nda => 3999));
        AddParam ('t1.1.2', Get_Ftr_Ind (p_at_id, p_nda => 4000));
        AddParam ('t1.2.1', Get_Ftr_Ind (p_at_id, p_nda => 4001));
        AddParam ('t1.2.2', Get_Ftr_Ind (p_at_id, p_nda => 4002));
        AddParam ('t1.2.3', Get_Ftr_Ind (p_at_id, p_nda => 4003));
        AddParam ('t1.3.1', Get_Ftr_Ind (p_at_id, p_nda => 4004));
        AddParam ('t1.3.2', Get_Ftr_Ind (p_at_id, p_nda => 4005));
        AddParam ('t1.3.3', Get_Ftr_Ind (p_at_id, p_nda => 4006));
        AddParam ('t1.4.1', Get_Ftr_Ind (p_at_id, p_nda => 4007));
        AddParam ('t1.4.2', Get_Ftr_Ind (p_at_id, p_nda => 4008));
        AddParam ('t1.4.3', Get_Ftr_Ind (p_at_id, p_nda => 4009));
        AddParam ('t1.5.1', Get_Ftr_Ind (p_at_id, p_nda => 4010));
        AddParam ('t1.5.2', Get_Ftr_Ind (p_at_id, p_nda => 4011));
        AddParam ('t1.5.3', Get_Ftr_Ind (p_at_id, p_nda => 4012));
        AddParam ('t1.6.1', Get_Ftr_Ind (p_at_id, p_nda => 4013));
        AddParam ('t1.6.2', Get_Ftr_Ind (p_at_id, p_nda => 4014));
        AddParam ('t1.6.3', Get_Ftr_Ind (p_at_id, p_nda => 4015));
        AddParam ('t1.7.1', Get_Ftr_Ind (p_at_id, p_nda => 4016));
        AddParam ('t1.7.2', Get_Ftr_Ind (p_at_id, p_nda => 4017));
        AddParam ('t1.8.1', Get_Ftr_Ind (p_at_id, p_nda => 4018));
        AddParam ('t1.8.2', Get_Ftr_Ind (p_at_id, p_nda => 4019));
        AddParam ('t1.9.1', Get_Ftr_Ind (p_at_id, p_nda => 4020));
        AddParam ('t1.9.2', Get_Ftr_Ind (p_at_id, p_nda => 4021));
        AddParam ('t1.9.3', Get_Ftr_Ind (p_at_id, p_nda => 4022));
        AddParam ('t1.10.1', Get_Ftr_Ind (p_at_id, p_nda => 4023));
        AddParam ('t1.10.2', Get_Ftr_Ind (p_at_id, p_nda => 4024));
        AddParam ('t1.11.1', Get_Ftr_Ind (p_at_id, p_nda => 4025));
        AddParam ('t1.11.2', Get_Ftr_Ind (p_at_id, p_nda => 4026));
        AddParam ('t1.11.3', Get_Ftr_Ind (p_at_id, p_nda => 4027));
        AddParam ('t1.11.4', Get_Ftr_Ind (p_at_id, p_nda => 4028));
        AddParam ('t1.12.1', Get_Ftr_Ind (p_at_id, p_nda => 4029));
        AddParam ('t1.12.2', Get_Ftr_Ind (p_at_id, p_nda => 4030));
        AddParam ('t1.12.3', Get_Ftr_Ind (p_at_id, p_nda => 4031));
        AddParam ('t1.12.4', Get_Ftr_Ind (p_at_id, p_nda => 4032));
        AddParam ('t1.13.1', Get_Ftr_Ind (p_at_id, p_nda => 4033));
        AddParam ('t1.13.2', Get_Ftr_Ind (p_at_id, p_nda => 4034));
        AddParam ('t1.13.3', Get_Ftr_Ind (p_at_id, p_nda => 4035));
        AddParam ('t1.13.4', Get_Ftr_Ind (p_at_id, p_nda => 4036));
        AddParam ('t1.14.1', Get_Ftr_Ind (p_at_id, p_nda => 4037));
        AddParam ('t1.14.2', Get_Ftr_Ind (p_at_id, p_nda => 4038));
        AddParam ('t1.14.3', Get_Ftr_Ind (p_at_id, p_nda => 4039));
        AddParam ('t1.14.4', Get_Ftr_Ind (p_at_id, p_nda => 4040));

        --ІV. Висновки
        l_bal :=
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 424).ate_indicator_value1;
        l_str :=
            CASE
                WHEN l_bal BETWEEN 10 AND 18 THEN 1
                WHEN l_bal BETWEEN 19 AND 36 THEN 2
                WHEN l_bal >= 37 THEN 3
            END;
        AddParam ('40-1', Api$Act_Rpt.chk_val2 (1, l_str)); --низький ступінь;
        AddParam ('40-2', Api$Act_Rpt.chk_val2 (2, l_str)); --помірний ступінь;
        AddParam ('40-3', Api$Act_Rpt.chk_val2 (3, l_str)); --високий ступінь.

        AddParam ('41', Underline (l_bal, 1));            -- усього #41# балів
        AddParam (
            '42',
            Underline (
                Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 371).ate_indicator_value2,
                1));                                 --в середньому #42# годин

        AddParam (
            'sgn1',
            Underline (Api$Act_Rpt.Get_IPr (Api$Act_Rpt.GetCuPIB (c.at_cu)),
                       1)); --Підпис працівника, який визначав індивідуальні потреби
        AddParam ('sgn2', Underline (Api$Act_Rpt.Get_IPr (p.pib), 1)); --Одержувач СП
        AddParam (
            'sgn3',
            Underline (
                   Get_Ftr_Nt (p_at_id, p_nda => 8586)
                || ' '
                || Get_Ftr_Nt (p_at_id, p_nda => 8585),
                1) /*Api$Act_Rpt.Get_IPr(get_signers_wucu_pib(p_at_id => p_at_id, p_ati_tp => 'PR'))*/
                  );                                       --Керівник надавача

        AddParam (
            'sgn_mark',
            api$act_rpt.get_sign_mark (p_at_id, p.Atp_Id, '________________'));

        ------------------------------------
        rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                         p_rpt_blob   => l_result);
        replace_ekr (l_result);

        RETURN l_result;
    END ACT_DOC_879_R1;

    --#94109 ОЦІНОЧНА ФОРМА ЗА РЕЗУЛЬТАТАМИ ІНФОРМАЦІЙНО-ОЦІНОЧНОЇ ЗУСТРІЧІ З МЕДІАТОРОМ
    FUNCTION ACT_DOC_868_R1 (p_at_id IN NUMBER)
        RETURN BLOB
    IS
        CURSOR c_at IS
            SELECT a.at_dt,
                   a.at_sc,
                   a.at_wu,
                   a.at_cu,
                   a.At_rnspm
              FROM act a
             WHERE a.at_id = p_at_id;

        c           c_at%ROWTYPE;

        p           Api$Act_Rpt.R_Person_for_act;

        --l_str    varchar2(32000);
        l_is_good   VARCHAR2 (10);
        l_jbr_id    NUMBER;
        l_result    BLOB;
    BEGIN
        rdm$rtfl_univ.initreport (p_code     => 'ACT_DOC_868_R1',
                                  p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);

        ------------------------------------
        OPEN c_at;

        FETCH c_at INTO c;

        CLOSE c_at;

        p :=
            get_AtPerson (p_at    => p_at_id,
                          p_atp   => get_AtPerson_id (p_at_id, 'OS'));

        AddParam ('01', '____________');                            --Справа №
        AddParam ('1', Api$Act_Rpt.Date2Str (c.at_dt));
        AddParam ('2', Api$Act_Rpt.Get_Nsp_Name (p_rnspm_id => c.At_rnspm)); --назва надавача
        AddParam (
            '3',
            LTRIM (
                   Get_Ftr_Nt (p_at_id, p_nda => 2817)
                || ', '
                || Get_Ftr_Nt (p_at_id, p_nda => 2818),
                ','));                                              --медіатор
        --І. Відомості про отримувача соціальної послуги
        AddParam ('4', p.pib);
        AddParam ('5', p.birth_dt_str);
        AddParam ('6', TRUNC (MONTHS_BETWEEN (SYSDATE, p.birth_dt) / 12));
        AddParam ('7', p.phone);
        AddParam ('8', p.live_address);
        AddParam ('9', p.email);
        --ІІ. Випадок класифіковано як  uss_ndi.V_DDN_CASE_CLASS
        AddParam ('10-1', Get_Ftr_Chk2 (p_at_id, p_nda => 2822, p_chk => 'SM'));
        AddParam ('10-2', Get_Ftr_Chk2 (p_at_id, p_nda => 2822, p_chk => 'MD'));
        AddParam ('10-3', Get_Ftr_Chk2 (p_at_id, p_nda => 2822, p_chk => 'DF'));
        AddParam ('10-4', Get_Ftr_Chk2 (p_at_id, p_nda => 2822, p_chk => 'EM'));

        AddParam ('11', Get_Ftr_Nt (p_at_id, p_nda => 2824));
        AddParam ('12', Get_Ftr_Nt (p_at_id, p_nda => 2825));
        --VI. ОЦІНКА МЕДІАБЕЛЬНОСТІ

        AddParam ('t1', Get_Ftr_Chk2 (p_at_id, p_nda => 2826));
        AddParam ('t1-1', Get_Ftr_Chk2 (p_at_id, p_nda => 2826, p_chk => 'F'));
        AddParam ('t2', Get_Ftr_Chk2 (p_at_id, p_nda => 2827));
        AddParam ('t2-1', Get_Ftr_Chk2 (p_at_id, p_nda => 2827, p_chk => 'F'));
        AddParam ('t3', Get_Ftr_Chk2 (p_at_id, p_nda => 2828));
        AddParam ('t3-1', Get_Ftr_Chk2 (p_at_id, p_nda => 2828, p_chk => 'F'));
        AddParam ('t4', Get_Ftr_Chk2 (p_at_id, p_nda => 3079));
        AddParam ('t4-1', Get_Ftr_Chk2 (p_at_id, p_nda => 3079, p_chk => 'F'));
        AddParam ('t5', Get_Ftr_Chk2 (p_at_id, p_nda => 2829));
        AddParam ('t5-1', Get_Ftr_Chk2 (p_at_id, p_nda => 2829, p_chk => 'F'));
        AddParam ('t6', Get_Ftr_Chk2 (p_at_id, p_nda => 2831));
        AddParam ('t6-1', Get_Ftr_Chk2 (p_at_id, p_nda => 2831, p_chk => 'F'));
        AddParam ('t7', Get_Ftr_Chk2 (p_at_id, p_nda => 2832));
        AddParam ('t7-1', Get_Ftr_Chk2 (p_at_id, p_nda => 2832, p_chk => 'F'));
        AddParam ('t8', Get_Ftr_Chk2 (p_at_id, p_nda => 2902));
        AddParam ('t8-1', Get_Ftr_Chk2 (p_at_id, p_nda => 2902, p_chk => 'F'));
        AddParam ('t9', Get_Ftr_Chk2 (p_at_id, p_nda => 2903));
        AddParam ('t9-1', Get_Ftr_Chk2 (p_at_id, p_nda => 2903, p_chk => 'F'));
        AddParam ('t10', Get_Ftr_Chk2 (p_at_id, p_nda => 2904));
        AddParam ('t10-1', Get_Ftr_Chk2 (p_at_id, p_nda => 2904, p_chk => 'F'));
        AddParam ('t11', Get_Ftr_Chk2 (p_at_id, p_nda => 2905));
        AddParam ('t11-1', Get_Ftr_Chk2 (p_at_id, p_nda => 2905, p_chk => 'F'));
        AddParam ('t12', Get_Ftr_Chk2 (p_at_id, p_nda => 2906));
        AddParam ('t12-1', Get_Ftr_Chk2 (p_at_id, p_nda => 2906, p_chk => 'F'));
        AddParam ('t13', Get_Ftr_Chk2 (p_at_id, p_nda => 2907));
        AddParam ('t13-1', Get_Ftr_Chk2 (p_at_id, p_nda => 2907, p_chk => 'F'));
        AddParam ('t14', Get_Ftr_Chk2 (p_at_id, p_nda => 2908));
        AddParam ('t14-1', Get_Ftr_Chk2 (p_at_id, p_nda => 2908, p_chk => 'F'));
        AddParam ('t15', Get_Ftr_Chk2 (p_at_id, p_nda => 2909));
        AddParam ('t15-1', Get_Ftr_Chk2 (p_at_id, p_nda => 2909, p_chk => 'F'));
        AddParam ('t16', Get_Ftr_Chk2 (p_at_id, p_nda => 2910));
        AddParam ('t16-1', Get_Ftr_Chk2 (p_at_id, p_nda => 2910, p_chk => 'F'));
        AddParam ('t17', Get_Ftr_Chk2 (p_at_id, p_nda => 2911));
        AddParam ('t17-1', Get_Ftr_Chk2 (p_at_id, p_nda => 2911, p_chk => 'F'));
        AddParam ('t18', Get_Ftr_Chk2 (p_at_id, p_nda => 2912));
        AddParam ('t18-1', Get_Ftr_Chk2 (p_at_id, p_nda => 2912, p_chk => 'F'));
        AddParam ('t19', Get_Ftr_Chk2 (p_at_id, p_nda => 2913));
        AddParam ('t19-1', Get_Ftr_Chk2 (p_at_id, p_nda => 2913, p_chk => 'F'));
        AddParam ('t20', Get_Ftr_Chk2 (p_at_id, p_nda => 2928));
        AddParam ('t20-1', Get_Ftr_Chk2 (p_at_id, p_nda => 2928, p_chk => 'F'));
        --Прошу залучити до медіації
        AddParam ('20', Get_Ftr_Nt (p_at_id, p_nda => 2929));
        --VІІ. Потреба в залученні медіатора uss_ndi.V_DDN_SS_NEED_MEDIATOR
        AddParam ('21-1',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 3067, p_chk => 'ONE'));
        AddParam ('21-2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 3067, p_chk => 'TWO'));
        AddParam ('21-3',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 3067, p_chk => 'R_ONE'));
        AddParam ('21-4',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 3067, p_chk => 'R_TWO'));
        --VІІІ. Висновки
        AddParam ('22-1', Get_Ftr_Chk2 (p_at_id, p_nda => 3069, p_chk => 'T'));
        AddParam ('22-2', Get_Ftr_Chk2 (p_at_id, p_nda => 3069, p_chk => 'F'));
        --Перешкод для участі в медіації uss_ndi.V_DDN_SS_OBSTCL_MEDIATION
        AddParam ('23-1', Get_Ftr_Chk2 (p_at_id, p_nda => 3070, p_chk => 'F'));
        AddParam ('23-2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 3070, p_chk => 'T_M'));
        AddParam ('23-3',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 3070, p_chk => 'T_R'));
        --Додаткові пояснення
        AddParam ('24', Get_Ftr_Nt (p_at_id, p_nda => 3075));

        --підписанти
        AddParam ('sgn1-1',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 2817, p_chk => 'T'));
        AddParam ('sgn1-2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 2817, p_chk => 'F'));
        AddParam ('sgn1-3', Get_Ftr_Nt (p_at_id, p_nda => 2817));

        AddParam ('sgn2-1',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 2818, p_chk => 'T'));
        AddParam ('sgn2-2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 2818, p_chk => 'F'));
        AddParam ('sgn2-3', Get_Ftr_Nt (p_at_id, p_nda => 2818));

        l_is_good := Get_Ftr (p_at_id => p_at_id, p_nda => 8521);

        IF (l_is_good = 'T')
        THEN
            AddParam (
                'sgn_mark_1',
                api$act_rpt.get_sign_mark (
                    p_at_id,
                    p.atp_id,
                    '_____________________________________'));
            AddParam ('sgn_mark_2', '_____________________________________');
        ELSE
            AddParam ('sgn_mark_1', '_____________________________________');
            AddParam (
                'sgn_mark_2',
                api$act_rpt.get_sign_mark (
                    p_at_id,
                    p.atp_id,
                    '_____________________________________'));
        END IF;

        ------------------------------------
        rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                         p_rpt_blob   => l_result);
        replace_ekr (l_result);

        RETURN l_result;
    END;


    --#94404 АКТ про результат візиту
    FUNCTION ACT_DOC_869_R1 (p_at_id IN NUMBER)
        RETURN BLOB
    IS
        CURSOR c_at IS
            SELECT a.at_dt,
                   a.at_sc,
                   a.at_wu,
                   a.at_cu
              FROM act a
             WHERE a.at_id = p_at_id;

        c          c_at%ROWTYPE;

        l_str      VARCHAR2 (32000);

        l_jbr_id   NUMBER;
        l_result   BLOB;
    BEGIN
        rdm$rtfl_univ.initreport (p_code     => 'ACT_DOC_869_R1',
                                  p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);

        ------------------------------------
        OPEN c_at;

        FETCH c_at INTO c;

        CLOSE c_at;

        addparam (
            'p1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 211).ate_parent_info);
        addparam ('p2', Api$Act_Rpt.Date2Str (c.at_dt));
        addparam ('p3', Get_Ftr_Nt (p_at_id, p_nda => 2836)); --центр соціальних служб
        addparam ('p4', Get_Ftr_Nt (p_at_id, p_nda => 2837));        --в особі
        addparam ('p5', Get_Ftr_Nt (p_at_id, p_nda => 2838)); --Представники інших закладів

        l_str :=
            q'[
    select
          row_number() over(order by birth_dt desc)||'.' c1,
          pib || nvl2(work_place, work_place||', ', null) || ', '||birth_dt_str||'p.' c2
    from table(uss_esr.Api$Act_Rpt.At_Person_for_act(:p_at_id)) t
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


        addparam ('p6', Get_Ftr_Nt (p_at_id, p_nda => 2839));
        addparam ('p7', Get_Ftr_Nt (p_at_id, p_nda => 2840));

        ------------------------------------
        rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                         p_rpt_blob   => l_result);
        replace_ekr (l_result);

        RETURN l_result;
    END;

    --#94122 013.0-882-КАРТА визначення індивідуальних потреб послуги соціальної адаптації
    FUNCTION ACT_DOC_882_R1 (p_at_id IN NUMBER)
        RETURN BLOB
    IS
        CURSOR c_at IS
            SELECT a.at_dt,
                   a.at_sc,
                   a.at_wu,
                   a.at_cu,
                   a.At_rnspm
              FROM act a
             WHERE a.at_id = p_at_id;

        c          c_at%ROWTYPE;

        p          Api$Act_Rpt.R_Person_for_act;                   --отримувач

        l_jbr_id   NUMBER;
        l_result   BLOB;
    BEGIN
        rdm$rtfl_univ.initreport (p_code     => 'ACT_DOC_882_R1',
                                  p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);

        ------------------------------------
        OPEN c_at;

        FETCH c_at INTO c;

        CLOSE c_at;

        p :=
            get_AtPerson (p_at    => p_at_id,
                          p_atp   => get_AtPerson_id (p_at_id, 'OS'));

        AddParam (
            '1',
            Underline (Api$Act_Rpt.Get_Nsp_Name (p_rnspm_id => c.At_rnspm), 1)); --назва надавача
        AddParam ('2', Underline (TO_CHAR (c.at_dt, 'dd.mm.yyyy'), 1));
        AddParam ('3', Underline (Get_Ftr_Nt (p_at_id, p_nda => 4408), 1));
        --І. Відомості про отримувача
        AddParam ('4', Underline (p.pib, 1));
        AddParam ('5-1', Api$Act_Rpt.chk_val2 (p.sex, 'M'));
        AddParam ('5-2', Api$Act_Rpt.chk_val2 (p.sex, 'F'));
        addparam ('6', Underline (p.birth_dt_str, 1));
        addparam (
            '7',
            Underline (
                p.Fact_Address || NVL2 (p.phone, ', тел. ' || p.phone),
                1));
        AddParam ('8', Underline (Get_Ftr_Nt (p_at_id, p_nda => 4409), 1));
        AddParam ('9', Underline (Get_Ftr_Nt (p_at_id, p_nda => 4410), 1));
        AddParam ('10', Underline (Get_Ftr_Nt (p_at_id, p_nda => 4411), 1));
        AddParam ('11', Underline (Get_Ftr_Nt (p_at_id, p_nda => 4412), 1));
        --ІІ. Соціальний статус
        AddParam ('12', Get_Ftr_Chk2 (p_at_id, p_nda => 4413));             --
        AddParam (
            '13',
            Api$Act_Rpt.chk_val2 (
                '1',
                Api$Act_Rpt.is_disabled (
                    Api$Act_Rpt.Get_Ftr (p_at_id, p_nda => 4414)))); --інвалід
        AddParam (
            '13-1',
            Underline (
                   Api$Act_Rpt.DisabledGrp (
                       Api$Act_Rpt.Get_Ftr (p_at_id, p_nda => 4414))
                || ', '
                || Get_Ftr_Nt (p_at_id, p_nda => 4414),
                1));
        AddParam ('14', Api$Act_Rpt.AtFtrNtIsNotNull (p_at_id, p_nda => 4415)); --інший
        AddParam ('14-1', Underline (Get_Ftr_Nt (p_at_id, p_nda => 4415), 1));
        --ІІІ. Сім’я та оточення uss_ndi.V_DDN_SS_MARITAL_SPCF
        AddParam ('15-1', Get_Ftr_Chk2 (p_at_id, p_nda => 4416, p_chk => 'M')); --одружений
        AddParam ('15-2', Get_Ftr_Chk2 (p_at_id, p_nda => 4416, p_chk => 'S')); --одинокий
        AddParam ('15-3', Get_Ftr_Chk2 (p_at_id, p_nda => 4416, p_chk => 'HR')); --має рідних
        AddParam ('15-4', Get_Ftr_Chk2 (p_at_id, p_nda => 4416, p_chk => 'LI')); --проживає самостійно
        AddParam ('15-5', Underline (Get_Ftr_Nt (p_at_id, p_nda => 4416), 1));
        AddParam ('16', Underline (Get_Ftr_Nt (p_at_id, p_nda => 4417), 1));
        --ІV. Соціальне функціонування
        AddParam ('17', Underline (Get_Ftr_Nt (p_at_id, p_nda => 4418), 1));
        AddParam ('18', Get_Ftr_Chk2 (p_at_id, p_nda => 4419));
        AddParam ('19', Underline (Get_Ftr_Nt (p_at_id, p_nda => 4419), 1));

        IF (Get_Ftr (p_at_id, p_nda => 4419) = 'T')
        THEN
            AddParam ('20-1',
                      Get_Ftr_Chk2 (p_at_id, p_nda => 4420, p_chk => 'T'));
            AddParam ('20-2',
                      Get_Ftr_Chk2 (p_at_id, p_nda => 4420, p_chk => 'F'));
        END IF;

        AddParam ('21', Underline (Get_Ftr_Nt (p_at_id, p_nda => 4421), 1));
        AddParam ('22', Underline (Get_Ftr_Nt (p_at_id, p_nda => 4493), 1));
        --V. Стан здоров’я та функціонування
        AddParam ('23', Underline (Get_Ftr_Nt (p_at_id, p_nda => 4422), 1));
        AddParam ('24', Underline (Get_Ftr_Nt (p_at_id, p_nda => 4423), 1));
        AddParam ('25', Underline (Get_Ftr_Nt (p_at_id, p_nda => 4424), 1));
        AddParam ('26-1', Get_Ftr_Chk2 (p_at_id, p_nda => 4425, p_chk => 'T'));
        AddParam ('26-2', Get_Ftr_Chk2 (p_at_id, p_nda => 4425, p_chk => 'F'));
        --Проблеми, що виникли в результаті захворювання
        AddParam ('27', Underline (Get_Ftr_Nt (p_at_id, p_nda => 4426), 1));
        AddParam ('28', Underline (Get_Ftr_Nt (p_at_id, p_nda => 4427), 1));
        AddParam ('29', Underline (Get_Ftr_Nt (p_at_id, p_nda => 4428), 1));
        AddParam ('30', Underline (Get_Ftr_Nt (p_at_id, p_nda => 4429), 1));
        AddParam ('31', Underline (Get_Ftr_Nt (p_at_id, p_nda => 4430), 1));
        AddParam ('32', Underline (Get_Ftr_Nt (p_at_id, p_nda => 4431), 1));
        AddParam ('33', Underline (Get_Ftr_Nt (p_at_id, p_nda => 4432), 1));
        AddParam ('34', Underline (Get_Ftr_Nt (p_at_id, p_nda => 4433), 1));
        AddParam ('35', Underline (Get_Ftr_Nt (p_at_id, p_nda => 4434), 1));
        --VІ. Потреби отримувача соціальної послуги
        AddParam ('36', Underline (Get_Ftr_Nt (p_at_id, p_nda => 4435), 1));
        AddParam ('37', Get_Ftr_Chk2 (p_at_id, p_nda => 4436));
        AddParam ('37-1', Underline (Get_Ftr_Nt (p_at_id, p_nda => 4436), 1));
        AddParam ('38', Get_Ftr_Chk2 (p_at_id, p_nda => 4437));
        AddParam ('38-1', Underline (Get_Ftr_Nt (p_at_id, p_nda => 4437), 1));
        AddParam ('39', Get_Ftr_Chk2 (p_at_id, p_nda => 4438));
        AddParam ('39-1', Underline (Get_Ftr_Nt (p_at_id, p_nda => 4438), 1));
        AddParam ('40', Get_Ftr_Chk2 (p_at_id, p_nda => 4439));
        AddParam ('40-1', Underline (Get_Ftr_Nt (p_at_id, p_nda => 4439), 1));
        AddParam ('41', Get_Ftr_Chk2 (p_at_id, p_nda => 4440));
        AddParam ('41-1', Underline (Get_Ftr_Nt (p_at_id, p_nda => 4440), 1));
        AddParam ('42', Get_Ftr_Chk2 (p_at_id, p_nda => 4441));
        AddParam ('42-1', Underline (Get_Ftr_Nt (p_at_id, p_nda => 4441), 1));
        AddParam ('43', Get_Ftr_Chk2 (p_at_id, p_nda => 4442));
        AddParam ('43-1', Underline (Get_Ftr_Nt (p_at_id, p_nda => 4442), 1));
        AddParam ('44', Get_Ftr_Chk2 (p_at_id, p_nda => 4443));
        AddParam ('44-1', Underline (Get_Ftr_Nt (p_at_id, p_nda => 4443), 1));
        AddParam ('45', Get_Ftr_Chk2 (p_at_id, p_nda => 4444));
        AddParam ('45-1', Underline (Get_Ftr_Nt (p_at_id, p_nda => 4444), 1));
        AddParam ('46', Get_Ftr_Chk2 (p_at_id, p_nda => 4445));
        AddParam ('46-1', Underline (Get_Ftr_Nt (p_at_id, p_nda => 4445), 1));
        AddParam ('47', Get_Ftr_Chk2 (p_at_id, p_nda => 4446));
        AddParam ('47-1', Underline (Get_Ftr_Nt (p_at_id, p_nda => 4446), 1));
        AddParam ('48', Get_Ftr_Chk2 (p_at_id, p_nda => 4447));
        AddParam ('48-1', Underline (Get_Ftr_Nt (p_at_id, p_nda => 4447), 1));
        AddParam ('49', Get_Ftr_Chk2 (p_at_id, p_nda => 4448));
        AddParam ('49-1', Underline (Get_Ftr_Nt (p_at_id, p_nda => 4448), 1));
        AddParam ('50', Get_Ftr_Chk2 (p_at_id, p_nda => 4449));
        AddParam ('50-1', Underline (Get_Ftr_Nt (p_at_id, p_nda => 4449), 1));
        --Потреба в реабілітаційному обладнанні/допоміжних засобах
        AddParam ('51', Underline (Get_Ftr_Nt (p_at_id, p_nda => 4450), 1));
        AddParam ('52', Underline (Get_Ftr_Nt (p_at_id, p_nda => 4451), 1));
        AddParam ('53', Underline (Get_Ftr_Nt (p_at_id, p_nda => 4452), 1));
        AddParam ('54', Underline (Get_Ftr_Nt (p_at_id, p_nda => 4453), 1));
        AddParam ('55', Underline (Get_Ftr_Nt (p_at_id, p_nda => 4454), 1));
        AddParam ('56', Underline (Get_Ftr_Nt (p_at_id, p_nda => 4455), 1));
        AddParam ('57', Underline (Get_Ftr_Nt (p_at_id, p_nda => 4456), 1));
        --підпис
        AddParam (
            'sgn1',
            Underline (Api$Act_Rpt.GetPIB (Api$Act_Rpt.GetCuPIB (c.at_cu)),
                       1));

        ------------------------------------
        rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                         p_rpt_blob   => l_result);
        replace_ekr (l_result);

        RETURN l_result;
    END;


    --#94123 Оцінка потреб особи, яка постраждала від торгівлі людьми
    FUNCTION ACT_DOC_885_R1 (p_at_id IN NUMBER)
        RETURN BLOB
    IS
        CURSOR c_at IS
            SELECT a.at_dt,
                   a.at_sc,
                   a.at_wu,
                   a.at_cu
              FROM act a
             WHERE a.at_id = p_at_id;

        c          c_at%ROWTYPE;

        p          Api$Act_Rpt.R_Person_for_act;                   --отримувач

        l_jbr_id   NUMBER;
        l_result   BLOB;
    BEGIN
        rdm$rtfl_univ.initreport (p_code     => 'ACT_DOC_885_R1',
                                  p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);

        ------------------------------------
        OPEN c_at;

        FETCH c_at INTO c;

        CLOSE c_at;

        p :=
            get_AtPerson (p_at    => p_at_id,
                          p_atp   => get_AtPerson_id (p_at_id, 'OS'));

        AddParam ('1', p.pib);
        AddParam ('2', Api$act.Get_At_Spec_Name (c.at_wu, c.at_cu));
        AddParam ('3', TO_CHAR (c.at_dt, 'dd.mm.yyyy'));

        AddParam ('t1', Get_Ftr_Chk2 (p_at_id, p_nda => 2528));
        AddParam ('t2', Get_Ftr_Chk2 (p_at_id, p_nda => 3676));
        AddParam ('t3', Get_Ftr_Chk2 (p_at_id, p_nda => 3677));
        AddParam ('t4', Get_Ftr_Chk2 (p_at_id, p_nda => 3678));
        AddParam ('t5', Get_Ftr_Chk2 (p_at_id, p_nda => 3681));
        AddParam ('t6', Get_Ftr_Chk2 (p_at_id, p_nda => 3682));
        AddParam ('t7', Get_Ftr_Chk2 (p_at_id, p_nda => 3694));
        AddParam ('t8', Get_Ftr_Chk2 (p_at_id, p_nda => 4406));

        AddParam ('sgn_mark',
                  api$act_rpt.get_sign_mark (p_at_id, p.Atp_Id, ''));
        ------------------------------------
        rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                         p_rpt_blob   => l_result);
        replace_ekr (l_result);

        RETURN l_result;
    END ACT_DOC_885_R1;

    --#94123 Оцінка потреб отримувача соціальної послуги соціальної інтеграції та рівня його готовності до самостійного життя (комплексна оцінка)
    FUNCTION ACT_DOC_886_R1 (p_at_id IN NUMBER)
        RETURN BLOB
    IS
        CURSOR c_at IS
            SELECT a.at_dt,
                   a.at_sc,
                   a.at_wu,
                   a.at_cu,
                   a.At_rnspm,
                   a.at_action_start_dt,
                   a.at_action_stop_dt,
                   NVL (TO_CHAR (a.at_action_stop_dt, 'dd.mm.yyyy'),
                        '__________')    sgn_dt
              FROM act a
             WHERE a.at_id = p_at_id;

        c          c_at%ROWTYPE;

        l_str      VARCHAR2 (32000);

        CURSOR c_rnspm (p_rnspm NUMBER)
        IS
            SELECT t.rnspa_kaot,
                   t.rnspa_index,
                   t.rnspa_street,
                   t.rnspa_building,
                   t.rnspa_korp,
                   t.rnspa_appartement
              FROM Uss_Rnsp.v_Rnsp t
             WHERE t.rnspm_id = p_rnspm;

        r_rnspm    c_rnspm%ROWTYPE;

        p          Api$Act_Rpt.R_Person_for_act;                   --отримувач
        p2         Api$Act_Rpt.R_Person_for_act; --працівник, який проводив оцінювання

        l_jbr_id   NUMBER;
        l_result   BLOB;

        PROCEDURE AddFtrChk (p_Param_Name   VARCHAR2,
                             p_nda          NUMBER,
                             p_chk          VARCHAR2:= 'T')
        IS
        BEGIN
            AddParam (
                p_Param_Name,
                Get_Ftr_Chk2 (p_at_id   => p_at_id,
                              p_nda     => p_nda,
                              p_chk     => p_chk));
        END AddFtrChk;

        PROCEDURE AddFtrNft (p_Param_Name VARCHAR2, p_nda NUMBER)
        IS
        BEGIN
            AddParam (p_Param_Name,
                      Get_Ftr_Nt (p_at_id => p_at_id, p_nda => p_nda));
        END AddFtrNft;
    BEGIN
        rdm$rtfl_univ.initreport (p_code     => 'ACT_DOC_886_R1',
                                  p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);

        ------------------------------------
        OPEN c_at;

        FETCH c_at INTO c;

        CLOSE c_at;

        p :=
            get_AtPerson (p_at    => p_at_id,
                          p_atp   => get_AtPerson_id (p_at_id, 'OS'));
        p2 :=
            get_AtPerson (p_at    => p_at_id,
                          p_atp   => get_AtPerson_id (p_at_id, 'AP', 1));

        OPEN c_rnspm (c.at_rnspm);

        FETCH c_rnspm INTO r_rnspm;

        CLOSE c_rnspm;

        l_str := Api$Act_Rpt.get_katottg_info (r_rnspm.rnspa_kaot);
        l_str :=
            Api$Act_Rpt.Get_adr (p_ind     => r_rnspm.rnspa_index,
                                 p_katot   => l_str,
                                 p_strit   => r_rnspm.rnspa_street,
                                 p_bild    => r_rnspm.rnspa_building,
                                 p_korp    => r_rnspm.rnspa_korp,
                                 p_kv      => r_rnspm.rnspa_appartement);

        AddParam (
            '1',
               Api$Act_Rpt.Get_Nsp_Name (p_rnspm_id => c.At_rnspm)
            || NVL2 (l_str, ', адреса ' || l_str));                     --надавач СП
        AddParam ('2', p2.pib || ', ' || p2.work_place);
        AddParam ('3', p2.phone);
        addparam (
            '4',
            NVL (TO_CHAR (c.at_action_start_dt, 'dd.mm.yyyy'), c_date_empty)); --Початок
        addparam (
            '5',
            NVL (TO_CHAR (c.at_action_stop_dt, 'dd.mm.yyyy'), c_date_empty));

        --І. Загальна інформація про отримувача
        AddParam ('6', p.pib);
        AddParam ('7', p.birth_dt_str);
        AddParam ('8', p.phone);
        AddParam ('9', p.live_address);
        AddParam ('10', Get_Ftr_Nt (p_at_id, p_nda => 4496));
        AddParam ('11', Get_Ftr_Nt (p_at_id, p_nda => 4497));
        AddParam ('12', p.work_place);

        --ІІ. Визначення основних пріоритетів розвитку
        AddParam ('t2-1', Get_Ftr_Nt (p_at_id, p_nda => 4498));
        AddParam ('t2-2', Get_Ftr_Nt (p_at_id, p_nda => 4499));
        AddParam ('t2-3', Get_Ftr_Nt (p_at_id, p_nda => 4500));
        AddParam ('t2-4', Get_Ftr_Nt (p_at_id, p_nda => 4501));

        --ІІІ. Потреби отримувача соціальної послуги соціальної інтеграції для розвитку
        --Показник 3.1. Стан здоров’я та навички здорового способу життя
        AddFtrChk ('t3-1', 4502);
        AddFtrChk ('t3-1-1', 4502, 'F');
        AddFtrNft ('t3-1-2', 4502);
        AddFtrChk ('t3-2', 4503);
        AddFtrChk ('t3-2-1', 4503, 'F');
        AddFtrNft ('t3-2-2', 4503);
        AddFtrChk ('t3-3', 4504);
        AddFtrChk ('t3-3-1', 4504, 'F');
        AddFtrNft ('t3-3-2', 4504);
        AddFtrChk ('t3-4', 4505);
        AddFtrChk ('t3-4-1', 4505, 'F');
        AddFtrNft ('t3-4-2', 4505);
        AddFtrChk ('t3-5', 4506);
        AddFtrChk ('t3-5-1', 4506, 'F');
        AddFtrNft ('t3-5-2', 4506);
        AddFtrChk ('t3-6', 4507);
        AddFtrChk ('t3-6-1', 4507, 'F');
        AddFtrNft ('t3-6-2', 4507);
        AddFtrChk ('t3-7', 4508);
        AddFtrChk ('t3-7-1', 4508, 'F');
        AddFtrNft ('t3-7-2', 4508);
        AddFtrChk ('t3-8', 4509);
        AddFtrChk ('t3-8-1', 4509, 'F');
        AddFtrNft ('t3-8-2', 4509);
        AddFtrChk ('t3-9', 4510);
        AddFtrChk ('t3-9-1', 4510, 'F');
        AddFtrNft ('t3-9-2', 4510);
        AddFtrChk ('t3-10', 4511);
        AddFtrChk ('t3-10-1', 4511, 'F');
        AddFtrNft ('t3-10-2', 4511);
        AddFtrChk ('t3-11', 4512);
        AddFtrChk ('t3-11-1', 4512, 'F');
        AddFtrNft ('t3-11-2', 4512);
        AddFtrChk ('t3-12', 4513);
        AddFtrChk ('t3-12-1', 4513, 'F');
        AddFtrNft ('t3-12-2', 4513);
        AddFtrChk ('t3-13', 4514);
        AddFtrChk ('t3-13-1', 4514, 'F');
        AddFtrNft ('t3-13-2', 4514);
        AddFtrChk ('t3-14', 4515);
        AddFtrChk ('t3-14-1', 4515, 'F');
        AddFtrNft ('t3-14-2', 4515);
        AddFtrChk ('t3-15', 4516);
        AddFtrChk ('t3-15-1', 4516, 'F');
        AddFtrNft ('t3-15-2', 4516);
        AddFtrChk ('t3-16', 4517);
        AddFtrChk ('t3-16-1', 4517, 'F');
        AddFtrNft ('t3-16-2', 4517);
        AddFtrChk ('t3-17', 4518);
        AddFtrChk ('t3-17-1', 4518, 'F');
        AddFtrNft ('t3-17-2', 4518);
        AddFtrChk ('t3-18', 4519);
        AddFtrChk ('t3-18-1', 4519, 'F');
        AddFtrNft ('t3-18-2', 4519);
        AddFtrChk ('t3-19', 4520);
        AddFtrChk ('t3-19-1', 4520, 'F');
        AddFtrNft ('t3-19-2', 4520);
        AddParam ('t3', Api$Act_Rpt.get_AtSctNt (p_at_id, p_nng => 228));
        --Показник 3.2. Навчання і досягнення
        AddFtrChk ('t32-1', 4521);
        AddFtrChk ('t32-1-1', 4521, 'F');
        AddFtrNft ('t32-1-2', 4521);
        AddFtrChk ('t32-2', 4522);
        AddFtrChk ('t32-2-1', 4522, 'F');
        AddFtrNft ('t32-2-2', 4522);
        AddFtrChk ('t32-3', 4523);
        AddFtrChk ('t32-3-1', 4523, 'F');
        AddFtrNft ('t32-3-2', 4523);
        AddFtrChk ('t32-4', 4524);
        AddFtrChk ('t32-4-1', 4524, 'F');
        AddFtrNft ('t32-4-2', 4524);
        AddFtrChk ('t32-5', 4525);
        AddFtrChk ('t32-5-1', 4525, 'F');
        AddFtrNft ('t32-5-2', 4525);
        AddFtrChk ('t32-6', 4526);
        AddFtrChk ('t32-6-1', 4526, 'F');
        AddFtrNft ('t32-6-2', 4526);
        AddFtrChk ('t32-7', 4527);
        AddFtrChk ('t32-7-1', 4527, 'F');
        AddFtrNft ('t32-7-2', 4527);
        AddFtrChk ('t32-8', 4528);
        AddFtrChk ('t32-8-1', 4528, 'F');
        AddFtrNft ('t32-8-2', 4528);
        AddFtrChk ('t32-9', 4529);
        AddFtrChk ('t32-9-1', 4529, 'F');
        AddFtrNft ('t32-9-2', 4529);
        AddFtrChk ('t32-10', 4530);
        AddFtrChk ('t32-10-1', 4530, 'F');
        AddFtrNft ('t32-10-2', 4530);
        AddFtrChk ('t32-11', 4531);
        AddFtrChk ('t32-11-1', 4531, 'F');
        AddFtrNft ('t32-11-2', 4531);
        AddFtrChk ('t32-12', 4532);
        AddFtrChk ('t32-12-1', 4532, 'F');
        AddFtrNft ('t32-12-2', 4532);
        AddFtrChk ('t32-13', 4533);
        AddFtrChk ('t32-13-1', 4533, 'F');
        AddFtrNft ('t32-13-2', 4533);
        AddFtrChk ('t32-14', 4534);
        AddFtrChk ('t32-14-1', 4534, 'F');
        AddFtrNft ('t32-14-2', 4534);
        AddParam ('t32', Api$Act_Rpt.get_AtSctNt (p_at_id, p_nng => 229));
        --Показник 3.3. Емоційний стан і навички саморегуляції
        AddFtrChk ('t33-1', 4535);
        AddFtrChk ('t33-1-1', 4535, 'F');
        AddFtrNft ('t33-1-2', 4535);
        AddFtrChk ('t33-2', 4536);
        AddFtrChk ('t33-2-1', 4536, 'F');
        AddFtrNft ('t33-2-2', 4536);
        AddFtrChk ('t33-3', 4537);
        AddFtrChk ('t33-3-1', 4537, 'F');
        AddFtrNft ('t33-3-2', 4537);
        AddFtrChk ('t33-4', 4538);
        AddFtrChk ('t33-4-1', 4538, 'F');
        AddFtrNft ('t33-4-2', 4538);
        AddFtrChk ('t33-5', 4539);
        AddFtrChk ('t33-5-1', 4539, 'F');
        AddFtrNft ('t33-5-2', 4539);
        AddFtrChk ('t33-6', 4540);
        AddFtrChk ('t33-6-1', 4540, 'F');
        AddFtrNft ('t33-6-2', 4540);
        AddFtrChk ('t33-7', 4541);
        AddFtrChk ('t33-7-1', 4541, 'F');
        AddFtrNft ('t33-7-2', 4541);
        AddFtrChk ('t33-8', 4542);
        AddFtrChk ('t33-8-1', 4542, 'F');
        AddFtrNft ('t33-8-2', 4542);
        AddFtrChk ('t33-9', 4543);
        AddFtrChk ('t33-9-1', 4543, 'F');
        AddFtrNft ('t33-9-2', 4543);
        AddParam ('t33', Api$Act_Rpt.get_AtSctNt (p_at_id, p_nng => 230));
        --Показник 3.4. Самоусвідомлення та соціальна презентація
        AddFtrChk ('t34-1', 4544);
        AddFtrChk ('t34-1-1', 4544, 'F');
        AddFtrNft ('t34-1-2', 4544);
        AddFtrChk ('t34-2', 4545);
        AddFtrChk ('t34-2-1', 4545, 'F');
        AddFtrNft ('t34-2-2', 4545);
        AddFtrChk ('t34-3', 4546);
        AddFtrChk ('t34-3-1', 4546, 'F');
        AddFtrNft ('t34-3-2', 4546);
        AddFtrChk ('t34-4', 4547);
        AddFtrChk ('t34-4-1', 4547, 'F');
        AddFtrNft ('t34-4-2', 4547);
        AddFtrChk ('t34-5', 4548);
        AddFtrChk ('t34-5-1', 4548, 'F');
        AddFtrNft ('t34-5-2', 4548);
        AddFtrChk ('t34-6', 4549);
        AddFtrChk ('t34-6-1', 4549, 'F');
        AddFtrNft ('t34-6-2', 4549);
        AddFtrChk ('t34-7', 4550);
        AddFtrChk ('t34-7-1', 4550, 'F');
        AddFtrNft ('t34-7-2', 4550);
        AddFtrChk ('t34-8', 4551);
        AddFtrChk ('t34-8-1', 4551, 'F');
        AddFtrNft ('t34-8-2', 4551);
        AddFtrChk ('t34-9', 4552);
        AddFtrChk ('t34-9-1', 4552, 'F');
        AddFtrNft ('t34-9-2', 4552);
        AddFtrChk ('t34-10', 4553);
        AddFtrChk ('t34-10-1', 4553, 'F');
        AddFtrNft ('t34-10-2', 4553);
        AddFtrChk ('t34-11', 4554);
        AddFtrChk ('t34-11-1', 4554, 'F');
        AddFtrNft ('t34-11-2', 4554);
        AddFtrChk ('t34-12', 4555);
        AddFtrChk ('t34-12-1', 4555, 'F');
        AddFtrNft ('t34-12-2', 4555);
        AddFtrChk ('t34-13', 4556);
        AddFtrChk ('t34-13-1', 4556, 'F');
        AddFtrNft ('t34-13-2', 4556);
        AddFtrChk ('t34-14', 4557);
        AddFtrChk ('t34-14-1', 4557, 'F');
        AddFtrNft ('t34-14-2', 4557);
        AddFtrChk ('t34-15', 4558);
        AddFtrChk ('t34-15-1', 4558, 'F');
        AddFtrNft ('t34-15-2', 4558);
        AddFtrChk ('t34-16', 4559);
        AddFtrChk ('t34-16-1', 4559, 'F');
        AddFtrNft ('t34-16-2', 4559);
        AddParam ('t34', Api$Act_Rpt.get_AtSctNt (p_at_id, p_nng => 231));
        --Показник 3.5. Сімейні та соціальні стосунки
        AddFtrChk ('t35-1', 4560);
        AddFtrChk ('t35-1-1', 4560, 'F');
        AddFtrNft ('t35-1-2', 4560);
        AddFtrChk ('t35-2', 4561);
        AddFtrChk ('t35-2-1', 4561, 'F');
        AddFtrNft ('t35-2-2', 4561);
        AddFtrChk ('t35-3', 4562);
        AddFtrChk ('t35-3-1', 4562, 'F');
        AddFtrNft ('t35-3-2', 4562);
        AddFtrChk ('t35-4', 4563);
        AddFtrChk ('t35-4-1', 4563, 'F');
        AddFtrNft ('t35-4-2', 4563);
        AddFtrChk ('t35-5', 4564);
        AddFtrChk ('t35-5-1', 4564, 'F');
        AddFtrNft ('t35-5-2', 4564);
        AddFtrChk ('t35-6', 4565);
        AddFtrChk ('t35-6-1', 4565, 'F');
        AddFtrNft ('t35-6-2', 4565);
        AddFtrChk ('t35-7', 4566);
        AddFtrChk ('t35-7-1', 4566, 'F');
        AddFtrNft ('t35-7-2', 4566);
        AddFtrChk ('t35-8', 4567);
        AddFtrChk ('t35-8-1', 4567, 'F');
        AddFtrNft ('t35-8-2', 4567);
        AddFtrChk ('t35-9', 4568);
        AddFtrChk ('t35-9-1', 4568, 'F');
        AddFtrNft ('t35-9-2', 4568);
        AddFtrChk ('t35-10', 4569);
        AddFtrChk ('t35-10-1', 4569, 'F');
        AddFtrNft ('t35-10-2', 4569);
        AddFtrChk ('t35-11', 4570);
        AddFtrChk ('t35-11-1', 4570, 'F');
        AddFtrNft ('t35-11-2', 4570);
        AddFtrChk ('t35-12', 4571);
        AddFtrChk ('t35-12-1', 4571, 'F');
        AddFtrNft ('t35-12-2', 4571);
        AddFtrChk ('t35-13', 4572);
        AddFtrChk ('t35-13-1', 4572, 'F');
        AddFtrNft ('t35-13-2', 4572);
        AddParam ('t35', Api$Act_Rpt.get_AtSctNt (p_at_id, p_nng => 232));
        --Показник 3.6. Навички самообслуговування та ведення домашнього господарства
        --Фінансовий стан отримувача соціальної послуги та навички планування бюджету
        AddFtrChk ('t36-1', 4573);
        AddFtrChk ('t36-1-1', 4573, 'F');
        AddFtrNft ('t36-1-2', 4573);
        AddFtrChk ('t36-2', 4574);
        AddFtrChk ('t36-2-1', 4574, 'F');
        AddFtrNft ('t36-2-2', 4574);
        AddFtrChk ('t36-3', 4575);
        AddFtrChk ('t36-3-1', 4575, 'F');
        AddFtrNft ('t36-3-2', 4575);
        AddFtrChk ('t36-4', 4576);
        AddFtrChk ('t36-4-1', 4576, 'F');
        AddFtrNft ('t36-4-2', 4576);
        AddFtrChk ('t36-5', 4577);
        AddFtrChk ('t36-5-1', 4577, 'F');
        AddFtrNft ('t36-5-2', 4577);
        AddFtrChk ('t36-6', 4578);
        AddFtrChk ('t36-6-1', 4578, 'F');
        AddFtrNft ('t36-6-2', 4578);
        AddFtrChk ('t36-7', 4579);
        AddFtrChk ('t36-7-1', 4579, 'F');
        AddFtrNft ('t36-7-2', 4579);
        AddFtrChk ('t36-8', 4580);
        AddFtrChk ('t36-8-1', 4580, 'F');
        AddFtrNft ('t36-8-2', 4580);
        AddFtrChk ('t36-9', 4581);
        AddFtrChk ('t36-9-1', 4581, 'F');
        AddFtrNft ('t36-9-2', 4581);
        AddFtrChk ('t36-10', 4582);
        AddFtrChk ('t36-10-1', 4582, 'F');
        AddFtrNft ('t36-10-2', 4582);
        AddFtrChk ('t36-11', 4583);
        AddFtrChk ('t36-11-1', 4583, 'F');
        AddFtrNft ('t36-11-2', 4583);
        AddFtrChk ('t36-12', 4584);
        AddFtrChk ('t36-12-1', 4584, 'F');
        AddFtrNft ('t36-12-2', 4584);
        AddFtrChk ('t36-13', 4585);
        AddFtrChk ('t36-13-1', 4585, 'F');
        AddFtrNft ('t36-13-2', 4585);
        AddFtrChk ('t36-14', 4586);
        AddFtrChk ('t36-14-1', 4586, 'F');
        AddFtrNft ('t36-14-2', 4586);
        AddFtrChk ('t36-15', 4587);
        AddFtrChk ('t36-15-1', 4587, 'F');
        AddFtrNft ('t36-15-2', 4587);
        AddFtrChk ('t36-16', 4588);
        AddFtrChk ('t36-16-1', 4588, 'F');
        AddFtrNft ('t36-16-2', 4588);
        AddFtrChk ('t36-17', 4589);
        AddFtrChk ('t36-17-1', 4589, 'F');
        AddFtrNft ('t36-17-2', 4589);
        AddFtrChk ('t36-18', 4590);
        AddFtrChk ('t36-18-1', 4590, 'F');
        AddFtrNft ('t36-18-2', 4590);
        --Навички догляду за собою
        AddFtrChk ('t36-20', 4591);
        AddFtrChk ('t36-20-1', 4591, 'F');
        AddFtrNft ('t36-20-2', 4591);
        AddFtrChk ('t36-21', 4592);
        AddFtrChk ('t36-21-1', 4592, 'F');
        AddFtrNft ('t36-21-2', 4592);
        AddFtrChk ('t36-22', 4593);
        AddFtrChk ('t36-22-1', 4593, 'F');
        AddFtrNft ('t36-22-2', 4593);
        AddFtrChk ('t36-23', 4594);
        AddFtrChk ('t36-23-1', 4594, 'F');
        AddFtrNft ('t36-23-2', 4594);
        AddFtrChk ('t36-24', 4595);
        AddFtrChk ('t36-24-1', 4595, 'F');
        AddFtrNft ('t36-24-2', 4595);
        AddFtrChk ('t36-25', 4596);
        AddFtrChk ('t36-25-1', 4596, 'F');
        AddFtrNft ('t36-25-2', 4596);
        AddFtrChk ('t36-26', 4597);
        AddFtrChk ('t36-26-1', 4597, 'F');
        AddFtrNft ('t36-26-2', 4597);
        AddFtrChk ('t36-27', 4598);
        AddFtrChk ('t36-27-1', 4598, 'F');
        AddFtrNft ('t36-27-2', 4598);
        --Навички приготування їжі
        AddFtrChk ('t36-29', 4599);
        AddFtrChk ('t36-29-1', 4599, 'F');
        AddFtrNft ('t36-29-2', 4599);
        AddFtrChk ('t36-30', 4600);
        AddFtrChk ('t36-30-1', 4600, 'F');
        AddFtrNft ('t36-30-2', 4600);
        AddFtrChk ('t36-31', 4601);
        AddFtrChk ('t36-31-1', 4601, 'F');
        AddFtrNft ('t36-31-2', 4601);
        AddFtrChk ('t36-32', 4602);
        AddFtrChk ('t36-32-1', 4602, 'F');
        AddFtrNft ('t36-32-2', 4602);
        AddFtrChk ('t36-33', 4603);
        AddFtrChk ('t36-33-1', 4603, 'F');
        AddFtrNft ('t36-33-2', 4603);
        AddFtrChk ('t36-34', 4604);
        AddFtrChk ('t36-34-1', 4604, 'F');
        AddFtrNft ('t36-34-2', 4604);
        AddFtrChk ('t36-36', 4605);
        AddFtrChk ('t36-36-1', 4605, 'F');
        AddFtrNft ('t36-36-2', 4605);
        --Оплата рахунків за комунальні послуги
        AddFtrChk ('t36-37', 4606);
        AddFtrChk ('t36-37-1', 4606, 'F');
        AddFtrNft ('t36-37-2', 4606);
        AddFtrChk ('t36-38', 4607);
        AddFtrChk ('t36-38-1', 4607, 'F');
        AddFtrNft ('t36-38-2', 4607);
        AddFtrChk ('t36-39', 4608);
        AddFtrChk ('t36-39-1', 4608, 'F');
        AddFtrNft ('t36-39-2', 4608);
        --Навички самопредставництва та пошуку ресурсів
        AddFtrChk ('t36-41', 4609);
        AddFtrChk ('t36-41-1', 4609, 'F');
        AddFtrNft ('t36-41-2', 4609);
        AddFtrChk ('t36-42', 4610);
        AddFtrChk ('t36-42-1', 4610, 'F');
        AddFtrNft ('t36-42-2', 4610);
        AddFtrChk ('t36-43', 4611);
        AddFtrChk ('t36-43-1', 4611, 'F');
        AddFtrNft ('t36-43-2', 4611);
        AddFtrChk ('t36-44', 4612);
        AddFtrChk ('t36-44-1', 4612, 'F');
        AddFtrNft ('t36-44-2', 4612);
        AddFtrChk ('t36-45', 4613);
        AddFtrChk ('t36-45-1', 4613, 'F');
        AddFtrNft ('t36-45-2', 4613);
        --Звернення до надавача соціальної послуги соціальної інтеграції
        AddFtrChk ('t36-47', 4614);
        AddFtrChk ('t36-47-1', 4614, 'F');
        AddFtrNft ('t36-47-2', 4614);
        AddFtrChk ('t36-48', 4615);
        AddFtrChk ('t36-48-1', 4615, 'F');
        AddFtrNft ('t36-48-2', 4615);
        AddFtrChk ('t36-49', 4616);
        AddFtrChk ('t36-49-1', 4616, 'F');
        AddFtrNft ('t36-49-2', 4616);
        AddFtrChk ('t36-50', 4617);
        AddFtrChk ('t36-50-1', 4617, 'F');
        AddFtrNft ('t36-50-2', 4617);
        AddParam ('t36', Api$Act_Rpt.get_AtSctNt (p_at_id, p_nng => 233));

        --ІV. Батьківський потенціал
        AddFtrNft ('40', 5552); --Прізвище, ім’я, по батькові особи з цільової групи
        AddFtrNft ('41', 5554);                                    --Категорія
        --Показник 4.1. Елементарний догляд
        AddFtrChk ('t4-1', 4618);
        AddFtrChk ('t4-1-1', 4618, 'F');
        AddFtrNft ('t4-1-2', 4618);
        AddFtrChk ('t4-2', 4619);
        AddFtrChk ('t4-2-1', 4619, 'F');
        AddFtrNft ('t4-2-2', 4619);
        AddFtrChk ('t4-3', 4620);
        AddFtrChk ('t4-3-1', 4620, 'F');
        AddFtrNft ('t4-3-2', 4620);
        AddFtrChk ('t4-4', 4621);
        AddFtrChk ('t4-4-1', 4621, 'F');
        AddFtrNft ('t4-4-2', 4621);
        AddParam ('t4', Api$Act_Rpt.get_AtSctNt (p_at_id, p_nng => 234));
        --Показник 4.2. Гарантія безпеки
        AddFtrChk ('t42-1', 4622);
        AddFtrChk ('t42-1-1', 4622, 'F');
        AddFtrNft ('t42-1-2', 4622);
        AddFtrChk ('t42-2', 4623);
        AddFtrChk ('t42-2-1', 4623, 'F');
        AddFtrNft ('t42-2-2', 4623);
        AddFtrChk ('t42-3', 4624);
        AddFtrChk ('t42-3-1', 4624, 'F');
        AddFtrNft ('t42-3-2', 4624);
        AddFtrChk ('t42-4', 4625);
        AddFtrChk ('t42-4-1', 4625, 'F');
        AddFtrNft ('t42-4-2', 4625);
        AddFtrChk ('t42-5', 4626);
        AddFtrChk ('t42-5-1', 4626, 'F');
        AddFtrNft ('t42-5-2', 4626);
        AddFtrChk ('t42-6', 4627);
        AddFtrChk ('t42-6-1', 4627, 'F');
        AddFtrNft ('t42-6-2', 4627);
        AddParam ('t42', Api$Act_Rpt.get_AtSctNt (p_at_id, p_nng => 235));

        --V. Фактори сім’ї та середовища
        AddFtrNft ('50', 5553); --тут якийсь незрозумілий компонент треба вивести...
        --Показник 5.1. Історія сім’ї
        AddFtrChk ('t5-1', 4628);
        AddFtrChk ('t5-1-1', 4628, 'F');
        AddFtrNft ('t5-1-2', 4628);
        AddFtrChk ('t5-2', 4629);
        AddFtrChk ('t5-2-1', 4629, 'F');
        AddFtrNft ('t5-2-2', 4629);
        AddFtrChk ('t5-3', 4630);
        AddFtrChk ('t5-3-1', 4630, 'F');
        AddFtrNft ('t5-3-2', 4630);
        AddFtrChk ('t5-4', 4631);
        AddFtrChk ('t5-4-1', 4631, 'F');
        AddFtrNft ('t5-4-2', 4631);
        AddFtrChk ('t5-5', 4632);
        AddFtrChk ('t5-5-1', 4632, 'F');
        AddFtrNft ('t5-5-2', 4632);
        AddFtrChk ('t5-6', 4633);
        AddFtrChk ('t5-6-1', 4633, 'F');
        AddFtrNft ('t5-6-2', 4633);
        AddFtrChk ('t5-7', 4634);
        AddFtrChk ('t5-7-1', 4634, 'F');
        AddFtrNft ('t5-7-2', 4634);
        AddFtrChk ('t5-8', 4635);
        AddFtrChk ('t5-8-1', 4635, 'F');
        AddFtrNft ('t5-8-2', 4635);
        AddFtrChk ('t5-9', 4636);
        AddFtrChk ('t5-9-1', 4636, 'F');
        AddFtrNft ('t5-9-2', 4636);
        AddParam ('t4', Api$Act_Rpt.get_AtSctNt (p_at_id, p_nng => 236));
        --Показник 5.2. Функціонування сім’ї
        AddFtrNft ('t52-1', 4637);
        AddFtrNft ('t52-2', 4638);
        AddFtrNft ('t52-3', 4639);
        AddFtrNft ('t52-4', 4640);
        AddFtrNft ('t52-5', 4641);
        AddParam ('t52', Api$Act_Rpt.get_AtSctNt (p_at_id, p_nng => 237));
        --Показник 5.3. Житлово-побутові умови
        AddFtrChk ('t53-1', 4642);
        AddFtrChk ('t53-1-1', 4642, 'F');
        AddFtrNft ('t53-1-2', 4642);
        AddFtrChk ('t53-2', 4643);
        AddFtrChk ('t53-2-1', 4643, 'F');
        AddFtrNft ('t53-2-2', 4643);
        AddFtrChk ('t53-3', 4644);
        AddFtrChk ('t53-3-1', 4644, 'F');
        AddFtrNft ('t53-3-2', 4644);
        AddFtrChk ('t53-4', 4645);
        AddFtrChk ('t53-4-1', 4645, 'F');
        AddFtrNft ('t53-4-2', 4645);
        AddFtrChk ('t53-5', 4646);
        AddFtrChk ('t53-5-1', 4646, 'F');
        AddFtrNft ('t53-5-2', 4646);
        AddFtrChk ('t53-6', 4647);
        AddFtrChk ('t53-6-1', 4647, 'F');
        AddFtrNft ('t53-6-2', 4647);
        AddFtrChk ('t53-7', 4648);
        AddFtrChk ('t53-7-1', 4648, 'F');
        AddFtrNft ('t53-7-2', 4648);
        AddFtrChk ('t53-8', 4649);
        AddFtrChk ('t53-8-1', 4649, 'F');
        AddFtrNft ('t53-8-2', 4649);
        AddParam ('t53', Api$Act_Rpt.get_AtSctNt (p_at_id, p_nng => 238));
        --Показник 5.4. Зайнятість
        AddFtrChk ('t54-1', 4650);
        AddFtrChk ('t54-1-1', 4650, 'F');
        AddFtrNft ('t54-1-2', 4650);
        AddFtrChk ('t54-2', 4651);
        AddFtrChk ('t54-2-1', 4651, 'F');
        AddFtrNft ('t54-2-2', 4651);
        AddFtrChk ('t54-3', 4652);
        AddFtrChk ('t54-3-1', 4652, 'F');
        AddFtrNft ('t54-3-2', 4652);
        AddFtrChk ('t54-4', 4653);
        AddFtrChk ('t54-4-1', 4653, 'F');
        AddFtrNft ('t54-4-2', 4653);
        AddFtrChk ('t54-5', 4654);
        AddFtrChk ('t54-5-1', 4654, 'F');
        AddFtrNft ('t54-5-2', 4654);
        AddParam ('t54', Api$Act_Rpt.get_AtSctNt (p_at_id, p_nng => 239));
        --Показник 5.5. Дохід
        AddFtrChk ('t55-1', 4655);
        AddFtrChk ('t55-1-1', 4655, 'F');
        AddFtrNft ('t55-1-2', 4655);
        AddFtrChk ('t55-2', 4656);
        AddFtrChk ('t55-2-1', 4656, 'F');
        AddFtrNft ('t55-2-2', 4656);
        AddFtrChk ('t55-3', 4657);
        AddFtrChk ('t55-3-1', 4657, 'F');
        AddFtrNft ('t55-3-2', 4657);
        AddFtrChk ('t55-4', 4658);
        AddFtrChk ('t55-4-1', 4658, 'F');
        AddFtrNft ('t55-4-2', 4658);
        AddFtrChk ('t55-5', 4659);
        AddFtrChk ('t55-5-1', 4659, 'F');
        AddFtrNft ('t55-5-2', 4659);
        AddFtrChk ('t55-6', 4660);
        AddFtrChk ('t55-6-1', 4660, 'F');
        AddFtrNft ('t55-6-2', 4660);
        AddParam ('t55', Api$Act_Rpt.get_AtSctNt (p_at_id, p_nng => 240));
        --Показник 5.6. Соціальна інтеграція
        AddFtrChk ('t56-1', 4661);
        AddFtrChk ('t56-1-1', 4661, 'F');
        AddFtrNft ('t56-1-2', 4661);
        AddFtrChk ('t56-2', 4662);
        AddFtrChk ('t56-2-1', 4662, 'F');
        AddFtrNft ('t56-2-2', 4662);
        AddFtrChk ('t56-3', 4663);
        AddFtrChk ('t56-3-1', 4663, 'F');
        AddFtrNft ('t56-3-2', 4663);
        AddFtrChk ('t56-4', 4664);
        AddFtrChk ('t56-4-1', 4664, 'F');
        AddFtrNft ('t56-4-2', 4664);
        AddParam ('t56', Api$Act_Rpt.get_AtSctNt (p_at_id, p_nng => 241));

        --VI. Висновки
        AddFtrNft ('60', 5558);
        AddFtrNft ('61', 5559);
        AddFtrNft ('62', 5560);
        AddFtrNft ('63', 5561);

        AddParam ('64', c.sgn_dt);
        AddParam ('65', Api$Act_Rpt.get_AtSctChld (p_at_id, p_nng => 387)); --Коментарі отримувача
        AddParam ('66', Api$Act_Rpt.get_AtSctPrnt (p_at_id, p_nng => 387)); --Коментарі батька/матері

        --Підтвердження отримання копії висновків
        AddParam ('sgn1_pib', p.pib);
        AddFtrChk ('sgn1-1', 4665);
        AddFtrChk ('sgn1-2', 4665, 'F');                           --отримувач
        AddFtrNft ('sgn2_pib', 4666);
        AddFtrChk ('sgn2-1', 4666);
        AddFtrChk ('sgn2-2', 4666, 'F');                                --мати
        AddFtrNft ('sgn3_pib', 4667);
        AddFtrChk ('sgn3-1', 4667);
        AddFtrChk ('sgn3-2', 4667, 'F');                              --батько


        AddParam ('sgn_mark_1',
                  api$act_rpt.get_sign_mark (p_at_id, p.Atp_Id, ''));
        AddParam ('sgn_mark_2', '' /*api$act_rpt.get_sign_mark(p_at_id, p.Atp_Id, '')*/
                                  );
        AddParam ('sgn_mark_3', '' /*api$act_rpt.get_sign_mark(p_at_id, p.Atp_Id, '')*/
                                  );


        AddParam ('sgn1-3', c.sgn_dt);
        AddParam ('sgn2-3', c.sgn_dt);
        AddParam ('sgn3-3', c.sgn_dt);                                  --дата
        --Підписи осіб, залучених до проведення оцінки
        l_str :=
            q'[
    select s.atop_ln||' '||s.atop_fn||' '||s.atop_mn c1, s.atop_position c2, null c3
      from uss_esr.v_at_other_spec s
     where s.atop_at = :p_at_id
       and s.history_status = 'A'
       --and s.atop_tp = 'OC'
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
                            'null',
                            CHR (39) || c.sgn_dt || CHR (39),
                            1,
                            0,
                            'i');
        rdm$rtfl_univ.AddDataset ('ds', l_str);

        --Працівник надавача соціальної послуги, який проводив оцінювання
        AddParam ('sgn4_pib', p2.pib);
        AddParam ('sgn4_1', p2.work_place);
        AddParam ('sgn4-2', c.sgn_dt);
        --Керівник надавача
        AddParam ('sgn5_pib',
                  get_signers_wucu_pib (p_at_id => p_at_id, p_ati_tp => 'PR'));
        AddParam ('sgn5-2', c.sgn_dt);

        ------------------------------------
        rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                         p_rpt_blob   => l_result);
        replace_ekr (l_result);

        RETURN l_result;
    END ACT_DOC_886_R1;

    --#94126 015.2-889-Визначення ступеня інд.потреб Догляд стаціонарний
    FUNCTION ACT_DOC_889_R1 (p_at_id IN NUMBER)
        RETURN BLOB
    IS
        --секція ЖИТЛО/ДОКУМЕНТИ з розділу "Анкета визначення рейтингу соціальних потреб..."
        C_ATE_NNG_ANK   CONSTANT INTEGER := 339;

        CURSOR c_at IS
            SELECT a.at_dt,
                   a.at_sc,
                   a.At_rnspm,
                   a.at_wu,
                   a.at_cu,
                   a.at_ap
              FROM act a
             WHERE a.at_id = p_at_id;

        c                        c_at%ROWTYPE;

        l_str                    VARCHAR2 (32000);

        p1                       Api$Act_Rpt.R_Person_for_act;     --отримувач
        p2                       at_other_spec%ROWTYPE;             --Фахівець
        p3                       Api$Act_Rpt.R_Person_for_act; --Законний представник

        l_jbr_id                 NUMBER;
        l_result                 BLOB;


        FUNCTION GetAtSectionSummary (p_at_id   act.at_id%TYPE,
                                      p_nng     at_section.ate_nng%TYPE)
            RETURN NUMBER
        IS
            CURSOR cur IS
                SELECT SUM (s.ate_indicator_value1)
                  FROM uss_esr.at_section s
                 WHERE s.ate_at = p_at_id AND s.ate_nng = p_nng;

            r   at_section.ate_indicator_value1%TYPE;
        BEGIN
            OPEN cur;

            FETCH cur INTO r;

            CLOSE cur;

            RETURN r;
        END;

        --для Анкети (uss_ndi.V_DDN_SS_TFN1)
        PROCEDURE AddFtrAnk (p_Param_Name   VARCHAR2,
                             p_atp          at_person.atp_id%TYPE,
                             p_nda          NUMBER)
        IS
        BEGIN
            CASE Get_Ftr (p_at_id => p_at_id, p_atp => p_atp, p_nda => p_nda)
                WHEN 'T'
                THEN
                    AddParam (p_Param_Name, 'Так');
                WHEN 'F'
                THEN
                    AddParam (p_Param_Name, 'Ні');
                ELSE
                    AddParam (p_Param_Name, '--');
            END CASE;
        END;

        PROCEDURE AddFtrAnk2 (p_Param_Name   VARCHAR2,
                              p_Atop         At_Section.Ate_Atop%TYPE,
                              p_Nda          NUMBER)
        IS
            CURSOR Cur IS
                SELECT f.Atef_Feature
                  FROM Uss_Esr.At_Section s, Uss_Esr.At_Section_Feature f
                 WHERE     s.Ate_At = p_At_Id
                       AND s.Ate_Atop = p_Atop
                       AND f.Atef_Ate = s.Ate_Id
                       AND f.Atef_Nda = p_Nda;

            l_Res   At_Section_Feature.Atef_Feature%TYPE;
        BEGIN
            OPEN Cur;

            FETCH Cur INTO l_Res;

            CLOSE Cur;

            CASE l_Res
                WHEN 'T'
                THEN
                    Addparam (p_Param_Name, 'Так');
                WHEN 'F'
                THEN
                    Addparam (p_Param_Name, 'Ні');
                ELSE
                    Addparam (p_Param_Name, '--');
            END CASE;
        END;
    BEGIN
        rdm$rtfl_univ.initreport (p_code     => 'ACT_DOC_889_R1',
                                  p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);

        ------------------------------------
        OPEN c_at;

        FETCH c_at INTO c;

        CLOSE c_at;

        --шукаємо по секції з заповненими даними трьох осіб
        SELECT MAX (CASE WHEN p.atp_app_tp = 'OS' THEN p.atp_id END), --отримувач
               MAX (CASE WHEN p.Atp_App_Tp = 'OR' THEN p.atp_id END) --Законний представник
          INTO p1.atp_id, p3.atp_id
          FROM uss_esr.at_section s, at_person p
         WHERE     1 = 1
               AND s.ate_at = p_at_id
               --секція ЖИТЛО/ДОКУМЕНТИ з розділу Таблиця 3
               --"Анкета визначення рейтингу соціальних потреб отримувача соціальної послуги соціальної реабілітації"
               AND s.ate_nng = C_ATE_NNG_ANK
               AND p.atp_at = s.ate_at
               AND p.atp_id = s.ate_atp;

        p1 := get_AtPerson (p_at => p_at_id, p_atp => p1.atp_id);
        p2 :=
            Get_Sctn_Specialist (p_At_Id         => p_at_id,
                                 p_Ate_Nng_Ank   => C_ATE_NNG_ANK); --Фахівець
        p3 := get_AtPerson (p_at => p_at_id, p_atp => p3.atp_id);

        --Таблиця 2 Шкала оцінювання можливості виконання елементарних дій
        AddParam ('t2.1.1', Get_Ftr_Ind (p_at_id, p_nda => 848)); --1 Прийом їжі
        AddParam ('t2.1.2', Get_Ftr_Ind (p_at_id, p_nda => 849));
        AddParam ('t2.1.3', Get_Ftr_Ind (p_at_id, p_nda => 850));
        AddParam ('t2.1.4', Get_Ftr_Ind (p_at_id, p_nda => 851));
        AddParam ('t2.1.5', Get_Ftr_Ind (p_at_id, p_nda => 852));
        AddParam ('t2.1.6', Get_Ftr_Ind (p_at_id, p_nda => 853));
        AddParam ('t2.1.7', Get_Ftr_Ind (p_at_id, p_nda => 854));
        AddParam ('t2.1.8', Get_Ftr_Ind (p_at_id, p_nda => 855));
        AddParam ('t2.1.9', Get_Ftr_Ind (p_at_id, p_nda => 1900));
        AddParam ('t2.2.1', Get_Ftr_Ind (p_at_id, p_nda => 1901)); --2 Купання
        AddParam ('t2.2.2', Get_Ftr_Ind (p_at_id, p_nda => 1902));
        AddParam ('t2.2.3', Get_Ftr_Ind (p_at_id, p_nda => 1903));
        AddParam ('t2.2.4', Get_Ftr_Ind (p_at_id, p_nda => 1904));
        AddParam ('t2.2.5', Get_Ftr_Ind (p_at_id, p_nda => 1905));
        AddParam ('t2.2.6', Get_Ftr_Ind (p_at_id, p_nda => 1906));
        AddParam ('t2.3.1', Get_Ftr_Ind (p_at_id, p_nda => 1907)); --3 Особистий туалет
        AddParam ('t2.3.2', Get_Ftr_Ind (p_at_id, p_nda => 1908));
        AddParam ('t2.3.3', Get_Ftr_Ind (p_at_id, p_nda => 2068));
        AddParam ('t2.3.4', Get_Ftr_Ind (p_at_id, p_nda => 2069));
        AddParam ('t2.3.5', Get_Ftr_Ind (p_at_id, p_nda => 2070));
        AddParam ('t2.3.6', Get_Ftr_Ind (p_at_id, p_nda => 2071));
        AddParam ('t2.4.1', Get_Ftr_Ind (p_at_id, p_nda => 2072)); --4 Одягання і взування
        AddParam ('t2.4.2', Get_Ftr_Ind (p_at_id, p_nda => 2073));
        AddParam ('t2.4.3', Get_Ftr_Ind (p_at_id, p_nda => 2074));
        AddParam ('t2.4.4', Get_Ftr_Ind (p_at_id, p_nda => 2075));
        AddParam ('t2.4.5', Get_Ftr_Ind (p_at_id, p_nda => 2109));
        AddParam ('t2.4.6', Get_Ftr_Ind (p_at_id, p_nda => 2110));
        AddParam ('t2.4.7', Get_Ftr_Ind (p_at_id, p_nda => 2541));
        AddParam ('t2.4.8', Get_Ftr_Ind (p_at_id, p_nda => 2542));
        AddParam ('t2.5.1', Get_Ftr_Ind (p_at_id, p_nda => 2543)); --5 Контроль дефекації
        AddParam ('t2.5.2', Get_Ftr_Ind (p_at_id, p_nda => 2544));
        AddParam ('t2.5.3', Get_Ftr_Ind (p_at_id, p_nda => 2721));
        AddParam ('t2.5.4', Get_Ftr_Ind (p_at_id, p_nda => 2722));
        AddParam ('t2.5.5', Get_Ftr_Ind (p_at_id, p_nda => 2723));
        AddParam ('t2.5.6', Get_Ftr_Ind (p_at_id, p_nda => 2724));
        AddParam ('t2.6.1', Get_Ftr_Ind (p_at_id, p_nda => 2725)); --6 Контроль сечовиділення
        AddParam ('t2.6.2', Get_Ftr_Ind (p_at_id, p_nda => 2726));
        AddParam ('t2.6.3', Get_Ftr_Ind (p_at_id, p_nda => 2727));
        AddParam ('t2.6.4', Get_Ftr_Ind (p_at_id, p_nda => 2728));
        AddParam ('t2.6.5', Get_Ftr_Ind (p_at_id, p_nda => 2729));
        AddParam ('t2.6.6', Get_Ftr_Ind (p_at_id, p_nda => 2730));
        AddParam ('t2.7.1', Get_Ftr_Ind (p_at_id, p_nda => 2731)); --7 Відвідування і здійснення туалету
        AddParam ('t2.7.2', Get_Ftr_Ind (p_at_id, p_nda => 2732));
        AddParam ('t2.7.3', Get_Ftr_Ind (p_at_id, p_nda => 2733));
        AddParam ('t2.7.4', Get_Ftr_Ind (p_at_id, p_nda => 2734));
        AddParam ('t2.7.5', Get_Ftr_Ind (p_at_id, p_nda => 2735));
        AddParam ('t2.7.6', Get_Ftr_Ind (p_at_id, p_nda => 2736));
        AddParam ('t2.7.7', Get_Ftr_Ind (p_at_id, p_nda => 2737));
        AddParam ('t2.8.1', Get_Ftr_Ind (p_at_id, p_nda => 2738)); --8 Вставання й перехід з ліжка
        AddParam ('t2.8.2', Get_Ftr_Ind (p_at_id, p_nda => 2739));
        AddParam ('t2.8.3', Get_Ftr_Ind (p_at_id, p_nda => 2740));
        AddParam ('t2.8.4', Get_Ftr_Ind (p_at_id, p_nda => 2741));
        AddParam ('t2.8.5', Get_Ftr_Ind (p_at_id, p_nda => 2742));
        AddParam ('t2.8.6', Get_Ftr_Ind (p_at_id, p_nda => 2743));
        AddParam ('t2.8.7', Get_Ftr_Ind (p_at_id, p_nda => 2744));
        AddParam ('t2.8.8', Get_Ftr_Ind (p_at_id, p_nda => 2745));
        AddParam ('t2.9.1', Get_Ftr_Ind (p_at_id, p_nda => 2746)); --9 Пересування
        AddParam ('t2.9.2', Get_Ftr_Ind (p_at_id, p_nda => 2747));
        AddParam ('t2.9.3', Get_Ftr_Ind (p_at_id, p_nda => 2748));
        AddParam ('t2.9.4', Get_Ftr_Ind (p_at_id, p_nda => 2749));
        AddParam ('t2.9.5', Get_Ftr_Ind (p_at_id, p_nda => 2750));
        AddParam ('t2.9.6', Get_Ftr_Ind (p_at_id, p_nda => 2751));
        AddParam ('t2.9.7', Get_Ftr_Ind (p_at_id, p_nda => 2752));
        AddParam ('t2.9.8', Get_Ftr_Ind (p_at_id, p_nda => 2753));
        AddParam ('t2.10.1', Get_Ftr_Ind (p_at_id, p_nda => 2754)); --10 Підіймання сходами
        AddParam ('t2.10.2', Get_Ftr_Ind (p_at_id, p_nda => 2755));
        AddParam ('t2.10.3', Get_Ftr_Ind (p_at_id, p_nda => 2756));
        AddParam ('t2.10.4', Get_Ftr_Ind (p_at_id, p_nda => 2757));
        AddParam ('t2.10.5', Get_Ftr_Ind (p_at_id, p_nda => 2758));
        AddParam ('t2.10.6', Get_Ftr_Ind (p_at_id, p_nda => 2759));
        --Сума балів
        AddParam (
            't2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 447).ate_indicator_value1);

        --Таблиця 3 Шкала оцінювання можливості виконання складних дій
        AddParam ('t3.1.1', Get_Ftr_Ind (p_at_id, p_nda => 2760));         --1
        AddParam ('t3.1.2', Get_Ftr_Ind (p_at_id, p_nda => 2761));
        AddParam ('t3.1.3', Get_Ftr_Ind (p_at_id, p_nda => 2762));
        AddParam ('t3.1.4', Get_Ftr_Ind (p_at_id, p_nda => 2763));
        AddParam ('t3.1.5', Get_Ftr_Ind (p_at_id, p_nda => 2764));
        AddParam ('t3.2.1', Get_Ftr_Ind (p_at_id, p_nda => 2765));         --2
        AddParam ('t3.2.2', Get_Ftr_Ind (p_at_id, p_nda => 2766));
        AddParam ('t3.2.3', Get_Ftr_Ind (p_at_id, p_nda => 2767));
        AddParam ('t3.2.4', Get_Ftr_Ind (p_at_id, p_nda => 2768));
        AddParam ('t3.2.5', Get_Ftr_Ind (p_at_id, p_nda => 2769));
        AddParam ('t3.3.1', Get_Ftr_Ind (p_at_id, p_nda => 2770));         --3
        AddParam ('t3.3.2', Get_Ftr_Ind (p_at_id, p_nda => 2771));
        AddParam ('t3.3.3', Get_Ftr_Ind (p_at_id, p_nda => 2772));
        AddParam ('t3.3.4', Get_Ftr_Ind (p_at_id, p_nda => 2773));
        AddParam ('t3.4.1', Get_Ftr_Ind (p_at_id, p_nda => 2774));         --4
        AddParam ('t3.4.2', Get_Ftr_Ind (p_at_id, p_nda => 2775));
        AddParam ('t3.4.3', Get_Ftr_Ind (p_at_id, p_nda => 2776));
        AddParam ('t3.4.4', Get_Ftr_Ind (p_at_id, p_nda => 2777));
        AddParam ('t3.4.5', Get_Ftr_Ind (p_at_id, p_nda => 2778));
        AddParam ('t3.5.1', Get_Ftr_Ind (p_at_id, p_nda => 2779));         --5
        AddParam ('t3.5.2', Get_Ftr_Ind (p_at_id, p_nda => 2780));
        AddParam ('t3.5.3', Get_Ftr_Ind (p_at_id, p_nda => 2781));
        AddParam ('t3.5.4', Get_Ftr_Ind (p_at_id, p_nda => 4955));
        AddParam ('t3.5.5', Get_Ftr_Ind (p_at_id, p_nda => 4956));
        AddParam ('t3.6.1', Get_Ftr_Ind (p_at_id, p_nda => 4957));         --6
        AddParam ('t3.6.2', Get_Ftr_Ind (p_at_id, p_nda => 4958));
        AddParam ('t3.6.3', Get_Ftr_Ind (p_at_id, p_nda => 4959));
        AddParam ('t3.6.4', Get_Ftr_Ind (p_at_id, p_nda => 4960));
        AddParam ('t3.7.1', Get_Ftr_Ind (p_at_id, p_nda => 4961));         --7
        AddParam ('t3.7.2', Get_Ftr_Ind (p_at_id, p_nda => 4962));
        AddParam ('t3.7.3', Get_Ftr_Ind (p_at_id, p_nda => 4963));
        AddParam ('t3.7.4', Get_Ftr_Ind (p_at_id, p_nda => 4964));
        AddParam ('t3.7.5', Get_Ftr_Ind (p_at_id, p_nda => 4965));
        AddParam ('t3.8.1', Get_Ftr_Ind (p_at_id, p_nda => 4966));         --8
        AddParam ('t3.8.2', Get_Ftr_Ind (p_at_id, p_nda => 4967));
        AddParam ('t3.8.3', Get_Ftr_Ind (p_at_id, p_nda => 4968));
        AddParam ('t3.8.4', Get_Ftr_Ind (p_at_id, p_nda => 4969));
        AddParam ('t3.9.1', Get_Ftr_Ind (p_at_id, p_nda => 4970));         --9
        AddParam ('t3.9.2', Get_Ftr_Ind (p_at_id, p_nda => 4971));
        AddParam ('t3.9.3', Get_Ftr_Ind (p_at_id, p_nda => 4972));
        AddParam ('t3.9.4', Get_Ftr_Ind (p_at_id, p_nda => 4973));
        --Сума балів
        AddParam (
            't3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 447).ate_indicator_value2);

        --Таблиця 4 Шкала оцінювання навичок проживання за основними категоріями
        --1 Управління фінансами
        AddParam ('t41.1.1', Get_Ftr_Chk2 (p_at_id, p_nda => 4974)); --Низький
        AddParam ('t41.1.2', Get_Ftr_Chk2 (p_at_id, p_nda => 4975));
        AddParam ('t41.1.3', Get_Ftr_Chk2 (p_at_id, p_nda => 4976));
        AddParam ('t41.1.4', Get_Ftr_Chk2 (p_at_id, p_nda => 4977));
        AddParam ('t41.1.5', Get_Ftr_Chk2 (p_at_id, p_nda => 4978));
        AddParam ('t41.2.1', Get_Ftr_Chk2 (p_at_id, p_nda => 4979)); --Базовий
        AddParam ('t41.2.2', Get_Ftr_Chk2 (p_at_id, p_nda => 4980));
        AddParam ('t41.2.3', Get_Ftr_Chk2 (p_at_id, p_nda => 4981));
        AddParam ('t41.2.4', Get_Ftr_Chk2 (p_at_id, p_nda => 4982));
        AddParam ('t41.2.5', Get_Ftr_Chk2 (p_at_id, p_nda => 4983));
        AddParam ('t41.3.1', Get_Ftr_Chk2 (p_at_id, p_nda => 4984)); --Задовільний
        AddParam ('t41.3.2', Get_Ftr_Chk2 (p_at_id, p_nda => 4985));
        AddParam ('t41.3.3', Get_Ftr_Chk2 (p_at_id, p_nda => 4986));
        AddParam ('t41.3.4', Get_Ftr_Chk2 (p_at_id, p_nda => 4987));
        AddParam ('t41.3.5', Get_Ftr_Chk2 (p_at_id, p_nda => 4988));
        AddParam ('t41.4.1', Get_Ftr_Chk2 (p_at_id, p_nda => 4989));  --Добрий
        AddParam ('t41.4.2', Get_Ftr_Chk2 (p_at_id, p_nda => 4990));
        AddParam ('t41.4.3', Get_Ftr_Chk2 (p_at_id, p_nda => 4991));
        AddParam ('t41.4.4', Get_Ftr_Chk2 (p_at_id, p_nda => 4992));
        AddParam ('t41.4.5', Get_Ftr_Chk2 (p_at_id, p_nda => 4993));
        AddParam ('t41.5.1', Get_Ftr_Chk2 (p_at_id, p_nda => 4994)); --Високий
        AddParam ('t41.5.2', Get_Ftr_Chk2 (p_at_id, p_nda => 4995));
        AddParam ('t41.5.3', Get_Ftr_Chk2 (p_at_id, p_nda => 4996));
        AddParam ('t41.5.4', Get_Ftr_Chk2 (p_at_id, p_nda => 4997));
        AddParam ('t41.5.5', Get_Ftr_Chk2 (p_at_id, p_nda => 4998));
        --2 Організація харчування
        AddParam ('t42.1.1', Get_Ftr_Chk2 (p_at_id, p_nda => 4999)); --Низький
        AddParam ('t42.1.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5000));
        AddParam ('t42.1.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5001));
        AddParam ('t42.1.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5002));
        AddParam ('t42.1.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5003));
        AddParam ('t42.2.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5004)); --Базовий
        AddParam ('t42.2.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5005));
        AddParam ('t42.2.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5006));
        AddParam ('t42.2.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5007));
        AddParam ('t42.2.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5008));
        AddParam ('t42.3.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5009)); --Задовільний
        AddParam ('t42.3.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5010));
        AddParam ('t42.3.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5011));
        AddParam ('t42.3.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5012));
        AddParam ('t42.3.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5013));
        AddParam ('t42.4.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5014));  --Добрий
        AddParam ('t42.4.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5015));
        AddParam ('t42.4.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5016));
        AddParam ('t42.4.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5017));
        AddParam ('t42.4.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5018));
        AddParam ('t42.5.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5019)); --Високий
        AddParam ('t42.5.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5020));
        AddParam ('t42.5.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5021));
        AddParam ('t42.5.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5022));
        AddParam ('t42.5.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5023));
        --3 Зовнішній вигляд
        AddParam ('t43.1.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5024)); --Низький
        AddParam ('t43.1.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5025));
        AddParam ('t43.1.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5026));
        AddParam ('t43.1.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5027));
        AddParam ('t43.1.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5028));
        AddParam ('t43.2.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5029)); --Базовий
        AddParam ('t43.2.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5030));
        AddParam ('t43.2.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5031));
        AddParam ('t43.2.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5032));
        AddParam ('t43.2.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5033));
        AddParam ('t43.3.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5034)); --Задовільний
        AddParam ('t43.3.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5035));
        AddParam ('t43.3.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5036));
        AddParam ('t43.3.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5037));
        AddParam ('t43.3.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5038));
        AddParam ('t43.4.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5039));  --Добрий
        AddParam ('t43.4.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5040));
        AddParam ('t43.4.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5041));
        AddParam ('t43.4.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5042));
        AddParam ('t43.4.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5043));
        AddParam ('t43.5.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5044)); --Високий
        AddParam ('t43.5.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5045));
        AddParam ('t43.5.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5046));
        AddParam ('t43.5.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5047));
        AddParam ('t43.5.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5048));
        --4 Здоров’я
        AddParam ('t44.1.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5049)); --Низький
        AddParam ('t44.1.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5050));
        AddParam ('t44.1.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5051));
        AddParam ('t44.1.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5052));
        AddParam ('t44.1.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5053));
        AddParam ('t44.2.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5054)); --Базовий
        AddParam ('t44.2.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5055));
        AddParam ('t44.2.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5056));
        AddParam ('t44.2.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5057));
        AddParam ('t44.2.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5058));
        AddParam ('t44.3.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5059)); --Задовільний
        AddParam ('t44.3.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5060));
        AddParam ('t44.3.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5061));
        AddParam ('t44.3.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5062));
        AddParam ('t44.3.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5063));
        AddParam ('t44.4.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5064));  --Добрий
        AddParam ('t44.4.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5065));
        AddParam ('t44.4.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5066));
        AddParam ('t44.4.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5067));
        AddParam ('t44.4.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5068));
        AddParam ('t44.5.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5069)); --Високий
        AddParam ('t44.5.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5070));
        AddParam ('t44.5.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5071));
        AddParam ('t44.5.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5072));
        AddParam ('t44.5.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5073));
        --5 Утримання помешкання
        AddParam ('t45.1.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5074)); --Низький
        AddParam ('t45.1.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5075));
        AddParam ('t45.1.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5076));
        AddParam ('t45.1.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5077));
        AddParam ('t45.1.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5078));
        AddParam ('t45.2.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5079)); --Базовий
        AddParam ('t45.2.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5080));
        AddParam ('t45.2.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5081));
        AddParam ('t45.2.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5082));
        AddParam ('t45.2.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5083));
        AddParam ('t45.3.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5084)); --Задовільний
        AddParam ('t45.3.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5085));
        AddParam ('t45.3.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5086));
        AddParam ('t45.3.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5087));
        AddParam ('t45.3.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5088));
        AddParam ('t45.4.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5089));  --Добрий
        AddParam ('t45.4.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5090));
        AddParam ('t45.4.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5091));
        AddParam ('t45.4.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5092));
        AddParam ('t45.4.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5093));
        AddParam ('t45.5.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5094)); --Високий
        AddParam ('t45.5.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5095));
        AddParam ('t45.5.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5096));
        AddParam ('t45.5.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5097));
        AddParam ('t45.5.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5098));
        --6 Обізнаність у сфері нерухомості
        AddParam ('t46.1.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5099)); --Низький
        AddParam ('t46.1.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5100));
        AddParam ('t46.1.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5101));
        AddParam ('t46.1.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5102));
        AddParam ('t46.1.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5103));
        AddParam ('t46.2.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5104)); --Базовий
        AddParam ('t46.2.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5105));
        AddParam ('t46.2.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5106));
        AddParam ('t46.2.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5107));
        AddParam ('t46.2.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5108));
        AddParam ('t46.3.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5109)); --Задовільний
        AddParam ('t46.3.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5110));
        AddParam ('t46.3.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5111));
        AddParam ('t46.3.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5112));
        AddParam ('t46.3.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5113));
        AddParam ('t46.4.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5114));  --Добрий
        AddParam ('t46.4.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5115));
        AddParam ('t46.4.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5116));
        AddParam ('t46.4.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5117));
        AddParam ('t46.4.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5118));
        AddParam ('t46.5.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5119)); --Високий
        AddParam ('t46.5.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5120));
        AddParam ('t46.5.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5121));
        AddParam ('t46.5.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5122));
        AddParam ('t46.5.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5123));
        --7 Користування транспортом
        AddParam ('t47.1.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5124)); --Низький
        AddParam ('t47.1.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5125));
        AddParam ('t47.1.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5126));
        AddParam ('t47.1.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5127));
        AddParam ('t47.1.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5128));
        AddParam ('t47.2.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5129)); --Базовий
        AddParam ('t47.2.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5130));
        AddParam ('t47.2.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5131));
        AddParam ('t47.2.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5132));
        AddParam ('t47.2.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5133));
        AddParam ('t47.3.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5134)); --Задовільний
        AddParam ('t47.3.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5135));
        AddParam ('t47.3.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5136));
        AddParam ('t47.3.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5137));
        AddParam ('t47.3.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5138));
        AddParam ('t47.4.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5139));  --Добрий
        AddParam ('t47.4.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5140));
        AddParam ('t47.4.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5141));
        AddParam ('t47.4.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5142));
        AddParam ('t47.4.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5143));
        AddParam ('t47.5.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5144)); --Високий
        AddParam ('t47.5.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5145));
        AddParam ('t47.5.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5146));
        AddParam ('t47.5.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5147));
        AddParam ('t47.5.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5148));
        --8 Організація навчального процесу
        AddParam ('t48.1.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5149)); --Низький
        AddParam ('t48.1.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5150));
        AddParam ('t48.1.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5151));
        AddParam ('t48.1.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5152));
        AddParam ('t48.1.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5153));
        AddParam ('t48.2.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5154)); --Базовий
        AddParam ('t48.2.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5155));
        AddParam ('t48.2.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5156));
        AddParam ('t48.2.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5157));
        AddParam ('t48.2.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5158));
        AddParam ('t48.3.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5159)); --Задовільний
        AddParam ('t48.3.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5160));
        AddParam ('t48.3.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5161));
        AddParam ('t48.3.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5162));
        AddParam ('t48.3.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5163));
        AddParam ('t48.4.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5164));  --Добрий
        AddParam ('t48.4.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5165));
        AddParam ('t48.4.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5166));
        AddParam ('t48.4.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5167));
        AddParam ('t48.4.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5168));
        AddParam ('t48.5.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5169)); --Високий
        AddParam ('t48.5.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5170));
        AddParam ('t48.5.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5171));
        AddParam ('t48.5.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5172));
        AddParam ('t48.5.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5173));
        --9 Навички пошуку роботи
        AddParam ('t49.1.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5174)); --Низький
        AddParam ('t49.1.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5175));
        AddParam ('t49.1.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5176));
        AddParam ('t49.1.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5177));
        AddParam ('t49.1.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5178));
        AddParam ('t49.2.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5179)); --Базовий
        AddParam ('t49.2.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5180));
        AddParam ('t49.2.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5181));
        AddParam ('t49.2.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5182));
        AddParam ('t49.2.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5183));
        AddParam ('t49.3.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5184)); --Задовільний
        AddParam ('t49.3.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5185));
        AddParam ('t49.3.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5186));
        AddParam ('t49.3.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5187));
        AddParam ('t49.3.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5188));
        AddParam ('t49.4.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5189));  --Добрий
        AddParam ('t49.4.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5190));
        AddParam ('t49.4.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5191));
        AddParam ('t49.4.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5192));
        AddParam ('t49.4.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5193));
        AddParam ('t49.5.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5194)); --Високий
        AddParam ('t49.5.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5195));
        AddParam ('t49.5.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5196));
        AddParam ('t49.5.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5197));
        AddParam ('t49.5.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5198));
        --10 Організація роботи
        AddParam ('t410.1.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5199)); --Низький
        AddParam ('t410.1.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5200));
        AddParam ('t410.1.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5201));
        AddParam ('t410.1.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5202));
        AddParam ('t410.1.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5203));
        AddParam ('t410.2.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5204)); --Базовий
        AddParam ('t410.2.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5205));
        AddParam ('t410.2.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5206));
        AddParam ('t410.2.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5207));
        AddParam ('t410.2.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5208));
        AddParam ('t410.3.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5209)); --Задовільний
        AddParam ('t410.3.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5210));
        AddParam ('t410.3.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5211));
        AddParam ('t410.3.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5212));
        AddParam ('t410.3.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5213));
        AddParam ('t410.4.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5214)); --Добрий
        AddParam ('t410.4.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5215));
        AddParam ('t410.4.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5216));
        AddParam ('t410.4.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5217));
        AddParam ('t410.4.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5218));
        AddParam ('t410.5.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5219)); --Високий
        AddParam ('t410.5.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5220));
        AddParam ('t410.5.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5221));
        AddParam ('t410.5.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5222));
        AddParam ('t410.5.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5223));
        --11 Дотримання правил безпеки
        AddParam ('t411.1.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5224)); --Низький
        AddParam ('t411.1.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5225));
        AddParam ('t411.1.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5226));
        AddParam ('t411.1.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5227));
        AddParam ('t411.1.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5228));
        AddParam ('t411.2.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5229)); --Базовий
        AddParam ('t411.2.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5230));
        AddParam ('t411.2.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5231));
        AddParam ('t411.2.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5232));
        AddParam ('t411.2.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5233));
        AddParam ('t411.3.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5234)); --Задовільний
        AddParam ('t411.3.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5235));
        AddParam ('t411.3.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5236));
        AddParam ('t411.3.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5237));
        AddParam ('t411.3.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5238));
        AddParam ('t411.4.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5239)); --Добрий
        AddParam ('t411.4.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5240));
        AddParam ('t411.4.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5241));
        AddParam ('t411.4.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5242));
        AddParam ('t411.4.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5243));
        AddParam ('t411.5.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5244)); --Високий
        AddParam ('t411.5.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5245));
        AddParam ('t411.5.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5246));
        AddParam ('t411.5.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5247));
        AddParam ('t411.5.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5248));
        --12 Знання ресурсів громади
        AddParam ('t412.1.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5249)); --Низький
        AddParam ('t412.1.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5250));
        AddParam ('t412.1.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5251));
        AddParam ('t412.1.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5252));
        AddParam ('t412.1.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5253));
        AddParam ('t412.2.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5254)); --Базовий
        AddParam ('t412.2.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5255));
        AddParam ('t412.2.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5256));
        AddParam ('t412.2.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5257));
        AddParam ('t412.2.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5258));
        AddParam ('t412.3.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5259)); --Задовільний
        AddParam ('t412.3.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5260));
        AddParam ('t412.3.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5261));
        AddParam ('t412.3.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5262));
        AddParam ('t412.3.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5263));
        AddParam ('t412.4.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5264)); --Добрий
        AddParam ('t412.4.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5265));
        AddParam ('t412.4.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5266));
        AddParam ('t412.4.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5267));
        AddParam ('t412.4.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5268));
        AddParam ('t412.5.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5269)); --Високий
        AddParam ('t412.5.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5270));
        AddParam ('t412.5.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5271));
        AddParam ('t412.5.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5272));
        AddParam ('t412.5.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5273));
        --13 Міжособистісні відносини
        AddParam ('t413.1.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5274)); --Низький
        AddParam ('t413.1.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5275));
        AddParam ('t413.1.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5276));
        AddParam ('t413.1.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5277));
        AddParam ('t413.1.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5278));
        AddParam ('t413.2.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5279)); --Базовий
        AddParam ('t413.2.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5280));
        AddParam ('t413.2.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5281));
        AddParam ('t413.2.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5282));
        AddParam ('t413.2.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5283));
        AddParam ('t413.3.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5284)); --Задовільний
        AddParam ('t413.3.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5285));
        AddParam ('t413.3.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5286));
        AddParam ('t413.3.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5287));
        AddParam ('t413.3.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5288));
        AddParam ('t413.4.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5289)); --Добрий
        AddParam ('t413.4.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5290));
        AddParam ('t413.4.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5291));
        AddParam ('t413.4.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5292));
        AddParam ('t413.4.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5293));
        AddParam ('t413.5.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5294)); --Високий
        AddParam ('t413.5.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5295));
        AddParam ('t413.5.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5296));
        AddParam ('t413.5.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5297));
        AddParam ('t413.5.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5298));
        --14 Обізнаність у юридичній сфері
        AddParam ('t414.1.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5299)); --Низький
        AddParam ('t414.1.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5300));
        AddParam ('t414.1.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5301));
        AddParam ('t414.1.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5302));
        AddParam ('t414.1.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5303));
        AddParam ('t414.2.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5304)); --Базовий
        AddParam ('t414.2.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5305));
        AddParam ('t414.2.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5306));
        AddParam ('t414.2.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5307));
        AddParam ('t414.2.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5308));
        AddParam ('t414.3.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5309)); --Задовільний
        AddParam ('t414.3.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5310));
        AddParam ('t414.3.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5311));
        AddParam ('t414.3.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5312));
        AddParam ('t414.3.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5313));
        AddParam ('t414.4.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5314)); --Добрий
        AddParam ('t414.4.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5315));
        AddParam ('t414.4.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5316));
        AddParam ('t414.4.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5317));
        AddParam ('t414.4.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5318));
        AddParam ('t414.5.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5319)); --Високий
        AddParam ('t414.5.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5320));
        AddParam ('t414.5.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5321));
        AddParam ('t414.5.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5322));
        AddParam ('t414.5.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5323));

        --Таблиця 5 Картка визначення рівня індивідуальних потреб дитини з інвалідністю (ітоги з Таблиці 4)
        --1 Управління фінансами
        AddParam (
            't51.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 269).ate_indicator_value1); --Низький
        AddParam (
            't51.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 270).ate_indicator_value1); --Базовий
        AddParam (
            't51.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 271).ate_indicator_value1); --Задовільний
        AddParam (
            't51.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 272).ate_indicator_value1); --Добрий
        AddParam (
            't51.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 273).ate_indicator_value1); --Високий
        --2 організація харчування
        AddParam (
            't52.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 274).ate_indicator_value1); --Низький
        AddParam (
            't52.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 275).ate_indicator_value1); --Базовий
        AddParam (
            't52.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 276).ate_indicator_value1); --Задовільний
        AddParam (
            't52.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 277).ate_indicator_value1); --Добрий
        AddParam (
            't52.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 278).ate_indicator_value1); --Високий
        --3 Зовнішній вигляд
        AddParam (
            't53.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 279).ate_indicator_value1); --Низький
        AddParam (
            't53.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 280).ate_indicator_value1); --Базовий
        AddParam (
            't53.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 281).ate_indicator_value1); --Задовільний
        AddParam (
            't53.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 282).ate_indicator_value1); --Добрий
        AddParam (
            't53.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 283).ate_indicator_value1); --Високий
        --4 здоров’я
        AddParam (
            't54.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 284).ate_indicator_value1); --Низький
        AddParam (
            't54.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 285).ate_indicator_value1); --Базовий
        AddParam (
            't54.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 286).ate_indicator_value1); --Задовільний
        AddParam (
            't54.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 287).ate_indicator_value1); --Добрий
        AddParam (
            't54.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 288).ate_indicator_value1); --Високий
        --5 утримання помешкання
        AddParam (
            't55.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 289).ate_indicator_value1); --Низький
        AddParam (
            't55.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 290).ate_indicator_value1); --Базовий
        AddParam (
            't55.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 291).ate_indicator_value1); --Задовільний
        AddParam (
            't55.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 292).ate_indicator_value1); --Добрий
        AddParam (
            't55.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 293).ate_indicator_value1); --Високий
        --6 обізнаність у сфері нерухомості
        AddParam (
            't56.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 294).ate_indicator_value1); --Низький
        AddParam (
            't56.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 295).ate_indicator_value1); --Базовий
        AddParam (
            't56.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 296).ate_indicator_value1); --Задовільний
        AddParam (
            't56.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 297).ate_indicator_value1); --Добрий
        AddParam (
            't56.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 298).ate_indicator_value1); --Високий
        --7 користування транспортом
        AddParam (
            't57.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 299).ate_indicator_value1); --Низький
        AddParam (
            't57.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 300).ate_indicator_value1); --Базовий
        AddParam (
            't57.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 301).ate_indicator_value1); --Задовільний
        AddParam (
            't57.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 302).ate_indicator_value1); --Добрий
        AddParam (
            't57.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 303).ate_indicator_value1); --Високий
        --8 організація навчального процесу
        AddParam (
            't58.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 304).ate_indicator_value1); --Низький
        AddParam (
            't58.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 305).ate_indicator_value1); --Базовий
        AddParam (
            't58.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 306).ate_indicator_value1); --Задовільний
        AddParam (
            't58.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 307).ate_indicator_value1); --Добрий
        AddParam (
            't58.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 308).ate_indicator_value1); --Високий
        --9 навички пошуку роботи
        AddParam (
            't59.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 309).ate_indicator_value1); --Низький
        AddParam (
            't59.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 310).ate_indicator_value1); --Базовий
        AddParam (
            't59.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 311).ate_indicator_value1); --Задовільний
        AddParam (
            't59.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 312).ate_indicator_value1); --Добрий
        AddParam (
            't59.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 313).ate_indicator_value1); --Високий
        --10 організація роботи
        AddParam (
            't510.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 314).ate_indicator_value1); --Низький
        AddParam (
            't510.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 315).ate_indicator_value1); --Базовий
        AddParam (
            't510.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 316).ate_indicator_value1); --Задовільний
        AddParam (
            't510.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 317).ate_indicator_value1); --Добрий
        AddParam (
            't510.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 318).ate_indicator_value1); --Високий
        --11  дотримання правил безпеки та поведінка
        AddParam (
            't511.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 319).ate_indicator_value1); --Низький
        AddParam (
            't511.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 320).ate_indicator_value1); --Базовий
        AddParam (
            't511.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 321).ate_indicator_value1); --Задовільний
        AddParam (
            't511.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 322).ate_indicator_value1); --Добрий
        AddParam (
            't511.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 323).ate_indicator_value1); --Високий
        --12 знання ресурсів громади
        AddParam (
            't512.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 324).ate_indicator_value1); --Низький
        AddParam (
            't512.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 325).ate_indicator_value1); --Базовий
        AddParam (
            't512.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 326).ate_indicator_value1); --Задовільний
        AddParam (
            't512.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 327).ate_indicator_value1); --Добрий
        AddParam (
            't512.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 328).ate_indicator_value1); --Високий
        --13 міжособистісні відносини
        AddParam (
            't513.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 329).ate_indicator_value1); --Низький
        AddParam (
            't513.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 330).ate_indicator_value1); --Базовий
        AddParam (
            't513.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 331).ate_indicator_value1); --Задовільний
        AddParam (
            't513.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 332).ate_indicator_value1); --Добрий
        AddParam (
            't513.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 333).ate_indicator_value1); --Високий
        --14 обізнаність у юридичній сфері
        AddParam (
            't514.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 334).ate_indicator_value1); --Низький
        AddParam (
            't514.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 335).ate_indicator_value1); --Базовий
        AddParam (
            't514.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 336).ate_indicator_value1); --Задовільний
        AddParam (
            't514.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 337).ate_indicator_value1); --Добрий
        AddParam (
            't514.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 338).ate_indicator_value1); --Високий
        --Загальна кількість балів
        AddParam ('t51', Get_Ftr_Nt (p_at_id, p_nda => 2806));
        AddParam ('t52', Get_Ftr_Nt (p_at_id, p_nda => 2807));
        AddParam ('t53', Get_Ftr_Nt (p_at_id, p_nda => 2808));
        AddParam ('t54', Get_Ftr_Nt (p_at_id, p_nda => 2809));
        AddParam ('t55', Get_Ftr_Nt (p_at_id, p_nda => 2810));
        AddParam ('t56', Get_Ftr_Nt (p_at_id, p_nda => 2811));
        AddParam ('t57', Get_Ftr_Nt (p_at_id, p_nda => 2812));
        AddParam ('t58', Get_Ftr_Nt (p_at_id, p_nda => 2813));
        AddParam ('t59', Get_Ftr_Nt (p_at_id, p_nda => 2814));
        AddParam ('t510', Get_Ftr_Nt (p_at_id, p_nda => 2815));
        AddParam ('t511', Get_Ftr_Nt (p_at_id, p_nda => 2816));
        AddParam ('t512', Get_Ftr_Nt (p_at_id, p_nda => 3131));
        AddParam ('t513', Get_Ftr_Nt (p_at_id, p_nda => 3132));
        AddParam ('t514', Get_Ftr_Nt (p_at_id, p_nda => 3133));

        --Висновок.
        AddParam ('v1', p1.pib);                --Отримувач соціальної послуги
        AddParam (
            'v2',
            NVL (
                Api$Act_Rpt.v_ddn (
                    'uss_ndi.V_DDN_SS_LEVEL_HAS_SKL',
                    Api$Act_Rpt.Get_Ftr (p_at_id, p_nda => 3137)),
                '______'));                                         --на рівні
        AddParam (
            'v3',
            NVL (
                TO_CHAR (
                    Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 449).ate_indicator_value1),
                '______'));                                     --усього балів
        AddParam (
            'v4',
            NVL (
                TO_CHAR (
                    Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 449).ate_indicator_value2),
                '______'));                               --в середньому годин

        --Особи, які брали участь в оцінюванні
        l_str :=
            q'[
    select p.pib                  as c1,
           p.Relation_Tp          as c2,
           null                   as c3,
           api$act_rpt.get_sign_mark(:p_at_id, p.Atp_Id, '') as c4
      from uss_esr.at_section s, table(uss_esr.Api$Act_Rpt.At_Person_for_act(:p_at_id)) p
     where 1=1
       and s.ate_at = :p_at_id
       --секція з розділу Таблиця 3
      -- and s.ate_nng = :C_ATE_NNG_ANK
       and p.atp_id = s.ate_atp
      -- and atp_app_tp <> 'AP'
    ]';
        l_str :=
            REGEXP_REPLACE (l_str,
                            ':p_at_id',
                            p_at_id,
                            1,
                            0,
                            'i');
        l_str :=
            REGEXP_REPLACE (
                l_str,
                'null',
                CHR (39) || TO_CHAR (c.at_dt, 'dd.mm.yyyy') || CHR (39),
                1,
                0,
                'i');
        l_str := REPLACE (l_str, ':C_ATE_NNG_ANK', C_ATE_NNG_ANK);
        rdm$rtfl_univ.AddDataset ('ds', l_str);

        AddParam ('sgn1',
                  p2.atop_ln || ' ' || p2.atop_fn || ' ' || p2.atop_mn); --Особа, яка провела оцінювання
        AddParam ('sgn3', TO_CHAR (c.at_dt, 'dd.mm.yyyy'));

        --Таблиця 6 Анкета для визначення рейтингу соціальних потреб отримувача соціальної послуги стаціонарного догляду
        AddParam ('a1', p1.pib);                                   --отримувач
        AddParam ('a2', p1.birth_dt_str);
        AddParam ('a3', p1.live_address);
        AddParam ('a4', p2.atop_ln || ' ' || p2.atop_fn || ' ' || p2.atop_mn);
        AddParam ('a5', TO_CHAR (c.at_dt, 'dd.mm.yyyy'));    --Дата опитування
        --
        --ЖИТЛО/ДОКУМЕНТИ
        AddFtrAnk ('a.1.1', p1.atp_id, 5324);
        AddFtrAnk2 ('a.1.2', p2.atop_id, 5324);
        AddFtrAnk ('a.1.3', p3.atp_id, 5324);
        AddFtrAnk ('a.2.1', p1.atp_id, 5325);
        AddFtrAnk2 ('a.2.2', p2.atop_id, 5325);
        AddFtrAnk ('a.2.3', p3.atp_id, 5325);
        AddFtrAnk ('a.3.1', p1.atp_id, 5326);
        AddFtrAnk2 ('a.3.2', p2.atop_id, 5326);
        AddFtrAnk ('a.3.3', p3.atp_id, 5326);
        AddFtrAnk ('a.4.1', p1.atp_id, 5327);
        AddFtrAnk2 ('a.4.2', p2.atop_id, 5327);
        AddFtrAnk ('a.4.3', p3.atp_id, 5327);
        AddFtrAnk ('a.5.1', p1.atp_id, 5328);
        AddFtrAnk2 ('a.5.2', p2.atop_id, 5328);
        AddFtrAnk ('a.5.3', p3.atp_id, 5328);
        AddFtrAnk ('a.6.1', p1.atp_id, 5329);
        AddFtrAnk2 ('a.6.2', p2.atop_id, 5329);
        AddFtrAnk ('a.6.3', p3.atp_id, 5329);
        --НАВИЧКИ САМОСТІЙНОГО ПРОЖИВАННЯ
        AddFtrAnk ('a.7.1', p1.atp_id, 5330);
        AddFtrAnk2 ('a.7.2', p2.atop_id, 5330);
        AddFtrAnk ('a.7.3', p3.atp_id, 5330);
        AddFtrAnk ('a.8.1', p1.atp_id, 5331);
        AddFtrAnk2 ('a.8.2', p2.atop_id, 5331);
        AddFtrAnk ('a.8.3', p3.atp_id, 5331);
        AddFtrAnk ('a.9.1', p1.atp_id, 5332);
        AddFtrAnk2 ('a.9.2', p2.atop_id, 5332);
        AddFtrAnk ('a.9.3', p3.atp_id, 5332);
        AddFtrAnk ('a.10.1', p1.atp_id, 5333);
        AddFtrAnk2 ('a.10.2', p2.atop_id, 5333);
        AddFtrAnk ('a.10.3', p3.atp_id, 5333);
        AddFtrAnk ('a.11.1', p1.atp_id, 5334);
        AddFtrAnk2 ('a.11.2', p2.atop_id, 5334);
        AddFtrAnk ('a.11.3', p3.atp_id, 5334);
        AddFtrAnk ('a.12.1', p1.atp_id, 5335);
        AddFtrAnk2 ('a.12.2', p2.atop_id, 5335);
        AddFtrAnk ('a.12.3', p3.atp_id, 5335);
        --СФЕРА ЗДОРОВ’Я
        AddFtrAnk ('a.13.1', p1.atp_id, 5336);
        AddFtrAnk2 ('a.13.2', p2.atop_id, 5336);
        AddFtrAnk ('a.13.3', p3.atp_id, 5336);
        AddFtrAnk ('a.14.1', p1.atp_id, 5337);
        AddFtrAnk2 ('a.14.2', p2.atop_id, 5337);
        AddFtrAnk ('a.14.3', p3.atp_id, 5337);
        AddFtrAnk ('a.15.1', p1.atp_id, 5338);
        AddFtrAnk2 ('a.15.2', p2.atop_id, 5338);
        AddFtrAnk ('a.15.3', p3.atp_id, 5338);
        AddFtrAnk ('a.16.1', p1.atp_id, 5339);
        AddFtrAnk2 ('a.16.2', p2.atop_id, 5339);
        AddFtrAnk ('a.16.3', p3.atp_id, 5339);
        AddFtrAnk ('a.17.1', p1.atp_id, 5340);
        AddFtrAnk2 ('a.17.2', p2.atop_id, 5340);
        AddFtrAnk ('a.17.3', p3.atp_id, 5340);
        AddFtrAnk ('a.18.1', p1.atp_id, 5341);
        AddFtrAnk2 ('a.18.2', p2.atop_id, 5341);
        AddFtrAnk ('a.18.3', p3.atp_id, 5341);
        --СОЦІАЛЬНА СФЕРА
        AddFtrAnk ('a.19.1', p1.atp_id, 5342);
        AddFtrAnk2 ('a.19.2', p2.atop_id, 5342);
        AddFtrAnk ('a.19.3', p3.atp_id, 5342);
        AddFtrAnk ('a.20.1', p1.atp_id, 5343);
        AddFtrAnk2 ('a.20.2', p2.atop_id, 5343);
        AddFtrAnk ('a.20.3', p3.atp_id, 5343);
        AddFtrAnk ('a.21.1', p1.atp_id, 5344);
        AddFtrAnk2 ('a.21.2', p2.atop_id, 5344);
        AddFtrAnk ('a.21.3', p3.atp_id, 5344);
        AddFtrAnk ('a.22.1', p1.atp_id, 5345);
        AddFtrAnk2 ('a.22.2', p2.atop_id, 5345);
        AddFtrAnk ('a.22.3', p3.atp_id, 5345);
        AddFtrAnk ('a.23.1', p1.atp_id, 5346);
        AddFtrAnk2 ('a.23.2', p2.atop_id, 5346);
        AddFtrAnk ('a.23.3', p3.atp_id, 5346);
        AddFtrAnk ('a.24.1', p1.atp_id, 5347);
        AddFtrAnk2 ('a.24.2', p2.atop_id, 5347);
        AddFtrAnk ('a.24.3', p3.atp_id, 5347);
        --Загальна сума балів за сферами
        /* AddParam('itg1', Api$Act_Rpt.GetAtSection(p_at_id, p_nng => 339).ate_indicator_value1);--Житло/документи
         AddParam('itg2', Api$Act_Rpt.GetAtSection(p_at_id, p_nng => 340).ate_indicator_value1);--Навички самостійного проживання
         AddParam('itg3', Api$Act_Rpt.GetAtSection(p_at_id, p_nng => 341).ate_indicator_value1);--Здоров’я
         AddParam('itg4', Api$Act_Rpt.GetAtSection(p_at_id, p_nng => 342).ate_indicator_value1);--Соціальна сфера*/
        AddParam ('itg1', GetAtSectionSummary (p_at_id, p_nng => 339)); --Житло/документи
        AddParam ('itg2', GetAtSectionSummary (p_at_id, p_nng => 340)); --Навички самостійного проживання
        AddParam ('itg3', GetAtSectionSummary (p_at_id, p_nng => 341)); --Здоров’я
        AddParam ('itg4', GetAtSectionSummary (p_at_id, p_nng => 342)); --Соціальна сфера

        ------------------------------------
        rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                         p_rpt_blob   => l_result);
        replace_ekr (l_result);

        RETURN l_result;
    END ACT_DOC_889_R1;

    --#94127 015.3-891-Комплексне визначення ступеня інд.потреб отримувача СП денного догляду
    FUNCTION ACT_DOC_891_R1 (p_at_id IN NUMBER)
        RETURN BLOB
    IS
        CURSOR c_at IS
            SELECT a.at_dt,
                   a.at_sc,
                   a.At_rnspm,
                   a.at_wu,
                   a.at_cu,
                   a.at_ap,
                   (  SELECT (t.atp_ln || ' ' || t.atp_fn || ' ' || t.atp_mn)
                        FROM at_person t
                       WHERE     t.atp_at = a.at_id
                             --and t.atp_sc = a.at_sc
                             AND t.atp_app_tp IN ('OS', 'Z')
                             AND t.history_status = 'A'
                    ORDER BY DECODE (t.atp_app_tp, 'OS', 1, 2)
                       FETCH FIRST ROW ONLY)    AS pib
              FROM act a
             WHERE a.at_id = p_at_id;

        c          c_at%ROWTYPE;

        l_str      VARCHAR2 (32000);

        l_jbr_id   NUMBER;
        l_result   BLOB;

        --для Анкети (uss_ndi.V_DDN_SS_TFN1)
        PROCEDURE AddFtrAnk (p_Param_Name   VARCHAR2,
                             p_atp          at_person.atp_id%TYPE,
                             p_nda          NUMBER)
        IS
        BEGIN
            CASE Get_Ftr (p_at_id => p_at_id, p_atp => p_atp, p_nda => p_nda)
                WHEN 'T'
                THEN
                    AddParam (p_Param_Name, 'Так');
                WHEN 'F'
                THEN
                    AddParam (p_Param_Name, 'Ні');
                ELSE
                    AddParam (p_Param_Name, '--');
            END CASE;
        END;

        FUNCTION ate_indicator_value1 (p_at_id NUMBER, p_nng NUMBER)
            RETURN NUMBER
        IS
        BEGIN
            RETURN Api$Act_Rpt.GetAtSection (p_at_id, p_nng => p_nng).ate_indicator_value1;
        END;
    BEGIN
        rdm$rtfl_univ.initreport (p_code     => 'ACT_DOC_891_R1',
                                  p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);

        ------------------------------------
        OPEN c_at;

        FETCH c_at INTO c;

        CLOSE c_at;

        --Таблиця 2 Шкала оцінювання можливості виконання елементарних дій
        AddParam ('t2.1.1', Get_Ftr_Ind (p_at_id, p_nda => 6334)); --1 Прийом їжі
        AddParam ('t2.1.2', Get_Ftr_Ind (p_at_id, p_nda => 6335));
        AddParam ('t2.1.3', Get_Ftr_Ind (p_at_id, p_nda => 6336));
        AddParam ('t2.1.4', Get_Ftr_Ind (p_at_id, p_nda => 6337));
        AddParam ('t2.1.5', Get_Ftr_Ind (p_at_id, p_nda => 6338));
        AddParam ('t2.1.6', Get_Ftr_Ind (p_at_id, p_nda => 6339));
        AddParam ('t2.1.7', Get_Ftr_Ind (p_at_id, p_nda => 6340));
        AddParam ('t2.1.8', Get_Ftr_Ind (p_at_id, p_nda => 6341));
        AddParam ('t2.1.9', Get_Ftr_Ind (p_at_id, p_nda => 6342));
        AddParam ('t2.2.1', Get_Ftr_Ind (p_at_id, p_nda => 6343)); --2 Купання
        AddParam ('t2.2.2', Get_Ftr_Ind (p_at_id, p_nda => 6344));
        AddParam ('t2.2.3', Get_Ftr_Ind (p_at_id, p_nda => 6345));
        AddParam ('t2.2.4', Get_Ftr_Ind (p_at_id, p_nda => 6346));
        AddParam ('t2.2.5', Get_Ftr_Ind (p_at_id, p_nda => 6347));
        AddParam ('t2.2.6', Get_Ftr_Ind (p_at_id, p_nda => 6348));
        AddParam ('t2.3.1', Get_Ftr_Ind (p_at_id, p_nda => 6349)); --3 Особистий туалет
        AddParam ('t2.3.2', Get_Ftr_Ind (p_at_id, p_nda => 6350));
        AddParam ('t2.3.3', Get_Ftr_Ind (p_at_id, p_nda => 6351));
        AddParam ('t2.3.4', Get_Ftr_Ind (p_at_id, p_nda => 6352));
        AddParam ('t2.3.5', Get_Ftr_Ind (p_at_id, p_nda => 6353));
        AddParam ('t2.3.6', Get_Ftr_Ind (p_at_id, p_nda => 6354));
        AddParam ('t2.4.1', Get_Ftr_Ind (p_at_id, p_nda => 6355)); --4 Одягання і взування
        AddParam ('t2.4.2', Get_Ftr_Ind (p_at_id, p_nda => 6356));
        AddParam ('t2.4.3', Get_Ftr_Ind (p_at_id, p_nda => 6357));
        AddParam ('t2.4.4', Get_Ftr_Ind (p_at_id, p_nda => 6358));
        AddParam ('t2.4.5', Get_Ftr_Ind (p_at_id, p_nda => 6359));
        AddParam ('t2.4.6', Get_Ftr_Ind (p_at_id, p_nda => 6360));
        AddParam ('t2.4.7', Get_Ftr_Ind (p_at_id, p_nda => 6361));
        AddParam ('t2.4.8', Get_Ftr_Ind (p_at_id, p_nda => 6362));
        AddParam ('t2.5.1', Get_Ftr_Ind (p_at_id, p_nda => 6363)); --5 Контроль дефекації
        AddParam ('t2.5.2', Get_Ftr_Ind (p_at_id, p_nda => 6364));
        AddParam ('t2.5.3', Get_Ftr_Ind (p_at_id, p_nda => 6365));
        AddParam ('t2.5.4', Get_Ftr_Ind (p_at_id, p_nda => 6366));
        AddParam ('t2.5.5', Get_Ftr_Ind (p_at_id, p_nda => 6367));
        AddParam ('t2.5.6', Get_Ftr_Ind (p_at_id, p_nda => 6368));
        AddParam ('t2.6.1', Get_Ftr_Ind (p_at_id, p_nda => 6369)); --6 Контроль сечовиділення
        AddParam ('t2.6.2', Get_Ftr_Ind (p_at_id, p_nda => 6370));
        AddParam ('t2.6.3', Get_Ftr_Ind (p_at_id, p_nda => 6371));
        AddParam ('t2.6.4', Get_Ftr_Ind (p_at_id, p_nda => 6372));
        AddParam ('t2.6.5', Get_Ftr_Ind (p_at_id, p_nda => 6373));
        AddParam ('t2.6.6', Get_Ftr_Ind (p_at_id, p_nda => 6374));
        AddParam ('t2.7.1', Get_Ftr_Ind (p_at_id, p_nda => 6375)); --7 Відвідування і здійснення туалету
        AddParam ('t2.7.2', Get_Ftr_Ind (p_at_id, p_nda => 6376));
        AddParam ('t2.7.3', Get_Ftr_Ind (p_at_id, p_nda => 6377));
        AddParam ('t2.7.4', Get_Ftr_Ind (p_at_id, p_nda => 6378));
        AddParam ('t2.7.5', Get_Ftr_Ind (p_at_id, p_nda => 6379));
        AddParam ('t2.7.6', Get_Ftr_Ind (p_at_id, p_nda => 6380));
        AddParam ('t2.7.7', Get_Ftr_Ind (p_at_id, p_nda => 6381));
        AddParam ('t2.8.1', Get_Ftr_Ind (p_at_id, p_nda => 6382)); --8 Вставання й перехід з ліжка
        AddParam ('t2.8.2', Get_Ftr_Ind (p_at_id, p_nda => 6383));
        AddParam ('t2.8.3', Get_Ftr_Ind (p_at_id, p_nda => 6384));
        AddParam ('t2.8.4', Get_Ftr_Ind (p_at_id, p_nda => 6385));
        AddParam ('t2.8.5', Get_Ftr_Ind (p_at_id, p_nda => 6386));
        AddParam ('t2.8.6', Get_Ftr_Ind (p_at_id, p_nda => 6387));
        AddParam ('t2.8.7', Get_Ftr_Ind (p_at_id, p_nda => 6388));
        AddParam ('t2.8.8', Get_Ftr_Ind (p_at_id, p_nda => 6389));
        AddParam ('t2.9.1', Get_Ftr_Ind (p_at_id, p_nda => 6390)); --9 Пересування
        AddParam ('t2.9.2', Get_Ftr_Ind (p_at_id, p_nda => 6391));
        AddParam ('t2.9.3', Get_Ftr_Ind (p_at_id, p_nda => 6392));
        AddParam ('t2.9.4', Get_Ftr_Ind (p_at_id, p_nda => 6393));
        AddParam ('t2.9.5', Get_Ftr_Ind (p_at_id, p_nda => 6394));
        AddParam ('t2.9.6', Get_Ftr_Ind (p_at_id, p_nda => 6395));
        AddParam ('t2.9.7', Get_Ftr_Ind (p_at_id, p_nda => 6396));
        AddParam ('t2.9.8', Get_Ftr_Ind (p_at_id, p_nda => 6397));
        AddParam ('t2.10.1', Get_Ftr_Ind (p_at_id, p_nda => 6398)); --10 Підіймання сходами
        AddParam ('t2.10.2', Get_Ftr_Ind (p_at_id, p_nda => 6399));
        AddParam ('t2.10.3', Get_Ftr_Ind (p_at_id, p_nda => 6400));
        AddParam ('t2.10.4', Get_Ftr_Ind (p_at_id, p_nda => 6401));
        AddParam ('t2.10.5', Get_Ftr_Ind (p_at_id, p_nda => 6402));
        AddParam ('t2.10.6', Get_Ftr_Ind (p_at_id, p_nda => 6403));
        --Сума балів
        AddParam (
            't2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 641).ate_indicator_value1);

        --Таблиця 3 Шкала оцінювання можливості виконання складних дій
        AddParam ('t3.1.1', Get_Ftr_Ind (p_at_id, p_nda => 6404));         --1
        AddParam ('t3.1.2', Get_Ftr_Ind (p_at_id, p_nda => 6405));
        AddParam ('t3.1.3', Get_Ftr_Ind (p_at_id, p_nda => 6406));
        AddParam ('t3.1.4', Get_Ftr_Ind (p_at_id, p_nda => 6407));
        AddParam ('t3.1.5', Get_Ftr_Ind (p_at_id, p_nda => 6408));
        AddParam ('t3.2.1', Get_Ftr_Ind (p_at_id, p_nda => 6409));         --2
        AddParam ('t3.2.2', Get_Ftr_Ind (p_at_id, p_nda => 6410));
        AddParam ('t3.2.3', Get_Ftr_Ind (p_at_id, p_nda => 6411));
        AddParam ('t3.2.4', Get_Ftr_Ind (p_at_id, p_nda => 6412));
        AddParam ('t3.2.5', Get_Ftr_Ind (p_at_id, p_nda => 6413));
        AddParam ('t3.3.1', Get_Ftr_Ind (p_at_id, p_nda => 6414));         --3
        AddParam ('t3.3.2', Get_Ftr_Ind (p_at_id, p_nda => 6415));
        AddParam ('t3.3.3', Get_Ftr_Ind (p_at_id, p_nda => 6416));
        AddParam ('t3.3.4', Get_Ftr_Ind (p_at_id, p_nda => 6417));
        AddParam ('t3.4.1', Get_Ftr_Ind (p_at_id, p_nda => 6418));         --4
        AddParam ('t3.4.2', Get_Ftr_Ind (p_at_id, p_nda => 6419));
        AddParam ('t3.4.3', Get_Ftr_Ind (p_at_id, p_nda => 6420));
        AddParam ('t3.4.4', Get_Ftr_Ind (p_at_id, p_nda => 6421));
        AddParam ('t3.4.5', Get_Ftr_Ind (p_at_id, p_nda => 6422));
        AddParam ('t3.5.1', Get_Ftr_Ind (p_at_id, p_nda => 6423));         --5
        AddParam ('t3.5.2', Get_Ftr_Ind (p_at_id, p_nda => 6424));
        AddParam ('t3.5.3', Get_Ftr_Ind (p_at_id, p_nda => 6425));
        AddParam ('t3.5.4', Get_Ftr_Ind (p_at_id, p_nda => 6426));
        AddParam ('t3.5.5', Get_Ftr_Ind (p_at_id, p_nda => 6427));
        AddParam ('t3.6.1', Get_Ftr_Ind (p_at_id, p_nda => 6428));         --6
        AddParam ('t3.6.2', Get_Ftr_Ind (p_at_id, p_nda => 6429));
        AddParam ('t3.6.3', Get_Ftr_Ind (p_at_id, p_nda => 6430));
        AddParam ('t3.6.4', Get_Ftr_Ind (p_at_id, p_nda => 6431));
        AddParam ('t3.7.1', Get_Ftr_Ind (p_at_id, p_nda => 6432));         --7
        AddParam ('t3.7.2', Get_Ftr_Ind (p_at_id, p_nda => 6433));
        AddParam ('t3.7.3', Get_Ftr_Ind (p_at_id, p_nda => 6434));
        AddParam ('t3.7.4', Get_Ftr_Ind (p_at_id, p_nda => 6435));
        AddParam ('t3.7.5', Get_Ftr_Ind (p_at_id, p_nda => 6436));
        AddParam ('t3.8.1', Get_Ftr_Ind (p_at_id, p_nda => 6437));         --8
        AddParam ('t3.8.2', Get_Ftr_Ind (p_at_id, p_nda => 6438));
        AddParam ('t3.8.3', Get_Ftr_Ind (p_at_id, p_nda => 6439));
        AddParam ('t3.8.4', Get_Ftr_Ind (p_at_id, p_nda => 6440));
        AddParam ('t3.9.1', Get_Ftr_Ind (p_at_id, p_nda => 6441));         --9
        AddParam ('t3.9.2', Get_Ftr_Ind (p_at_id, p_nda => 6442));
        AddParam ('t3.9.3', Get_Ftr_Ind (p_at_id, p_nda => 6443));
        AddParam ('t3.9.4', Get_Ftr_Ind (p_at_id, p_nda => 6444));
        --Сума балів
        AddParam (
            't3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 641).ate_indicator_value2);

        --Таблиця 4 Шкала оцінювання навичок проживання за основними категоріями
        --1 Управління фінансами
        AddParam ('t4.1', Get_Ftr_Chk2 (p_at_id, p_nda => 6445));
        AddParam ('t4.2', Get_Ftr_Chk2 (p_at_id, p_nda => 6446));
        AddParam ('t4.3', Get_Ftr_Chk2 (p_at_id, p_nda => 6447));
        AddParam ('t4.4', Get_Ftr_Chk2 (p_at_id, p_nda => 6448));
        AddParam ('t4.5', Get_Ftr_Chk2 (p_at_id, p_nda => 6449));
        AddParam ('t4.6', Get_Ftr_Chk2 (p_at_id, p_nda => 6450));
        AddParam ('t4.7', Get_Ftr_Chk2 (p_at_id, p_nda => 6451));
        AddParam ('t4.8', Get_Ftr_Chk2 (p_at_id, p_nda => 6452));
        AddParam ('t4.9', Get_Ftr_Chk2 (p_at_id, p_nda => 6453));
        AddParam ('t4.10', Get_Ftr_Chk2 (p_at_id, p_nda => 6454));
        AddParam ('t4.11', Get_Ftr_Chk2 (p_at_id, p_nda => 6455));
        AddParam ('t4.12', Get_Ftr_Chk2 (p_at_id, p_nda => 6456));
        AddParam ('t4.13', Get_Ftr_Chk2 (p_at_id, p_nda => 6457));
        AddParam ('t4.14', Get_Ftr_Chk2 (p_at_id, p_nda => 6458));
        AddParam ('t4.15', Get_Ftr_Chk2 (p_at_id, p_nda => 6459));
        AddParam ('t4.16', Get_Ftr_Chk2 (p_at_id, p_nda => 6460));
        AddParam ('t4.17', Get_Ftr_Chk2 (p_at_id, p_nda => 6461));
        AddParam ('t4.18', Get_Ftr_Chk2 (p_at_id, p_nda => 6462));
        AddParam ('t4.19', Get_Ftr_Chk2 (p_at_id, p_nda => 6463));
        AddParam ('t4.20', Get_Ftr_Chk2 (p_at_id, p_nda => 6464));
        AddParam ('t4.21', Get_Ftr_Chk2 (p_at_id, p_nda => 6465));
        AddParam ('t4.22', Get_Ftr_Chk2 (p_at_id, p_nda => 6466));
        AddParam ('t4.23', Get_Ftr_Chk2 (p_at_id, p_nda => 6467));
        AddParam ('t4.24', Get_Ftr_Chk2 (p_at_id, p_nda => 6468));
        AddParam ('t4.25', Get_Ftr_Chk2 (p_at_id, p_nda => 6469));
        --Організація харчування
        AddParam ('t4.26', Get_Ftr_Chk2 (p_at_id, p_nda => 6470));
        AddParam ('t4.27', Get_Ftr_Chk2 (p_at_id, p_nda => 6471));
        AddParam ('t4.28', Get_Ftr_Chk2 (p_at_id, p_nda => 6472));
        AddParam ('t4.29', Get_Ftr_Chk2 (p_at_id, p_nda => 6473));
        AddParam ('t4.30', Get_Ftr_Chk2 (p_at_id, p_nda => 6474));
        AddParam ('t4.31', Get_Ftr_Chk2 (p_at_id, p_nda => 6475));
        AddParam ('t4.32', Get_Ftr_Chk2 (p_at_id, p_nda => 6476));
        AddParam ('t4.33', Get_Ftr_Chk2 (p_at_id, p_nda => 6477));
        AddParam ('t4.34', Get_Ftr_Chk2 (p_at_id, p_nda => 6478));
        AddParam ('t4.35', Get_Ftr_Chk2 (p_at_id, p_nda => 6479));
        AddParam ('t4.36', Get_Ftr_Chk2 (p_at_id, p_nda => 6480));
        AddParam ('t4.37', Get_Ftr_Chk2 (p_at_id, p_nda => 6481));
        AddParam ('t4.38', Get_Ftr_Chk2 (p_at_id, p_nda => 6482));
        AddParam ('t4.39', Get_Ftr_Chk2 (p_at_id, p_nda => 6483));
        AddParam ('t4.40', Get_Ftr_Chk2 (p_at_id, p_nda => 6484));
        AddParam ('t4.41', Get_Ftr_Chk2 (p_at_id, p_nda => 6485));
        AddParam ('t4.42', Get_Ftr_Chk2 (p_at_id, p_nda => 6486));
        AddParam ('t4.43', Get_Ftr_Chk2 (p_at_id, p_nda => 6487));
        AddParam ('t4.44', Get_Ftr_Chk2 (p_at_id, p_nda => 6488));
        AddParam ('t4.45', Get_Ftr_Chk2 (p_at_id, p_nda => 6489));
        AddParam ('t4.46', Get_Ftr_Chk2 (p_at_id, p_nda => 6490));
        AddParam ('t4.47', Get_Ftr_Chk2 (p_at_id, p_nda => 6491));
        AddParam ('t4.48', Get_Ftr_Chk2 (p_at_id, p_nda => 6492));
        AddParam ('t4.49', Get_Ftr_Chk2 (p_at_id, p_nda => 6493));
        AddParam ('t4.50', Get_Ftr_Chk2 (p_at_id, p_nda => 6494));
        --Зовнішній вигляд, дотримання правил особистої гігієни
        AddParam ('t4.51', Get_Ftr_Chk2 (p_at_id, p_nda => 6495));
        AddParam ('t4.52', Get_Ftr_Chk2 (p_at_id, p_nda => 6496));
        AddParam ('t4.53', Get_Ftr_Chk2 (p_at_id, p_nda => 6497));
        AddParam ('t4.54', Get_Ftr_Chk2 (p_at_id, p_nda => 6498));
        AddParam ('t4.55', Get_Ftr_Chk2 (p_at_id, p_nda => 6499));
        AddParam ('t4.56', Get_Ftr_Chk2 (p_at_id, p_nda => 6500));
        AddParam ('t4.57', Get_Ftr_Chk2 (p_at_id, p_nda => 6501));
        AddParam ('t4.58', Get_Ftr_Chk2 (p_at_id, p_nda => 6502));
        AddParam ('t4.59', Get_Ftr_Chk2 (p_at_id, p_nda => 6503));
        AddParam ('t4.60', Get_Ftr_Chk2 (p_at_id, p_nda => 6504));
        AddParam ('t4.61', Get_Ftr_Chk2 (p_at_id, p_nda => 6505));
        AddParam ('t4.62', Get_Ftr_Chk2 (p_at_id, p_nda => 6506));
        AddParam ('t4.63', Get_Ftr_Chk2 (p_at_id, p_nda => 6507));
        AddParam ('t4.64', Get_Ftr_Chk2 (p_at_id, p_nda => 6508));
        AddParam ('t4.65', Get_Ftr_Chk2 (p_at_id, p_nda => 6509));
        AddParam ('t4.66', Get_Ftr_Chk2 (p_at_id, p_nda => 6510));
        AddParam ('t4.67', Get_Ftr_Chk2 (p_at_id, p_nda => 6511));
        AddParam ('t4.68', Get_Ftr_Chk2 (p_at_id, p_nda => 6512));
        AddParam ('t4.69', Get_Ftr_Chk2 (p_at_id, p_nda => 6513));
        AddParam ('t4.70', Get_Ftr_Chk2 (p_at_id, p_nda => 6514));
        AddParam ('t4.71', Get_Ftr_Chk2 (p_at_id, p_nda => 6515));
        AddParam ('t4.72', Get_Ftr_Chk2 (p_at_id, p_nda => 6516));
        AddParam ('t4.73', Get_Ftr_Chk2 (p_at_id, p_nda => 6517));
        AddParam ('t4.74', Get_Ftr_Chk2 (p_at_id, p_nda => 6518));
        AddParam ('t4.75', Get_Ftr_Chk2 (p_at_id, p_nda => 6519));
        --Здоров’я
        AddParam ('t4.76', Get_Ftr_Chk2 (p_at_id, p_nda => 6520));
        AddParam ('t4.77', Get_Ftr_Chk2 (p_at_id, p_nda => 6521));
        AddParam ('t4.78', Get_Ftr_Chk2 (p_at_id, p_nda => 6522));
        AddParam ('t4.79', Get_Ftr_Chk2 (p_at_id, p_nda => 6523));
        AddParam ('t4.80', Get_Ftr_Chk2 (p_at_id, p_nda => 6524));
        AddParam ('t4.81', Get_Ftr_Chk2 (p_at_id, p_nda => 6525));
        AddParam ('t4.82', Get_Ftr_Chk2 (p_at_id, p_nda => 6526));
        AddParam ('t4.83', Get_Ftr_Chk2 (p_at_id, p_nda => 6527));
        AddParam ('t4.84', Get_Ftr_Chk2 (p_at_id, p_nda => 6528));
        AddParam ('t4.85', Get_Ftr_Chk2 (p_at_id, p_nda => 6529));
        AddParam ('t4.86', Get_Ftr_Chk2 (p_at_id, p_nda => 6530));
        AddParam ('t4.87', Get_Ftr_Chk2 (p_at_id, p_nda => 6531));
        AddParam ('t4.88', Get_Ftr_Chk2 (p_at_id, p_nda => 6532));
        AddParam ('t4.89', Get_Ftr_Chk2 (p_at_id, p_nda => 6533));
        AddParam ('t4.90', Get_Ftr_Chk2 (p_at_id, p_nda => 6534));
        AddParam ('t4.91', Get_Ftr_Chk2 (p_at_id, p_nda => 6535));
        AddParam ('t4.92', Get_Ftr_Chk2 (p_at_id, p_nda => 6536));
        AddParam ('t4.93', Get_Ftr_Chk2 (p_at_id, p_nda => 6537));
        AddParam ('t4.94', Get_Ftr_Chk2 (p_at_id, p_nda => 6538));
        AddParam ('t4.95', Get_Ftr_Chk2 (p_at_id, p_nda => 6539));
        AddParam ('t4.96', Get_Ftr_Chk2 (p_at_id, p_nda => 6540));
        AddParam ('t4.97', Get_Ftr_Chk2 (p_at_id, p_nda => 6541));
        AddParam ('t4.98', Get_Ftr_Chk2 (p_at_id, p_nda => 6542));
        AddParam ('t4.99', Get_Ftr_Chk2 (p_at_id, p_nda => 6543));
        AddParam ('t4.100', Get_Ftr_Chk2 (p_at_id, p_nda => 6544));
        --Утримання помешкання
        AddParam ('t4.101', Get_Ftr_Chk2 (p_at_id, p_nda => 6545));
        AddParam ('t4.102', Get_Ftr_Chk2 (p_at_id, p_nda => 6546));
        AddParam ('t4.103', Get_Ftr_Chk2 (p_at_id, p_nda => 6547));
        AddParam ('t4.104', Get_Ftr_Chk2 (p_at_id, p_nda => 6548));
        AddParam ('t4.105', Get_Ftr_Chk2 (p_at_id, p_nda => 6549));
        AddParam ('t4.106', Get_Ftr_Chk2 (p_at_id, p_nda => 6550));
        AddParam ('t4.107', Get_Ftr_Chk2 (p_at_id, p_nda => 6551));
        AddParam ('t4.108', Get_Ftr_Chk2 (p_at_id, p_nda => 6552));
        AddParam ('t4.109', Get_Ftr_Chk2 (p_at_id, p_nda => 6553));
        AddParam ('t4.110', Get_Ftr_Chk2 (p_at_id, p_nda => 6554));
        AddParam ('t4.111', Get_Ftr_Chk2 (p_at_id, p_nda => 6555));
        AddParam ('t4.112', Get_Ftr_Chk2 (p_at_id, p_nda => 6556));
        AddParam ('t4.113', Get_Ftr_Chk2 (p_at_id, p_nda => 6557));
        AddParam ('t4.114', Get_Ftr_Chk2 (p_at_id, p_nda => 6558));
        AddParam ('t4.115', Get_Ftr_Chk2 (p_at_id, p_nda => 6559));
        AddParam ('t4.116', Get_Ftr_Chk2 (p_at_id, p_nda => 6560));
        AddParam ('t4.117', Get_Ftr_Chk2 (p_at_id, p_nda => 6561));
        AddParam ('t4.118', Get_Ftr_Chk2 (p_at_id, p_nda => 6562));
        AddParam ('t4.119', Get_Ftr_Chk2 (p_at_id, p_nda => 6563));
        AddParam ('t4.120', Get_Ftr_Chk2 (p_at_id, p_nda => 6564));
        AddParam ('t4.121', Get_Ftr_Chk2 (p_at_id, p_nda => 6565));
        AddParam ('t4.122', Get_Ftr_Chk2 (p_at_id, p_nda => 6566));
        AddParam ('t4.123', Get_Ftr_Chk2 (p_at_id, p_nda => 6567));
        AddParam ('t4.124', Get_Ftr_Chk2 (p_at_id, p_nda => 6568));
        AddParam ('t4.125', Get_Ftr_Chk2 (p_at_id, p_nda => 6569));
        --Обізнаність у сфері нерухомості
        AddParam ('t4.126', Get_Ftr_Chk2 (p_at_id, p_nda => 6570));
        AddParam ('t4.127', Get_Ftr_Chk2 (p_at_id, p_nda => 6571));
        AddParam ('t4.128', Get_Ftr_Chk2 (p_at_id, p_nda => 6572));
        AddParam ('t4.129', Get_Ftr_Chk2 (p_at_id, p_nda => 6573));
        AddParam ('t4.130', Get_Ftr_Chk2 (p_at_id, p_nda => 6574));
        AddParam ('t4.131', Get_Ftr_Chk2 (p_at_id, p_nda => 6575));
        AddParam ('t4.132', Get_Ftr_Chk2 (p_at_id, p_nda => 6576));
        AddParam ('t4.133', Get_Ftr_Chk2 (p_at_id, p_nda => 6577));
        AddParam ('t4.134', Get_Ftr_Chk2 (p_at_id, p_nda => 6578));
        AddParam ('t4.135', Get_Ftr_Chk2 (p_at_id, p_nda => 6579));
        AddParam ('t4.136', Get_Ftr_Chk2 (p_at_id, p_nda => 6580));
        AddParam ('t4.137', Get_Ftr_Chk2 (p_at_id, p_nda => 6581));
        AddParam ('t4.138', Get_Ftr_Chk2 (p_at_id, p_nda => 6582));
        AddParam ('t4.139', Get_Ftr_Chk2 (p_at_id, p_nda => 6583));
        AddParam ('t4.140', Get_Ftr_Chk2 (p_at_id, p_nda => 6584));
        AddParam ('t4.141', Get_Ftr_Chk2 (p_at_id, p_nda => 6585));
        AddParam ('t4.142', Get_Ftr_Chk2 (p_at_id, p_nda => 6586));
        AddParam ('t4.143', Get_Ftr_Chk2 (p_at_id, p_nda => 6587));
        AddParam ('t4.144', Get_Ftr_Chk2 (p_at_id, p_nda => 6588));
        AddParam ('t4.145', Get_Ftr_Chk2 (p_at_id, p_nda => 6589));
        AddParam ('t4.146', Get_Ftr_Chk2 (p_at_id, p_nda => 6590));
        AddParam ('t4.147', Get_Ftr_Chk2 (p_at_id, p_nda => 6591));
        AddParam ('t4.148', Get_Ftr_Chk2 (p_at_id, p_nda => 6592));
        AddParam ('t4.149', Get_Ftr_Chk2 (p_at_id, p_nda => 6593));
        AddParam ('t4.150', Get_Ftr_Chk2 (p_at_id, p_nda => 6594));
        --Користування транспортом
        AddParam ('t4.151', Get_Ftr_Chk2 (p_at_id, p_nda => 6595));
        AddParam ('t4.152', Get_Ftr_Chk2 (p_at_id, p_nda => 6596));
        AddParam ('t4.153', Get_Ftr_Chk2 (p_at_id, p_nda => 6597));
        AddParam ('t4.154', Get_Ftr_Chk2 (p_at_id, p_nda => 6598));
        AddParam ('t4.155', Get_Ftr_Chk2 (p_at_id, p_nda => 6599));
        AddParam ('t4.156', Get_Ftr_Chk2 (p_at_id, p_nda => 6600));
        AddParam ('t4.157', Get_Ftr_Chk2 (p_at_id, p_nda => 6601));
        AddParam ('t4.158', Get_Ftr_Chk2 (p_at_id, p_nda => 6602));
        AddParam ('t4.159', Get_Ftr_Chk2 (p_at_id, p_nda => 6603));
        AddParam ('t4.160', Get_Ftr_Chk2 (p_at_id, p_nda => 6604));
        AddParam ('t4.161', Get_Ftr_Chk2 (p_at_id, p_nda => 6605));
        AddParam ('t4.162', Get_Ftr_Chk2 (p_at_id, p_nda => 6606));
        AddParam ('t4.163', Get_Ftr_Chk2 (p_at_id, p_nda => 6607));
        AddParam ('t4.164', Get_Ftr_Chk2 (p_at_id, p_nda => 6608));
        AddParam ('t4.165', Get_Ftr_Chk2 (p_at_id, p_nda => 6609));
        AddParam ('t4.166', Get_Ftr_Chk2 (p_at_id, p_nda => 6610));
        AddParam ('t4.167', Get_Ftr_Chk2 (p_at_id, p_nda => 6611));
        AddParam ('t4.168', Get_Ftr_Chk2 (p_at_id, p_nda => 6612));
        AddParam ('t4.169', Get_Ftr_Chk2 (p_at_id, p_nda => 6613));
        AddParam ('t4.170', Get_Ftr_Chk2 (p_at_id, p_nda => 6614));
        AddParam ('t4.171', Get_Ftr_Chk2 (p_at_id, p_nda => 6615));
        AddParam ('t4.172', Get_Ftr_Chk2 (p_at_id, p_nda => 6616));
        AddParam ('t4.173', Get_Ftr_Chk2 (p_at_id, p_nda => 6617));
        AddParam ('t4.174', Get_Ftr_Chk2 (p_at_id, p_nda => 6618));
        AddParam ('t4.175', Get_Ftr_Chk2 (p_at_id, p_nda => 6619));
        --Організація навчального процесу
        AddParam ('t4.176', Get_Ftr_Chk2 (p_at_id, p_nda => 6620));
        AddParam ('t4.177', Get_Ftr_Chk2 (p_at_id, p_nda => 6621));
        AddParam ('t4.178', Get_Ftr_Chk2 (p_at_id, p_nda => 6622));
        AddParam ('t4.179', Get_Ftr_Chk2 (p_at_id, p_nda => 6623));
        AddParam ('t4.180', Get_Ftr_Chk2 (p_at_id, p_nda => 6624));
        AddParam ('t4.181', Get_Ftr_Chk2 (p_at_id, p_nda => 6625));
        AddParam ('t4.182', Get_Ftr_Chk2 (p_at_id, p_nda => 6626));
        AddParam ('t4.183', Get_Ftr_Chk2 (p_at_id, p_nda => 6627));
        AddParam ('t4.184', Get_Ftr_Chk2 (p_at_id, p_nda => 6628));
        AddParam ('t4.185', Get_Ftr_Chk2 (p_at_id, p_nda => 6629));
        AddParam ('t4.186', Get_Ftr_Chk2 (p_at_id, p_nda => 6630));
        AddParam ('t4.187', Get_Ftr_Chk2 (p_at_id, p_nda => 6631));
        AddParam ('t4.188', Get_Ftr_Chk2 (p_at_id, p_nda => 6632));
        AddParam ('t4.189', Get_Ftr_Chk2 (p_at_id, p_nda => 6633));
        AddParam ('t4.190', Get_Ftr_Chk2 (p_at_id, p_nda => 6634));
        AddParam ('t4.191', Get_Ftr_Chk2 (p_at_id, p_nda => 6635));
        AddParam ('t4.192', Get_Ftr_Chk2 (p_at_id, p_nda => 6636));
        AddParam ('t4.193', Get_Ftr_Chk2 (p_at_id, p_nda => 6637));
        AddParam ('t4.194', Get_Ftr_Chk2 (p_at_id, p_nda => 6638));
        AddParam ('t4.195', Get_Ftr_Chk2 (p_at_id, p_nda => 6639));
        AddParam ('t4.196', Get_Ftr_Chk2 (p_at_id, p_nda => 6640));
        AddParam ('t4.197', Get_Ftr_Chk2 (p_at_id, p_nda => 6641));
        AddParam ('t4.198', Get_Ftr_Chk2 (p_at_id, p_nda => 6642));
        AddParam ('t4.199', Get_Ftr_Chk2 (p_at_id, p_nda => 6643));
        AddParam ('t4.200', Get_Ftr_Chk2 (p_at_id, p_nda => 6644));
        --Навички пошуку роботи
        AddParam ('t4.201', Get_Ftr_Chk2 (p_at_id, p_nda => 6645));
        AddParam ('t4.202', Get_Ftr_Chk2 (p_at_id, p_nda => 6646));
        AddParam ('t4.203', Get_Ftr_Chk2 (p_at_id, p_nda => 6647));
        AddParam ('t4.204', Get_Ftr_Chk2 (p_at_id, p_nda => 6648));
        AddParam ('t4.205', Get_Ftr_Chk2 (p_at_id, p_nda => 6649));
        AddParam ('t4.206', Get_Ftr_Chk2 (p_at_id, p_nda => 6650));
        AddParam ('t4.207', Get_Ftr_Chk2 (p_at_id, p_nda => 6651));
        AddParam ('t4.208', Get_Ftr_Chk2 (p_at_id, p_nda => 6652));
        AddParam ('t4.209', Get_Ftr_Chk2 (p_at_id, p_nda => 6653));
        AddParam ('t4.210', Get_Ftr_Chk2 (p_at_id, p_nda => 6654));
        AddParam ('t4.211', Get_Ftr_Chk2 (p_at_id, p_nda => 6655));
        AddParam ('t4.212', Get_Ftr_Chk2 (p_at_id, p_nda => 6656));
        AddParam ('t4.213', Get_Ftr_Chk2 (p_at_id, p_nda => 6657));
        AddParam ('t4.214', Get_Ftr_Chk2 (p_at_id, p_nda => 6658));
        AddParam ('t4.215', Get_Ftr_Chk2 (p_at_id, p_nda => 6659));
        AddParam ('t4.216', Get_Ftr_Chk2 (p_at_id, p_nda => 6660));
        AddParam ('t4.217', Get_Ftr_Chk2 (p_at_id, p_nda => 6661));
        AddParam ('t4.218', Get_Ftr_Chk2 (p_at_id, p_nda => 6662));
        AddParam ('t4.219', Get_Ftr_Chk2 (p_at_id, p_nda => 6663));
        AddParam ('t4.220', Get_Ftr_Chk2 (p_at_id, p_nda => 6664));
        AddParam ('t4.221', Get_Ftr_Chk2 (p_at_id, p_nda => 6665));
        AddParam ('t4.222', Get_Ftr_Chk2 (p_at_id, p_nda => 6666));
        AddParam ('t4.223', Get_Ftr_Chk2 (p_at_id, p_nda => 6667));
        AddParam ('t4.224', Get_Ftr_Chk2 (p_at_id, p_nda => 6668));
        AddParam ('t4.225', Get_Ftr_Chk2 (p_at_id, p_nda => 6669));
        --Організація роботи (зайнятості)
        AddParam ('t4.226', Get_Ftr_Chk2 (p_at_id, p_nda => 6670));
        AddParam ('t4.227', Get_Ftr_Chk2 (p_at_id, p_nda => 6671));
        AddParam ('t4.228', Get_Ftr_Chk2 (p_at_id, p_nda => 6672));
        AddParam ('t4.229', Get_Ftr_Chk2 (p_at_id, p_nda => 6673));
        AddParam ('t4.230', Get_Ftr_Chk2 (p_at_id, p_nda => 6674));
        AddParam ('t4.231', Get_Ftr_Chk2 (p_at_id, p_nda => 6675));
        AddParam ('t4.232', Get_Ftr_Chk2 (p_at_id, p_nda => 6676));
        AddParam ('t4.233', Get_Ftr_Chk2 (p_at_id, p_nda => 6677));
        AddParam ('t4.234', Get_Ftr_Chk2 (p_at_id, p_nda => 6678));
        AddParam ('t4.235', Get_Ftr_Chk2 (p_at_id, p_nda => 6679));
        AddParam ('t4.236', Get_Ftr_Chk2 (p_at_id, p_nda => 6680));
        AddParam ('t4.237', Get_Ftr_Chk2 (p_at_id, p_nda => 6681));
        AddParam ('t4.238', Get_Ftr_Chk2 (p_at_id, p_nda => 6682));
        AddParam ('t4.239', Get_Ftr_Chk2 (p_at_id, p_nda => 6683));
        AddParam ('t4.240', Get_Ftr_Chk2 (p_at_id, p_nda => 6684));
        AddParam ('t4.241', Get_Ftr_Chk2 (p_at_id, p_nda => 6685));
        AddParam ('t4.242', Get_Ftr_Chk2 (p_at_id, p_nda => 6686));
        AddParam ('t4.243', Get_Ftr_Chk2 (p_at_id, p_nda => 6687));
        AddParam ('t4.244', Get_Ftr_Chk2 (p_at_id, p_nda => 6688));
        AddParam ('t4.245', Get_Ftr_Chk2 (p_at_id, p_nda => 6689));
        AddParam ('t4.246', Get_Ftr_Chk2 (p_at_id, p_nda => 6690));
        AddParam ('t4.247', Get_Ftr_Chk2 (p_at_id, p_nda => 6691));
        AddParam ('t4.248', Get_Ftr_Chk2 (p_at_id, p_nda => 6692));
        AddParam ('t4.249', Get_Ftr_Chk2 (p_at_id, p_nda => 6693));
        AddParam ('t4.250', Get_Ftr_Chk2 (p_at_id, p_nda => 6694));
        --Дотримання правил безпеки та поведінки
        AddParam ('t4.251', Get_Ftr_Chk2 (p_at_id, p_nda => 6695));
        AddParam ('t4.252', Get_Ftr_Chk2 (p_at_id, p_nda => 6696));
        AddParam ('t4.253', Get_Ftr_Chk2 (p_at_id, p_nda => 6697));
        AddParam ('t4.254', Get_Ftr_Chk2 (p_at_id, p_nda => 6698));
        AddParam ('t4.255', Get_Ftr_Chk2 (p_at_id, p_nda => 6699));
        AddParam ('t4.256', Get_Ftr_Chk2 (p_at_id, p_nda => 6700));
        AddParam ('t4.257', Get_Ftr_Chk2 (p_at_id, p_nda => 6701));
        AddParam ('t4.258', Get_Ftr_Chk2 (p_at_id, p_nda => 6702));
        AddParam ('t4.259', Get_Ftr_Chk2 (p_at_id, p_nda => 6703));
        AddParam ('t4.260', Get_Ftr_Chk2 (p_at_id, p_nda => 6704));
        AddParam ('t4.261', Get_Ftr_Chk2 (p_at_id, p_nda => 6705));
        AddParam ('t4.262', Get_Ftr_Chk2 (p_at_id, p_nda => 6706));
        AddParam ('t4.263', Get_Ftr_Chk2 (p_at_id, p_nda => 6707));
        AddParam ('t4.264', Get_Ftr_Chk2 (p_at_id, p_nda => 6708));
        AddParam ('t4.265', Get_Ftr_Chk2 (p_at_id, p_nda => 6709));
        AddParam ('t4.266', Get_Ftr_Chk2 (p_at_id, p_nda => 6710));
        AddParam ('t4.267', Get_Ftr_Chk2 (p_at_id, p_nda => 6711));
        AddParam ('t4.268', Get_Ftr_Chk2 (p_at_id, p_nda => 6712));
        AddParam ('t4.269', Get_Ftr_Chk2 (p_at_id, p_nda => 6713));
        AddParam ('t4.270', Get_Ftr_Chk2 (p_at_id, p_nda => 6714));
        AddParam ('t4.271', Get_Ftr_Chk2 (p_at_id, p_nda => 6715));
        AddParam ('t4.272', Get_Ftr_Chk2 (p_at_id, p_nda => 6716));
        AddParam ('t4.273', Get_Ftr_Chk2 (p_at_id, p_nda => 6717));
        AddParam ('t4.274', Get_Ftr_Chk2 (p_at_id, p_nda => 6718));
        AddParam ('t4.275', Get_Ftr_Chk2 (p_at_id, p_nda => 6719));
        --Знання ресурсів громади
        AddParam ('t4.276', Get_Ftr_Chk2 (p_at_id, p_nda => 6720));
        AddParam ('t4.277', Get_Ftr_Chk2 (p_at_id, p_nda => 6721));
        AddParam ('t4.278', Get_Ftr_Chk2 (p_at_id, p_nda => 6722));
        AddParam ('t4.279', Get_Ftr_Chk2 (p_at_id, p_nda => 6723));
        AddParam ('t4.280', Get_Ftr_Chk2 (p_at_id, p_nda => 6724));
        AddParam ('t4.281', Get_Ftr_Chk2 (p_at_id, p_nda => 6725));
        AddParam ('t4.282', Get_Ftr_Chk2 (p_at_id, p_nda => 6726));
        AddParam ('t4.283', Get_Ftr_Chk2 (p_at_id, p_nda => 6727));
        AddParam ('t4.284', Get_Ftr_Chk2 (p_at_id, p_nda => 6728));
        AddParam ('t4.285', Get_Ftr_Chk2 (p_at_id, p_nda => 6729));
        AddParam ('t4.286', Get_Ftr_Chk2 (p_at_id, p_nda => 6730));
        AddParam ('t4.287', Get_Ftr_Chk2 (p_at_id, p_nda => 6731));
        AddParam ('t4.288', Get_Ftr_Chk2 (p_at_id, p_nda => 6732));
        AddParam ('t4.289', Get_Ftr_Chk2 (p_at_id, p_nda => 6733));
        AddParam ('t4.290', Get_Ftr_Chk2 (p_at_id, p_nda => 6734));
        AddParam ('t4.291', Get_Ftr_Chk2 (p_at_id, p_nda => 6735));
        AddParam ('t4.292', Get_Ftr_Chk2 (p_at_id, p_nda => 6736));
        AddParam ('t4.293', Get_Ftr_Chk2 (p_at_id, p_nda => 6737));
        AddParam ('t4.294', Get_Ftr_Chk2 (p_at_id, p_nda => 6738));
        AddParam ('t4.295', Get_Ftr_Chk2 (p_at_id, p_nda => 6739));
        AddParam ('t4.296', Get_Ftr_Chk2 (p_at_id, p_nda => 6740));
        AddParam ('t4.297', Get_Ftr_Chk2 (p_at_id, p_nda => 6741));
        AddParam ('t4.298', Get_Ftr_Chk2 (p_at_id, p_nda => 6742));
        AddParam ('t4.299', Get_Ftr_Chk2 (p_at_id, p_nda => 6743));
        AddParam ('t4.300', Get_Ftr_Chk2 (p_at_id, p_nda => 6744));
        --Міжособистісні відносини
        AddParam ('t4.301', Get_Ftr_Chk2 (p_at_id, p_nda => 6745));
        AddParam ('t4.302', Get_Ftr_Chk2 (p_at_id, p_nda => 6746));
        AddParam ('t4.303', Get_Ftr_Chk2 (p_at_id, p_nda => 6747));
        AddParam ('t4.304', Get_Ftr_Chk2 (p_at_id, p_nda => 6748));
        AddParam ('t4.305', Get_Ftr_Chk2 (p_at_id, p_nda => 6749));
        AddParam ('t4.306', Get_Ftr_Chk2 (p_at_id, p_nda => 6750));
        AddParam ('t4.307', Get_Ftr_Chk2 (p_at_id, p_nda => 6751));
        AddParam ('t4.308', Get_Ftr_Chk2 (p_at_id, p_nda => 6752));
        AddParam ('t4.309', Get_Ftr_Chk2 (p_at_id, p_nda => 6753));
        AddParam ('t4.310', Get_Ftr_Chk2 (p_at_id, p_nda => 6754));
        AddParam ('t4.311', Get_Ftr_Chk2 (p_at_id, p_nda => 6755));
        AddParam ('t4.312', Get_Ftr_Chk2 (p_at_id, p_nda => 6756));
        AddParam ('t4.313', Get_Ftr_Chk2 (p_at_id, p_nda => 6757));
        AddParam ('t4.314', Get_Ftr_Chk2 (p_at_id, p_nda => 6758));
        AddParam ('t4.315', Get_Ftr_Chk2 (p_at_id, p_nda => 6759));
        AddParam ('t4.316', Get_Ftr_Chk2 (p_at_id, p_nda => 6760));
        AddParam ('t4.317', Get_Ftr_Chk2 (p_at_id, p_nda => 6761));
        AddParam ('t4.318', Get_Ftr_Chk2 (p_at_id, p_nda => 6762));
        AddParam ('t4.319', Get_Ftr_Chk2 (p_at_id, p_nda => 6763));
        AddParam ('t4.320', Get_Ftr_Chk2 (p_at_id, p_nda => 6764));
        AddParam ('t4.321', Get_Ftr_Chk2 (p_at_id, p_nda => 6765));
        AddParam ('t4.322', Get_Ftr_Chk2 (p_at_id, p_nda => 6766));
        AddParam ('t4.323', Get_Ftr_Chk2 (p_at_id, p_nda => 6767));
        AddParam ('t4.324', Get_Ftr_Chk2 (p_at_id, p_nda => 6768));
        AddParam ('t4.325', Get_Ftr_Chk2 (p_at_id, p_nda => 6769));
        --Обізнаність у юридичній сфері
        AddParam ('t4.326', Get_Ftr_Chk2 (p_at_id, p_nda => 6770));
        AddParam ('t4.327', Get_Ftr_Chk2 (p_at_id, p_nda => 6771));
        AddParam ('t4.328', Get_Ftr_Chk2 (p_at_id, p_nda => 6772));
        AddParam ('t4.329', Get_Ftr_Chk2 (p_at_id, p_nda => 6773));
        AddParam ('t4.330', Get_Ftr_Chk2 (p_at_id, p_nda => 6774));
        AddParam ('t4.331', Get_Ftr_Chk2 (p_at_id, p_nda => 6775));
        AddParam ('t4.332', Get_Ftr_Chk2 (p_at_id, p_nda => 6776));
        AddParam ('t4.333', Get_Ftr_Chk2 (p_at_id, p_nda => 6777));
        AddParam ('t4.334', Get_Ftr_Chk2 (p_at_id, p_nda => 6778));
        AddParam ('t4.335', Get_Ftr_Chk2 (p_at_id, p_nda => 6779));
        AddParam ('t4.336', Get_Ftr_Chk2 (p_at_id, p_nda => 6780));
        AddParam ('t4.337', Get_Ftr_Chk2 (p_at_id, p_nda => 6781));
        AddParam ('t4.338', Get_Ftr_Chk2 (p_at_id, p_nda => 6782));
        AddParam ('t4.339', Get_Ftr_Chk2 (p_at_id, p_nda => 6783));
        AddParam ('t4.340', Get_Ftr_Chk2 (p_at_id, p_nda => 6784));
        AddParam ('t4.341', Get_Ftr_Chk2 (p_at_id, p_nda => 6785));
        AddParam ('t4.342', Get_Ftr_Chk2 (p_at_id, p_nda => 6786));
        AddParam ('t4.343', Get_Ftr_Chk2 (p_at_id, p_nda => 6787));
        AddParam ('t4.344', Get_Ftr_Chk2 (p_at_id, p_nda => 6788));
        AddParam ('t4.345', Get_Ftr_Chk2 (p_at_id, p_nda => 6789));
        AddParam ('t4.346', Get_Ftr_Chk2 (p_at_id, p_nda => 6790));
        AddParam ('t4.347', Get_Ftr_Chk2 (p_at_id, p_nda => 6791));
        AddParam ('t4.348', Get_Ftr_Chk2 (p_at_id, p_nda => 6792));
        AddParam ('t4.349', Get_Ftr_Chk2 (p_at_id, p_nda => 6793));
        AddParam ('t4.350', Get_Ftr_Chk2 (p_at_id, p_nda => 6794));

        --Таблиця 5 Картка визначення індивідуальних потреб отримувача соціальної послуги (ітоги з Таблиці 4)
        --1 Управління фінансами
        AddParam ('t51.1', ate_indicator_value1 (p_at_id, p_nng => 642)); --Нульовий
        AddParam ('t51.2', ate_indicator_value1 (p_at_id, p_nng => 643)); --Базовий
        AddParam ('t51.3', ate_indicator_value1 (p_at_id, p_nng => 644)); --Задовільний
        AddParam ('t51.4', ate_indicator_value1 (p_at_id, p_nng => 645)); --Добрий
        AddParam ('t51.5', ate_indicator_value1 (p_at_id, p_nng => 646)); --Високий
        --2 організація харчування
        AddParam ('t52.1', ate_indicator_value1 (p_at_id, p_nng => 647)); --Нульовий
        AddParam ('t52.2', ate_indicator_value1 (p_at_id, p_nng => 648)); --Базовий
        AddParam ('t52.3', ate_indicator_value1 (p_at_id, p_nng => 649)); --Задовільний
        AddParam ('t52.4', ate_indicator_value1 (p_at_id, p_nng => 650)); --Добрий
        AddParam ('t52.5', ate_indicator_value1 (p_at_id, p_nng => 651)); --Високий
        --3 Зовнішній вигляд
        AddParam ('t53.1', ate_indicator_value1 (p_at_id, p_nng => 652)); --Нульовий
        AddParam ('t53.2', ate_indicator_value1 (p_at_id, p_nng => 653)); --Базовий
        AddParam ('t53.3', ate_indicator_value1 (p_at_id, p_nng => 654)); --Задовільний
        AddParam ('t53.4', ate_indicator_value1 (p_at_id, p_nng => 655)); --Добрий
        AddParam ('t53.5', ate_indicator_value1 (p_at_id, p_nng => 656)); --Високий
        --4 здоров’я
        AddParam ('t54.1', ate_indicator_value1 (p_at_id, p_nng => 657)); --Нульовий
        AddParam ('t54.2', ate_indicator_value1 (p_at_id, p_nng => 658)); --Базовий
        AddParam ('t54.3', ate_indicator_value1 (p_at_id, p_nng => 659)); --Задовільний
        AddParam ('t54.4', ate_indicator_value1 (p_at_id, p_nng => 660)); --Добрий
        AddParam ('t54.5', ate_indicator_value1 (p_at_id, p_nng => 661)); --Високий
        --5 утримання помешкання
        AddParam ('t55.1', ate_indicator_value1 (p_at_id, p_nng => 662)); --Нульовий
        AddParam ('t55.2', ate_indicator_value1 (p_at_id, p_nng => 663)); --Базовий
        AddParam ('t55.3', ate_indicator_value1 (p_at_id, p_nng => 664)); --Задовільний
        AddParam ('t55.4', ate_indicator_value1 (p_at_id, p_nng => 665)); --Добрий
        AddParam ('t55.5', ate_indicator_value1 (p_at_id, p_nng => 666)); --Високий
        --6 обізнаність у сфері нерухомості
        AddParam ('t56.1', ate_indicator_value1 (p_at_id, p_nng => 667)); --Нульовий
        AddParam ('t56.2', ate_indicator_value1 (p_at_id, p_nng => 668)); --Базовий
        AddParam ('t56.3', ate_indicator_value1 (p_at_id, p_nng => 669)); --Задовільний
        AddParam ('t56.4', ate_indicator_value1 (p_at_id, p_nng => 670)); --Добрий
        AddParam ('t56.5', ate_indicator_value1 (p_at_id, p_nng => 671)); --Високий
        --7 користування транспортом
        AddParam ('t57.1', ate_indicator_value1 (p_at_id, p_nng => 672)); --Нульовий
        AddParam ('t57.2', ate_indicator_value1 (p_at_id, p_nng => 673)); --Базовий
        AddParam ('t57.3', ate_indicator_value1 (p_at_id, p_nng => 674)); --Задовільний
        AddParam ('t57.4', ate_indicator_value1 (p_at_id, p_nng => 675)); --Добрий
        AddParam ('t57.5', ate_indicator_value1 (p_at_id, p_nng => 676)); --Високий
        --8 організація навчального процесу
        AddParam ('t58.1', ate_indicator_value1 (p_at_id, p_nng => 677)); --Нульовий
        AddParam ('t58.2', ate_indicator_value1 (p_at_id, p_nng => 678)); --Базовий
        AddParam ('t58.3', ate_indicator_value1 (p_at_id, p_nng => 679)); --Задовільний
        AddParam ('t58.4', ate_indicator_value1 (p_at_id, p_nng => 680)); --Добрий
        AddParam ('t58.5', ate_indicator_value1 (p_at_id, p_nng => 681)); --Високий
        --9 навички пошуку роботи
        AddParam ('t59.1', ate_indicator_value1 (p_at_id, p_nng => 682)); --Нульовий
        AddParam ('t59.2', ate_indicator_value1 (p_at_id, p_nng => 683)); --Базовий
        AddParam ('t59.3', ate_indicator_value1 (p_at_id, p_nng => 684)); --Задовільний
        AddParam ('t59.4', ate_indicator_value1 (p_at_id, p_nng => 685)); --Добрий
        AddParam ('t59.5', ate_indicator_value1 (p_at_id, p_nng => 686)); --Високий
        --10 організація роботи
        AddParam ('t510.1', ate_indicator_value1 (p_at_id, p_nng => 687)); --Нульовий
        AddParam ('t510.2', ate_indicator_value1 (p_at_id, p_nng => 688)); --Базовий
        AddParam ('t510.3', ate_indicator_value1 (p_at_id, p_nng => 689)); --Задовільний
        AddParam ('t510.4', ate_indicator_value1 (p_at_id, p_nng => 690)); --Добрий
        AddParam ('t510.5', ate_indicator_value1 (p_at_id, p_nng => 691)); --Високий
        --11  дотримання правил безпеки та поведінка
        AddParam ('t511.1', ate_indicator_value1 (p_at_id, p_nng => 692)); --Нульовий
        AddParam ('t511.2', ate_indicator_value1 (p_at_id, p_nng => 693)); --Базовий
        AddParam ('t511.3', ate_indicator_value1 (p_at_id, p_nng => 694)); --Задовільний
        AddParam ('t511.4', ate_indicator_value1 (p_at_id, p_nng => 695)); --Добрий
        AddParam ('t511.5', ate_indicator_value1 (p_at_id, p_nng => 696)); --Високий
        --12 знання ресурсів громади
        AddParam ('t512.1', ate_indicator_value1 (p_at_id, p_nng => 697)); --Нульовий
        AddParam ('t512.2', ate_indicator_value1 (p_at_id, p_nng => 698)); --Базовий
        AddParam ('t512.3', ate_indicator_value1 (p_at_id, p_nng => 699)); --Задовільний
        AddParam ('t512.4', ate_indicator_value1 (p_at_id, p_nng => 700)); --Добрий
        AddParam ('t512.5', ate_indicator_value1 (p_at_id, p_nng => 701)); --Високий
        --13 міжособистісні відносини
        AddParam ('t513.1', ate_indicator_value1 (p_at_id, p_nng => 702)); --Нульовий
        AddParam ('t513.2', ate_indicator_value1 (p_at_id, p_nng => 703)); --Базовий
        AddParam ('t513.3', ate_indicator_value1 (p_at_id, p_nng => 704)); --Задовільний
        AddParam ('t513.4', ate_indicator_value1 (p_at_id, p_nng => 705)); --Добрий
        AddParam ('t513.5', ate_indicator_value1 (p_at_id, p_nng => 706)); --Високий
        --14 обізнаність у юридичній сфері
        AddParam ('t514.1', ate_indicator_value1 (p_at_id, p_nng => 707)); --Нульовий
        AddParam ('t514.2', ate_indicator_value1 (p_at_id, p_nng => 708)); --Базовий
        AddParam ('t514.3', ate_indicator_value1 (p_at_id, p_nng => 709)); --Задовільний
        AddParam ('t514.4', ate_indicator_value1 (p_at_id, p_nng => 710)); --Добрий
        AddParam ('t514.5', ate_indicator_value1 (p_at_id, p_nng => 711)); --Високий
        --Загальна кількість балів
        AddParam ('t51', Get_Ftr_Nt (p_at_id, p_nda => 6795));
        AddParam ('t52', Get_Ftr_Nt (p_at_id, p_nda => 6796));
        AddParam ('t53', Get_Ftr_Nt (p_at_id, p_nda => 6797));
        AddParam ('t54', Get_Ftr_Nt (p_at_id, p_nda => 6798));
        AddParam ('t55', Get_Ftr_Nt (p_at_id, p_nda => 6799));
        AddParam ('t56', Get_Ftr_Nt (p_at_id, p_nda => 6800));
        AddParam ('t57', Get_Ftr_Nt (p_at_id, p_nda => 6801));
        AddParam ('t58', Get_Ftr_Nt (p_at_id, p_nda => 6802));
        AddParam ('t59', Get_Ftr_Nt (p_at_id, p_nda => 6803));
        AddParam ('t510', Get_Ftr_Nt (p_at_id, p_nda => 6804));
        AddParam ('t511', Get_Ftr_Nt (p_at_id, p_nda => 6805));
        AddParam ('t512', Get_Ftr_Nt (p_at_id, p_nda => 6806));
        AddParam ('t513', Get_Ftr_Nt (p_at_id, p_nda => 6807));
        AddParam ('t514', Get_Ftr_Nt (p_at_id, p_nda => 6808));

        --Висновок. nng=712
        AddParam ('v1', Underline (c.pib, 2));  --Отримувач соціальної послуги
        AddParam (
            'v2',
            NVL (
                Underline (
                       Api$Act_Rpt.v_ddn (
                           'uss_ndi.V_DDN_SS_LEVEL_HAS_SKL',
                           Api$Act_Rpt.Get_Ftr (p_at_id, p_nda => 6809))
                    || CASE
                           WHEN Api$Act_Rpt.Get_Ftr_Nt (p_at_id,
                                                        p_nda   => 6809)
                                    IS NOT NULL
                           THEN
                                  ' '
                               || Api$Act_Rpt.Get_Ftr_Nt (p_at_id,
                                                          p_nda   => 6809)
                       END,
                    2),
                '______'));                                         --на рівні
        AddParam (
            'v3',
            NVL (
                TO_CHAR (
                    Underline (
                        Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 712).ate_indicator_value1,
                        2)),
                '______'));                                     --усього балів
        AddParam (
            'v4',
            NVL (
                TO_CHAR (
                    Underline (
                        Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 712).ate_indicator_value2,
                        2)),
                '______'));                               --в середньому годин

        --Особи, які брали участь в оцінюванні
        /*l_str:= q'[
          select p.pib                  as c1,
                 p.Relation_Tp          as c2,
                 null                   as c3,
                 api$act_rpt.get_sign_mark(:p_at_id, p.Atp_Id, '') as c4
            from table(uss_esr.Api$Act_Rpt.At_Person_for_act(:p_at_id)) p
           where 1=1
             and p.atp_app_tp not in ('OS', 'AP')
          ]';*/

        l_str := q'[
    select p.atop_ln || ' ' || atop_fn || ' ' || atop_mn as c1,
           p.atop_position                               as c2,
           to_char(sysdate, 'DD.MM.YYYY')                as c3
      from uss_esr.v_at_other_spec p
     where 1=1
       and atop_at = :p_at_id
       and history_status = 'A'
    ]';
        l_str :=
            REGEXP_REPLACE (l_str,
                            ':p_at_id',
                            p_at_id,
                            1,
                            0,
                            'i');
        l_str :=
            REGEXP_REPLACE (
                l_str,
                'null',
                CHR (39) || TO_CHAR (c.at_dt, 'dd.mm.yyyy') || CHR (39),
                1,
                0,
                'i');
        rdm$rtfl_univ.AddDataset ('ds', l_str);

        AddParam ('sgn1', Api$Act_Rpt.GetCuPIB (c.at_cu)); --Особа, яка провела оцінювання
        AddParam ('sgn2', TO_CHAR (c.at_dt, 'dd.mm.yyyy'));

        ------------------------------------
        rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                         p_rpt_blob   => l_result);
        replace_ekr (l_result);

        RETURN l_result;
    END ACT_DOC_891_R1;

    --#94128 017.1-896-Комплексне визначення ступеня інд.потреб СП соціальної реабілітації
    FUNCTION ACT_DOC_896_R1 (p_at_id IN NUMBER)
        RETURN BLOB
    IS
        --секція ЖИТЛО/ДОКУМЕНТИ з розділу "Анкета визначення рейтингу соціальних потреб..."
        C_ATE_NNG_ANK   CONSTANT INTEGER := 522;

        CURSOR c_at IS
            SELECT a.at_dt,
                   a.at_sc,
                   a.At_rnspm,
                   a.at_wu,
                   a.at_cu,
                   a.at_ap
              FROM act a
             WHERE a.at_id = p_at_id;

        c                        c_at%ROWTYPE;

        l_str                    VARCHAR2 (32000);

        p1                       Api$Act_Rpt.R_Person_for_act;     --отримувач
        p2                       at_other_spec%ROWTYPE;             --Фахівець
        p3                       Api$Act_Rpt.R_Person_for_act; --Член сім’ї отримувача

        l_jbr_id                 NUMBER;
        l_result                 BLOB;

        --для Анкети (uss_ndi.V_DDN_SS_TFN1)
        PROCEDURE AddFtrT3 (p_Param_Name   VARCHAR2,
                            p_atp          at_person.atp_id%TYPE,
                            p_nda          NUMBER)
        IS
        BEGIN
            CASE Get_Ftr (p_at_id => p_at_id, p_atp => p_atp, p_nda => p_nda)
                WHEN 'T'
                THEN
                    AddParam (p_Param_Name, 'Так');
                WHEN 'F'
                THEN
                    AddParam (p_Param_Name, 'Ні');
                ELSE
                    AddParam (p_Param_Name, '--');
            END CASE;
        END;

        PROCEDURE AddFtrT3_2 (p_Param_Name   VARCHAR2,
                              p_Atop         At_Section.Ate_Atop%TYPE,
                              p_Nda          NUMBER)
        IS
            CURSOR Cur IS
                SELECT f.Atef_Feature
                  FROM Uss_Esr.At_Section s, Uss_Esr.At_Section_Feature f
                 WHERE     s.Ate_At = p_At_Id
                       AND s.Ate_Atop = p_Atop
                       AND f.Atef_Ate = s.Ate_Id
                       AND f.Atef_Nda = p_Nda;

            l_Res   At_Section_Feature.Atef_Feature%TYPE;
        BEGIN
            OPEN Cur;

            FETCH Cur INTO l_Res;

            CLOSE Cur;

            CASE l_Res
                WHEN 'T'
                THEN
                    Addparam (p_Param_Name, 'Так');
                WHEN 'F'
                THEN
                    Addparam (p_Param_Name, 'Ні');
                ELSE
                    Addparam (p_Param_Name, '--');
            END CASE;
        END;
    BEGIN
        rdm$rtfl_univ.initreport (p_code     => 'ACT_DOC_896_R1',
                                  p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);

        ------------------------------------
        OPEN c_at;

        FETCH c_at INTO c;

        CLOSE c_at;

        --шукаємо по секції з заповненими даними трьох осіб
        SELECT MAX (CASE WHEN p.atp_app_tp = 'OS' THEN p.atp_id END), --отримувач
               MAX (
                   CASE
                       WHEN NVL (p.Atp_App_Tp, '***') NOT IN ('OS', 'AP')
                       THEN
                           p.atp_id
                   END)                                --Член сім’ї отримувача
          INTO p1.atp_id, p3.atp_id
          FROM uss_esr.at_section s, at_person p
         WHERE     1 = 1
               AND s.ate_at = p_at_id
               --секція ЖИТЛО/ДОКУМЕНТИ з розділу "Анкета визначення рейтингу соціальних потреб..."
               AND s.ate_nng = C_ATE_NNG_ANK
               AND p.atp_at = s.ate_at
               AND p.atp_id = s.ate_atp;

        p1 := get_AtPerson (p_at => p_at_id, p_atp => p1.atp_id);
        p2 :=
            Get_Sctn_Specialist (p_At_Id         => p_at_id,
                                 p_Ate_Nng_Ank   => C_ATE_NNG_ANK); --Фахівець
        p3 := get_AtPerson (p_at => p_at_id, p_atp => p3.atp_id);

        --Таблиця 1 Шкала оцінки навичок за основними категоріями отримувача соціальної послуги
        --1 Управління фінансами
        AddParam ('t11.1.1', Get_Ftr_Chk2 (p_at_id, p_nda => 3138)); --Низький
        AddParam ('t11.1.2', Get_Ftr_Chk2 (p_at_id, p_nda => 3139));
        AddParam ('t11.1.3', Get_Ftr_Chk2 (p_at_id, p_nda => 3140));
        AddParam ('t11.1.4', Get_Ftr_Chk2 (p_at_id, p_nda => 3141));
        AddParam ('t11.1.5', Get_Ftr_Chk2 (p_at_id, p_nda => 3159));
        AddParam ('t11.2.1', Get_Ftr_Chk2 (p_at_id, p_nda => 3160)); --Базовий
        AddParam ('t11.2.2', Get_Ftr_Chk2 (p_at_id, p_nda => 3161));
        AddParam ('t11.2.3', Get_Ftr_Chk2 (p_at_id, p_nda => 3167));
        AddParam ('t11.2.4', Get_Ftr_Chk2 (p_at_id, p_nda => 3168));
        AddParam ('t11.2.5', Get_Ftr_Chk2 (p_at_id, p_nda => 3169));
        AddParam ('t11.3.1', Get_Ftr_Chk2 (p_at_id, p_nda => 3188)); --Задовільний
        AddParam ('t11.3.2', Get_Ftr_Chk2 (p_at_id, p_nda => 3189));
        AddParam ('t11.3.3', Get_Ftr_Chk2 (p_at_id, p_nda => 3190));
        AddParam ('t11.3.4', Get_Ftr_Chk2 (p_at_id, p_nda => 3202));
        AddParam ('t11.3.5', Get_Ftr_Chk2 (p_at_id, p_nda => 3203));
        AddParam ('t11.4.1', Get_Ftr_Chk2 (p_at_id, p_nda => 3204));  --Добрий
        AddParam ('t11.4.2', Get_Ftr_Chk2 (p_at_id, p_nda => 3222));
        AddParam ('t11.4.3', Get_Ftr_Chk2 (p_at_id, p_nda => 3223));
        AddParam ('t11.4.4', Get_Ftr_Chk2 (p_at_id, p_nda => 3224));
        AddParam ('t11.4.5', Get_Ftr_Chk2 (p_at_id, p_nda => 3246));
        AddParam ('t11.5.1', Get_Ftr_Chk2 (p_at_id, p_nda => 3247)); --Високий
        AddParam ('t11.5.2', Get_Ftr_Chk2 (p_at_id, p_nda => 3248));
        AddParam ('t11.5.3', Get_Ftr_Chk2 (p_at_id, p_nda => 3256));
        AddParam ('t11.5.4', Get_Ftr_Chk2 (p_at_id, p_nda => 3257));
        AddParam ('t11.5.5', Get_Ftr_Chk2 (p_at_id, p_nda => 3258));
        --2 Організація харчування
        AddParam ('t12.1.1', Get_Ftr_Chk2 (p_at_id, p_nda => 3435)); --Низький
        AddParam ('t12.1.2', Get_Ftr_Chk2 (p_at_id, p_nda => 3436));
        AddParam ('t12.1.3', Get_Ftr_Chk2 (p_at_id, p_nda => 3437));
        AddParam ('t12.1.4', Get_Ftr_Chk2 (p_at_id, p_nda => 3438));
        AddParam ('t12.1.5', Get_Ftr_Chk2 (p_at_id, p_nda => 3613));
        AddParam ('t12.2.1', Get_Ftr_Chk2 (p_at_id, p_nda => 4058)); --Базовий
        AddParam ('t12.2.2', Get_Ftr_Chk2 (p_at_id, p_nda => 4059));
        AddParam ('t12.2.3', Get_Ftr_Chk2 (p_at_id, p_nda => 4060));
        AddParam ('t12.2.4', Get_Ftr_Chk2 (p_at_id, p_nda => 4061));
        AddParam ('t12.2.5', Get_Ftr_Chk2 (p_at_id, p_nda => 4062));
        AddParam ('t12.3.1', Get_Ftr_Chk2 (p_at_id, p_nda => 4063)); --Задовільний
        AddParam ('t12.3.2', Get_Ftr_Chk2 (p_at_id, p_nda => 4064));
        AddParam ('t12.3.3', Get_Ftr_Chk2 (p_at_id, p_nda => 4065));
        AddParam ('t12.3.4', Get_Ftr_Chk2 (p_at_id, p_nda => 4066));
        AddParam ('t12.3.5', Get_Ftr_Chk2 (p_at_id, p_nda => 4067));
        AddParam ('t12.4.1', Get_Ftr_Chk2 (p_at_id, p_nda => 4068));  --Добрий
        AddParam ('t12.4.2', Get_Ftr_Chk2 (p_at_id, p_nda => 4069));
        AddParam ('t12.4.3', Get_Ftr_Chk2 (p_at_id, p_nda => 4070));
        AddParam ('t12.4.4', Get_Ftr_Chk2 (p_at_id, p_nda => 4071));
        AddParam ('t12.4.5', Get_Ftr_Chk2 (p_at_id, p_nda => 4072));
        AddParam ('t12.5.1', Get_Ftr_Chk2 (p_at_id, p_nda => 4073)); --Високий
        AddParam ('t12.5.2', Get_Ftr_Chk2 (p_at_id, p_nda => 4074));
        AddParam ('t12.5.3', Get_Ftr_Chk2 (p_at_id, p_nda => 4075));
        AddParam ('t12.5.4', Get_Ftr_Chk2 (p_at_id, p_nda => 4076));
        AddParam ('t12.5.5', Get_Ftr_Chk2 (p_at_id, p_nda => 4077));
        --3 Зовнішній вигляд
        AddParam ('t13.1.1', Get_Ftr_Chk2 (p_at_id, p_nda => 4078)); --Низький
        AddParam ('t13.1.2', Get_Ftr_Chk2 (p_at_id, p_nda => 4079));
        AddParam ('t13.1.3', Get_Ftr_Chk2 (p_at_id, p_nda => 4080));
        AddParam ('t13.1.4', Get_Ftr_Chk2 (p_at_id, p_nda => 4081));
        AddParam ('t13.1.5', Get_Ftr_Chk2 (p_at_id, p_nda => 4082));
        AddParam ('t13.2.1', Get_Ftr_Chk2 (p_at_id, p_nda => 4083)); --Базовий
        AddParam ('t13.2.2', Get_Ftr_Chk2 (p_at_id, p_nda => 4084));
        AddParam ('t13.2.3', Get_Ftr_Chk2 (p_at_id, p_nda => 4085));
        AddParam ('t13.2.4', Get_Ftr_Chk2 (p_at_id, p_nda => 4086));
        AddParam ('t13.2.5', Get_Ftr_Chk2 (p_at_id, p_nda => 4087));
        AddParam ('t13.3.1', Get_Ftr_Chk2 (p_at_id, p_nda => 4088)); --Задовільний
        AddParam ('t13.3.2', Get_Ftr_Chk2 (p_at_id, p_nda => 4089));
        AddParam ('t13.3.3', Get_Ftr_Chk2 (p_at_id, p_nda => 4090));
        AddParam ('t13.3.4', Get_Ftr_Chk2 (p_at_id, p_nda => 4091));
        AddParam ('t13.3.5', Get_Ftr_Chk2 (p_at_id, p_nda => 4092));
        AddParam ('t13.4.1', Get_Ftr_Chk2 (p_at_id, p_nda => 4093));  --Добрий
        AddParam ('t13.4.2', Get_Ftr_Chk2 (p_at_id, p_nda => 4094));
        AddParam ('t13.4.3', Get_Ftr_Chk2 (p_at_id, p_nda => 4095));
        AddParam ('t13.4.4', Get_Ftr_Chk2 (p_at_id, p_nda => 4096));
        AddParam ('t13.4.5', Get_Ftr_Chk2 (p_at_id, p_nda => 4097));
        AddParam ('t13.5.1', Get_Ftr_Chk2 (p_at_id, p_nda => 4098)); --Високий
        AddParam ('t13.5.2', Get_Ftr_Chk2 (p_at_id, p_nda => 4099));
        AddParam ('t13.5.3', Get_Ftr_Chk2 (p_at_id, p_nda => 4100));
        AddParam ('t13.5.4', Get_Ftr_Chk2 (p_at_id, p_nda => 4101));
        AddParam ('t13.5.5', Get_Ftr_Chk2 (p_at_id, p_nda => 4102));
        --4 Здоров’я
        AddParam ('t14.1.1', Get_Ftr_Chk2 (p_at_id, p_nda => 4103)); --Низький
        AddParam ('t14.1.2', Get_Ftr_Chk2 (p_at_id, p_nda => 4104));
        AddParam ('t14.1.3', Get_Ftr_Chk2 (p_at_id, p_nda => 4105));
        AddParam ('t14.1.4', Get_Ftr_Chk2 (p_at_id, p_nda => 4106));
        AddParam ('t14.1.5', Get_Ftr_Chk2 (p_at_id, p_nda => 4107));
        AddParam ('t14.2.1', Get_Ftr_Chk2 (p_at_id, p_nda => 4108)); --Базовий
        AddParam ('t14.2.2', Get_Ftr_Chk2 (p_at_id, p_nda => 4109));
        AddParam ('t14.2.3', Get_Ftr_Chk2 (p_at_id, p_nda => 4110));
        AddParam ('t14.2.4', Get_Ftr_Chk2 (p_at_id, p_nda => 4111));
        AddParam ('t14.2.5', Get_Ftr_Chk2 (p_at_id, p_nda => 4112));
        AddParam ('t14.3.1', Get_Ftr_Chk2 (p_at_id, p_nda => 4113)); --Задовільний
        AddParam ('t14.3.2', Get_Ftr_Chk2 (p_at_id, p_nda => 4114));
        AddParam ('t14.3.3', Get_Ftr_Chk2 (p_at_id, p_nda => 4115));
        AddParam ('t14.3.4', Get_Ftr_Chk2 (p_at_id, p_nda => 4116));
        AddParam ('t14.3.5', Get_Ftr_Chk2 (p_at_id, p_nda => 4117));
        AddParam ('t14.4.1', Get_Ftr_Chk2 (p_at_id, p_nda => 4118));  --Добрий
        AddParam ('t14.4.2', Get_Ftr_Chk2 (p_at_id, p_nda => 4119));
        AddParam ('t14.4.3', Get_Ftr_Chk2 (p_at_id, p_nda => 4120));
        AddParam ('t14.4.4', Get_Ftr_Chk2 (p_at_id, p_nda => 4121));
        AddParam ('t14.4.5', Get_Ftr_Chk2 (p_at_id, p_nda => 4122));
        AddParam ('t14.5.1', Get_Ftr_Chk2 (p_at_id, p_nda => 4123)); --Високий
        AddParam ('t14.5.2', Get_Ftr_Chk2 (p_at_id, p_nda => 4124));
        AddParam ('t14.5.3', Get_Ftr_Chk2 (p_at_id, p_nda => 4125));
        AddParam ('t14.5.4', Get_Ftr_Chk2 (p_at_id, p_nda => 4126));
        AddParam ('t14.5.5', Get_Ftr_Chk2 (p_at_id, p_nda => 4127));
        --5 Утримання помешкання
        AddParam ('t15.1.1', Get_Ftr_Chk2 (p_at_id, p_nda => 4128)); --Низький
        AddParam ('t15.1.2', Get_Ftr_Chk2 (p_at_id, p_nda => 4129));
        AddParam ('t15.1.3', Get_Ftr_Chk2 (p_at_id, p_nda => 4130));
        AddParam ('t15.1.4', Get_Ftr_Chk2 (p_at_id, p_nda => 4131));
        AddParam ('t15.1.5', Get_Ftr_Chk2 (p_at_id, p_nda => 4132));
        AddParam ('t15.2.1', Get_Ftr_Chk2 (p_at_id, p_nda => 4133)); --Базовий
        AddParam ('t15.2.2', Get_Ftr_Chk2 (p_at_id, p_nda => 4134));
        AddParam ('t15.2.3', Get_Ftr_Chk2 (p_at_id, p_nda => 4135));
        AddParam ('t15.2.4', Get_Ftr_Chk2 (p_at_id, p_nda => 4136));
        AddParam ('t15.2.5', Get_Ftr_Chk2 (p_at_id, p_nda => 4137));
        AddParam ('t15.3.1', Get_Ftr_Chk2 (p_at_id, p_nda => 4138)); --Задовільний
        AddParam ('t15.3.2', Get_Ftr_Chk2 (p_at_id, p_nda => 4139));
        AddParam ('t15.3.3', Get_Ftr_Chk2 (p_at_id, p_nda => 4140));
        AddParam ('t15.3.4', Get_Ftr_Chk2 (p_at_id, p_nda => 4675));
        AddParam ('t15.3.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5418));
        AddParam ('t15.4.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5576));  --Добрий
        AddParam ('t15.4.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5577));
        AddParam ('t15.4.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5578));
        AddParam ('t15.4.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5579));
        AddParam ('t15.4.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5580));
        AddParam ('t15.5.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5581)); --Високий
        AddParam ('t15.5.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5582));
        AddParam ('t15.5.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5583));
        AddParam ('t15.5.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5584));
        AddParam ('t15.5.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5585));
        --6 Обізнаність у сфері нерухомості
        AddParam ('t16.1.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5586)); --Низький
        AddParam ('t16.1.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5587));
        AddParam ('t16.1.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5588));
        AddParam ('t16.1.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5589));
        AddParam ('t16.1.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5590));
        AddParam ('t16.2.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5591)); --Базовий
        AddParam ('t16.2.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5592));
        AddParam ('t16.2.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5593));
        AddParam ('t16.2.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5594));
        AddParam ('t16.2.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5595));
        AddParam ('t16.3.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5596)); --Задовільний
        AddParam ('t16.3.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5597));
        AddParam ('t16.3.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5598));
        AddParam ('t16.3.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5599));
        AddParam ('t16.3.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5600));
        AddParam ('t16.4.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5601));  --Добрий
        AddParam ('t16.4.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5602));
        AddParam ('t16.4.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5603));
        AddParam ('t16.4.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5604));
        AddParam ('t16.4.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5605));
        AddParam ('t16.5.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5606)); --Високий
        AddParam ('t16.5.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5607));
        AddParam ('t16.5.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5608));
        AddParam ('t16.5.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5609));
        AddParam ('t16.5.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5610));
        --7 Користування транспортом
        AddParam ('t17.1.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5611)); --Низький
        AddParam ('t17.1.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5612));
        AddParam ('t17.1.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5613));
        AddParam ('t17.1.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5614));
        AddParam ('t17.1.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5615));
        AddParam ('t17.2.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5616)); --Базовий
        AddParam ('t17.2.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5617));
        AddParam ('t17.2.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5618));
        AddParam ('t17.2.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5619));
        AddParam ('t17.2.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5620));
        AddParam ('t17.3.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5621)); --Задовільний
        AddParam ('t17.3.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5622));
        AddParam ('t17.3.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5623));
        AddParam ('t17.3.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5624));
        AddParam ('t17.3.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5625));
        AddParam ('t17.4.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5626));  --Добрий
        AddParam ('t17.4.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5627));
        AddParam ('t17.4.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5628));
        AddParam ('t17.4.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5629));
        AddParam ('t17.4.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5630));
        AddParam ('t17.5.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5631)); --Високий
        AddParam ('t17.5.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5632));
        AddParam ('t17.5.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5633));
        AddParam ('t17.5.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5634));
        AddParam ('t17.5.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5635));
        --8 Організація навчального процесу
        AddParam ('t18.1.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5636)); --Низький
        AddParam ('t18.1.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5637));
        AddParam ('t18.1.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5638));
        AddParam ('t18.1.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5639));
        AddParam ('t18.1.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5640));
        AddParam ('t18.2.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5641)); --Базовий
        AddParam ('t18.2.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5642));
        AddParam ('t18.2.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5643));
        AddParam ('t18.2.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5644));
        AddParam ('t18.2.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5645));
        AddParam ('t18.3.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5646)); --Задовільний
        AddParam ('t18.3.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5647));
        AddParam ('t18.3.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5648));
        AddParam ('t18.3.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5649));
        AddParam ('t18.3.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5650));
        AddParam ('t18.4.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5651));  --Добрий
        AddParam ('t18.4.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5652));
        AddParam ('t18.4.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5653));
        AddParam ('t18.4.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5654));
        AddParam ('t18.4.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5655));
        AddParam ('t18.5.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5656)); --Високий
        AddParam ('t18.5.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5657));
        AddParam ('t18.5.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5658));
        AddParam ('t18.5.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5659));
        AddParam ('t18.5.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5660));
        --9 Навички пошуку роботи
        AddParam ('t19.1.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5661)); --Низький
        AddParam ('t19.1.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5662));
        AddParam ('t19.1.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5663));
        AddParam ('t19.1.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5664));
        AddParam ('t19.1.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5665));
        AddParam ('t19.2.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5666)); --Базовий
        AddParam ('t19.2.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5667));
        AddParam ('t19.2.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5668));
        AddParam ('t19.2.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5669));
        AddParam ('t19.2.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5670));
        AddParam ('t19.3.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5671)); --Задовільний
        AddParam ('t19.3.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5672));
        AddParam ('t19.3.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5673));
        AddParam ('t19.3.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5674));
        AddParam ('t19.3.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5675));
        AddParam ('t19.4.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5676));  --Добрий
        AddParam ('t19.4.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5677));
        AddParam ('t19.4.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5678));
        AddParam ('t19.4.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5679));
        AddParam ('t19.4.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5680));
        AddParam ('t19.5.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5681)); --Високий
        AddParam ('t19.5.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5682));
        AddParam ('t19.5.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5683));
        AddParam ('t19.5.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5684));
        AddParam ('t19.5.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5685));
        --10 Організація роботи
        AddParam ('t110.1.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5686)); --Низький
        AddParam ('t110.1.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5687));
        AddParam ('t110.1.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5688));
        AddParam ('t110.1.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5689));
        AddParam ('t110.1.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5690));
        AddParam ('t110.2.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5691)); --Базовий
        AddParam ('t110.2.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5692));
        AddParam ('t110.2.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5693));
        AddParam ('t110.2.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5694));
        AddParam ('t110.2.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5695));
        AddParam ('t110.3.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5696)); --Задовільний
        AddParam ('t110.3.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5697));
        AddParam ('t110.3.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5698));
        AddParam ('t110.3.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5699));
        AddParam ('t110.3.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5700));
        AddParam ('t110.4.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5701)); --Добрий
        AddParam ('t110.4.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5702));
        AddParam ('t110.4.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5703));
        AddParam ('t110.4.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5704));
        AddParam ('t110.4.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5705));
        AddParam ('t110.5.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5706)); --Високий
        AddParam ('t110.5.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5707));
        AddParam ('t110.5.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5708));
        AddParam ('t110.5.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5709));
        AddParam ('t110.5.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5710));
        --11 Дотримання правил безпеки та поведінки у разі надзвичайних ситуацій
        AddParam ('t111.1.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5711)); --Низький
        AddParam ('t111.1.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5712));
        AddParam ('t111.1.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5713));
        AddParam ('t111.1.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5714));
        AddParam ('t111.1.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5715));
        AddParam ('t111.2.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5716)); --Базовий
        AddParam ('t111.2.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5717));
        AddParam ('t111.2.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5718));
        AddParam ('t111.2.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5719));
        AddParam ('t111.2.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5720));
        AddParam ('t111.3.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5721)); --Задовільний
        AddParam ('t111.3.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5722));
        AddParam ('t111.3.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5723));
        AddParam ('t111.3.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5724));
        AddParam ('t111.3.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5725));
        AddParam ('t111.4.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5726)); --Добрий
        AddParam ('t111.4.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5727));
        AddParam ('t111.4.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5728));
        AddParam ('t111.4.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5729));
        AddParam ('t111.4.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5730));
        AddParam ('t111.5.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5731)); --Високий
        AddParam ('t111.5.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5732));
        AddParam ('t111.5.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5733));
        AddParam ('t111.5.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5734));
        AddParam ('t111.5.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5735));
        --Знання ресурсів громади
        AddParam ('t112.1.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5736)); --Низький
        AddParam ('t112.1.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5737));
        AddParam ('t112.1.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5738));
        AddParam ('t112.1.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5739));
        AddParam ('t112.1.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5740));
        AddParam ('t112.2.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5741)); --Базовий
        AddParam ('t112.2.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5742));
        AddParam ('t112.2.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5743));
        AddParam ('t112.2.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5744));
        AddParam ('t112.2.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5745));
        AddParam ('t112.3.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5746)); --Задовільний
        AddParam ('t112.3.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5747));
        AddParam ('t112.3.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5748));
        AddParam ('t112.3.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5749));
        AddParam ('t112.3.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5750));
        AddParam ('t112.4.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5751)); --Добрий
        AddParam ('t112.4.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5752));
        AddParam ('t112.4.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5753));
        AddParam ('t112.4.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5754));
        AddParam ('t112.4.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5755));
        AddParam ('t112.5.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5756)); --Високий
        AddParam ('t112.5.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5757));
        AddParam ('t112.5.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5758));
        AddParam ('t112.5.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5759));
        AddParam ('t112.5.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5760));
        --13 Міжособистісні відносини
        AddParam ('t113.1.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5761)); --Низький
        AddParam ('t113.1.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5762));
        AddParam ('t113.1.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5763));
        AddParam ('t113.1.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5764));
        AddParam ('t113.1.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5765));
        AddParam ('t113.2.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5766)); --Базовий
        AddParam ('t113.2.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5767));
        AddParam ('t113.2.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5768));
        AddParam ('t113.2.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5769));
        AddParam ('t113.2.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5770));
        AddParam ('t113.3.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5771)); --Задовільний
        AddParam ('t113.3.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5772));
        AddParam ('t113.3.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5773));
        AddParam ('t113.3.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5774));
        AddParam ('t113.3.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5775));
        AddParam ('t113.4.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5776)); --Добрий
        AddParam ('t113.4.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5777));
        AddParam ('t113.4.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5778));
        AddParam ('t113.4.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5779));
        AddParam ('t113.4.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5780));
        AddParam ('t113.5.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5781)); --Високий
        AddParam ('t113.5.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5782));
        AddParam ('t113.5.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5783));
        AddParam ('t113.5.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5784));
        AddParam ('t113.5.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5785));
        --14 Обізнаність у юридичній сфері
        AddParam ('t114.1.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5786)); --Низький
        AddParam ('t114.1.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5787));
        AddParam ('t114.1.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5788));
        AddParam ('t114.1.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5789));
        AddParam ('t114.1.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5790));
        AddParam ('t114.2.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5791)); --Базовий
        AddParam ('t114.2.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5792));
        AddParam ('t114.2.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5793));
        AddParam ('t114.2.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5794));
        AddParam ('t114.2.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5795));
        AddParam ('t114.3.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5796)); --Задовільний
        AddParam ('t114.3.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5797));
        AddParam ('t114.3.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5798));
        AddParam ('t114.3.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5799));
        AddParam ('t114.3.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5800));
        AddParam ('t114.4.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5801)); --Добрий
        AddParam ('t114.4.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5802));
        AddParam ('t114.4.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5803));
        AddParam ('t114.4.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5804));
        AddParam ('t114.4.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5805));
        AddParam ('t114.5.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5806)); --Високий
        AddParam ('t114.5.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5807));
        AddParam ('t114.5.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5808));
        AddParam ('t114.5.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5809));
        AddParam ('t114.5.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5810));

        --Таблиця 2
        --Картка визначення індивідуальних потреб отримувача соціальної послуги соціальної реабілітації повнолітніх осіб з інтелектуальними розладами

        AddParam ('os.pib', p1.pib);            --Отримувач соціальної послуги

        --1 Самообслуговування/ зовнішній вигляд, дотримання правил особистої гігієни
        AddParam (
            't21.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 451).ate_indicator_value1); --Низький
        AddParam (
            't21.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 452).ate_indicator_value1); --Базовий
        AddParam (
            't21.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 453).ate_indicator_value1); --Задовільний
        AddParam (
            't21.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 454).ate_indicator_value1); --Добрий
        AddParam (
            't21.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 455).ate_indicator_value1); --Високий
        --2 організація харчування
        AddParam (
            't22.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 456).ate_indicator_value1); --Низький
        AddParam (
            't22.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 457).ate_indicator_value1); --Базовий
        AddParam (
            't22.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 458).ate_indicator_value1); --Задовільний
        AddParam (
            't22.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 459).ate_indicator_value1); --Добрий
        AddParam (
            't22.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 460).ate_indicator_value1); --Високий
        --3 управління фінансами
        AddParam (
            't23.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 461).ate_indicator_value1); --Низький
        AddParam (
            't23.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 462).ate_indicator_value1); --Базовий
        AddParam (
            't23.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 463).ate_indicator_value1); --Задовільний
        AddParam (
            't23.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 464).ate_indicator_value1); --Добрий
        AddParam (
            't23.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 465).ate_indicator_value1); --Високий
        --4 здоров’я
        AddParam (
            't24.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 466).ate_indicator_value1); --Низький
        AddParam (
            't24.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 467).ate_indicator_value1); --Базовий
        AddParam (
            't24.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 468).ate_indicator_value1); --Задовільний
        AddParam (
            't24.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 469).ate_indicator_value1); --Добрий
        AddParam (
            't24.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 470).ate_indicator_value1); --Високий
        --5 утримання помешкання
        AddParam (
            't25.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 471).ate_indicator_value1); --Низький
        AddParam (
            't25.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 472).ate_indicator_value1); --Базовий
        AddParam (
            't25.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 473).ate_indicator_value1); --Задовільний
        AddParam (
            't25.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 474).ate_indicator_value1); --Добрий
        AddParam (
            't25.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 475).ate_indicator_value1); --Високий
        --6 обізнаність у сфері нерухомості
        AddParam (
            't26.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 476).ate_indicator_value1); --Низький
        AddParam (
            't26.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 477).ate_indicator_value1); --Базовий
        AddParam (
            't26.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 478).ate_indicator_value1); --Задовільний
        AddParam (
            't26.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 479).ate_indicator_value1); --Добрий
        AddParam (
            't26.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 480).ate_indicator_value1); --Високий
        --7 користування транспортом
        AddParam (
            't27.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 481).ate_indicator_value1); --Низький
        AddParam (
            't27.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 482).ate_indicator_value1); --Базовий
        AddParam (
            't27.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 483).ate_indicator_value1); --Задовільний
        AddParam (
            't27.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 484).ate_indicator_value1); --Добрий
        AddParam (
            't27.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 485).ate_indicator_value1); --Високий
        --8 організація навчального процесу
        AddParam (
            't28.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 486).ate_indicator_value1); --Низький
        AddParam (
            't28.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 487).ate_indicator_value1); --Базовий
        AddParam (
            't28.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 488).ate_indicator_value1); --Задовільний
        AddParam (
            't28.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 489).ate_indicator_value1); --Добрий
        AddParam (
            't28.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 490).ate_indicator_value1); --Високий
        --9 навички пошуку роботи
        AddParam (
            't29.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 491).ate_indicator_value1); --Низький
        AddParam (
            't29.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 492).ate_indicator_value1); --Базовий
        AddParam (
            't29.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 493).ate_indicator_value1); --Задовільний
        AddParam (
            't29.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 494).ate_indicator_value1); --Добрий
        AddParam (
            't29.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 495).ate_indicator_value1); --Високий
        --10 організація діяльності
        AddParam (
            't210.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 496).ate_indicator_value1); --Низький
        AddParam (
            't210.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 497).ate_indicator_value1); --Базовий
        AddParam (
            't210.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 498).ate_indicator_value1); --Задовільний
        AddParam (
            't210.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 499).ate_indicator_value1); --Добрий
        AddParam (
            't210.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 500).ate_indicator_value1); --Високий
        --11  дотримання правил безпеки та поведінка
        AddParam (
            't211.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 501).ate_indicator_value1); --Низький
        AddParam (
            't211.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 502).ate_indicator_value1); --Базовий
        AddParam (
            't211.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 503).ate_indicator_value1); --Задовільний
        AddParam (
            't211.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 504).ate_indicator_value1); --Добрий
        AddParam (
            't211.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 505).ate_indicator_value1); --Високий
        --12 знання ресурсів громади
        AddParam (
            't212.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 506).ate_indicator_value1); --Низький
        AddParam (
            't212.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 507).ate_indicator_value1); --Базовий
        AddParam (
            't212.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 508).ate_indicator_value1); --Задовільний
        AddParam (
            't212.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 509).ate_indicator_value1); --Добрий
        AddParam (
            't212.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 510).ate_indicator_value1); --Високий
        --13 міжособистісні відносини
        AddParam (
            't213.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 511).ate_indicator_value1); --Низький
        AddParam (
            't213.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 512).ate_indicator_value1); --Базовий
        AddParam (
            't213.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 513).ate_indicator_value1); --Задовільний
        AddParam (
            't213.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 514).ate_indicator_value1); --Добрий
        AddParam (
            't213.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 515).ate_indicator_value1); --Високий
        --14 обізнаність у юридичній сфері
        AddParam (
            't214.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 516).ate_indicator_value1); --Низький
        AddParam (
            't214.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 517).ate_indicator_value1); --Базовий
        AddParam (
            't214.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 518).ate_indicator_value1); --Задовільний
        AddParam (
            't214.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 519).ate_indicator_value1); --Добрий
        AddParam (
            't214.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 520).ate_indicator_value1); --Високий
        --Загальна кількість балів
        AddParam ('t21', Get_Ftr_Nt (p_at_id, p_nda => 5811));
        AddParam ('t22', Get_Ftr_Nt (p_at_id, p_nda => 5812));
        AddParam ('t23', Get_Ftr_Nt (p_at_id, p_nda => 5813));
        AddParam ('t24', Get_Ftr_Nt (p_at_id, p_nda => 5814));
        AddParam ('t25', Get_Ftr_Nt (p_at_id, p_nda => 5815));
        AddParam ('t26', Get_Ftr_Nt (p_at_id, p_nda => 5816));
        AddParam ('t27', Get_Ftr_Nt (p_at_id, p_nda => 5817));
        AddParam ('t28', Get_Ftr_Nt (p_at_id, p_nda => 5818));
        AddParam ('t29', Get_Ftr_Nt (p_at_id, p_nda => 5819));
        AddParam ('t210', Get_Ftr_Nt (p_at_id, p_nda => 5820));
        AddParam ('t211', Get_Ftr_Nt (p_at_id, p_nda => 5821));
        AddParam ('t212', Get_Ftr_Nt (p_at_id, p_nda => 5822));
        AddParam ('t213', Get_Ftr_Nt (p_at_id, p_nda => 5823));
        AddParam ('t214', Get_Ftr_Nt (p_at_id, p_nda => 5824));

        --Висновок.
        AddParam ('v1', p1.pib);                --Отримувач соціальної послуги
        AddParam (
            'v2',
            NVL (
                Api$Act_Rpt.v_ddn (
                    'uss_ndi.V_DDN_SS_LEVEL_HAS_SKL',
                    Api$Act_Rpt.Get_Ftr (p_at_id, p_nda => 5825)),
                '______'));                                         --на рівні
        AddParam (
            'v3',
            NVL (
                TO_CHAR (
                    Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 521).ate_indicator_value1),
                '______'));                                     --усього балів
        AddParam (
            'v4',
            NVL (
                TO_CHAR (
                    Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 521).ate_indicator_value2),
                '______'));                               --в середньому годин

        --Особи, які брали участь в оцінюванні
        l_str :=
            q'[
    select p.pib                  as c1,
           p.Relation_Tp          as c2,
           null                   as c3,
           api$act_rpt.get_sign_mark(:p_at_id, p.Atp_Id, '') as c4
      from uss_esr.at_section s, table(uss_esr.Api$Act_Rpt.At_Person_for_act(:p_at_id)) p
     where 1=1
       and s.ate_at = :p_at_id
       --секція з розділу "Анкета для визначення рейтингу соціальних потреб..."
       and s.ate_nng = :C_ATE_NNG_ANK
       and p.atp_id = s.ate_atp
       and atp_app_tp in ('OS')
    ]';
        l_str :=
            REGEXP_REPLACE (l_str,
                            ':p_at_id',
                            p_at_id,
                            1,
                            0,
                            'i');
        l_str :=
            REGEXP_REPLACE (
                l_str,
                'null',
                CHR (39) || TO_CHAR (c.at_dt, 'dd.mm.yyyy') || CHR (39),
                1,
                0,
                'i');
        l_str := REPLACE (l_str, ':C_ATE_NNG_ANK', C_ATE_NNG_ANK);
        rdm$rtfl_univ.AddDataset ('ds', l_str);

        AddParam ('sgn1',
                  p2.atop_ln || ' ' || p2.atop_fn || ' ' || p2.atop_mn); --Особа, яка провела оцінювання
        AddParam ('sgn3', TO_CHAR (c.at_dt, 'dd.mm.yyyy'));

        --Таблиця 3 Визначення ступеня індивідуальних потреб
        AddParam ('a1', p1.pib);                                   --отримувач
        AddParam ('a2', p1.birth_dt_str);
        AddParam ('a3', p1.live_address);
        AddParam ('a4', p2.atop_ln || ' ' || p2.atop_fn || ' ' || p2.atop_mn);
        AddParam ('a5', TO_CHAR (c.at_dt, 'dd.mm.yyyy'));    --Дата опитування

        --Анкета визначення рейтингу соціальних потреб отримувача соціальної послуги соціальної реабілітації
        --ЖИТЛО/ДОКУМЕНТИ
        AddFtrT3 ('t3.1.1', p1.atp_id, 5826);
        AddFtrT3_2 ('t3.1.2', p2.atop_id, 5826);
        AddFtrT3 ('t3.1.3', p3.atp_id, 5826);
        AddFtrT3 ('t3.2.1', p1.atp_id, 5827);
        AddFtrT3_2 ('t3.2.2', p2.atop_id, 5827);
        AddFtrT3 ('t3.2.3', p3.atp_id, 5827);
        AddFtrT3 ('t3.3.1', p1.atp_id, 5828);
        AddFtrT3_2 ('t3.3.2', p2.atop_id, 5828);
        AddFtrT3 ('t3.3.3', p3.atp_id, 5828);
        AddFtrT3 ('t3.4.1', p1.atp_id, 5829);
        AddFtrT3_2 ('t3.4.2', p2.atop_id, 5829);
        AddFtrT3 ('t3.4.3', p3.atp_id, 5829);
        AddFtrT3 ('t3.5.1', p1.atp_id, 5830);
        AddFtrT3_2 ('t3.5.2', p2.atop_id, 5830);
        AddFtrT3 ('t3.5.3', p3.atp_id, 5830);
        AddFtrT3 ('t3.6.1', p1.atp_id, 5831);
        AddFtrT3_2 ('t3.6.2', p2.atop_id, 5831);
        AddFtrT3 ('t3.6.3', p3.atp_id, 5831);
        --НАВИЧКИ САМОСТІЙНОГО ПРОЖИВАННЯ
        AddFtrT3 ('t3.7.1', p1.atp_id, 5832);
        AddFtrT3_2 ('t3.7.2', p2.atop_id, 5832);
        AddFtrT3 ('t3.7.3', p3.atp_id, 5832);
        AddFtrT3 ('t3.8.1', p1.atp_id, 5833);
        AddFtrT3_2 ('t3.8.2', p2.atop_id, 5833);
        AddFtrT3 ('t3.8.3', p3.atp_id, 5833);
        AddFtrT3 ('t3.9.1', p1.atp_id, 5834);
        AddFtrT3_2 ('t3.9.2', p2.atop_id, 5834);
        AddFtrT3 ('t3.9.3', p3.atp_id, 5834);
        AddFtrT3 ('t3.10.1', p1.atp_id, 5835);
        AddFtrT3_2 ('t3.10.2', p2.atop_id, 5835);
        AddFtrT3 ('t3.10.3', p3.atp_id, 5835);
        AddFtrT3 ('t3.11.1', p1.atp_id, 5836);
        AddFtrT3_2 ('t3.11.2', p2.atop_id, 5836);
        AddFtrT3 ('t3.11.3', p3.atp_id, 5836);
        AddFtrT3 ('t3.12.1', p1.atp_id, 5837);
        AddFtrT3_2 ('t3.12.2', p2.atop_id, 5837);
        AddFtrT3 ('t3.12.3', p3.atp_id, 5837);
        --СФЕРА ЗДОРОВ’Я
        AddFtrT3 ('t3.13.1', p1.atp_id, 5838);
        AddFtrT3_2 ('t3.13.2', p2.atop_id, 5838);
        AddFtrT3 ('t3.13.3', p3.atp_id, 5838);
        AddFtrT3 ('t3.14.1', p1.atp_id, 5839);
        AddFtrT3_2 ('t3.14.2', p2.atop_id, 5839);
        AddFtrT3 ('t3.14.3', p3.atp_id, 5839);
        AddFtrT3 ('t3.15.1', p1.atp_id, 5840);
        AddFtrT3_2 ('t3.15.2', p2.atop_id, 5840);
        AddFtrT3 ('t3.15.3', p3.atp_id, 5840);
        AddFtrT3 ('t3.16.1', p1.atp_id, 5841);
        AddFtrT3_2 ('t3.16.2', p2.atop_id, 5841);
        AddFtrT3 ('t3.16.3', p3.atp_id, 5841);
        AddFtrT3 ('t3.17.1', p1.atp_id, 5842);
        AddFtrT3_2 ('t3.17.2', p2.atop_id, 5842);
        AddFtrT3 ('t3.17.3', p3.atp_id, 5842);
        AddFtrT3 ('t3.18.1', p1.atp_id, 5843);
        AddFtrT3_2 ('t3.18.2', p2.atop_id, 5843);
        AddFtrT3 ('t3.18.3', p3.atp_id, 5843);
        --СОЦІАЛЬНА СФЕРА
        AddFtrT3 ('t3.19.1', p1.atp_id, 5844);
        AddFtrT3_2 ('t3.19.2', p2.atop_id, 5844);
        AddFtrT3 ('t3.19.3', p3.atp_id, 5844);
        AddFtrT3 ('t3.20.1', p1.atp_id, 5845);
        AddFtrT3_2 ('t3.20.2', p2.atop_id, 5845);
        AddFtrT3 ('t3.20.3', p3.atp_id, 5845);
        AddFtrT3 ('t3.21.1', p1.atp_id, 5846);
        AddFtrT3_2 ('t3.21.2', p2.atop_id, 5846);
        AddFtrT3 ('t3.21.3', p3.atp_id, 5846);
        AddFtrT3 ('t3.22.1', p1.atp_id, 5847);
        AddFtrT3_2 ('t3.22.2', p2.atop_id, 5847);
        AddFtrT3 ('t3.22.3', p3.atp_id, 5847);
        AddFtrT3 ('t3.23.1', p1.atp_id, 5848);
        AddFtrT3_2 ('t3.23.2', p2.atop_id, 5848);
        AddFtrT3 ('t3.23.3', p3.atp_id, 5848);
        AddFtrT3 ('t3.24.1', p1.atp_id, 5849);
        AddFtrT3_2 ('t3.24.2', p2.atop_id, 5849);
        AddFtrT3 ('t3.24.3', p3.atp_id, 5849);
        --Загальна сума балів за сферами
        AddParam (
            'itg1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 522).ate_indicator_value1); --Житло/документи
        AddParam (
            'itg2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 523).ate_indicator_value1); --Навички самостійного проживання
        AddParam (
            'itg3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 524).ate_indicator_value1); --Здоров’я
        AddParam (
            'itg4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 525).ate_indicator_value1); --Соціальна сфера

        ------------------------------------
        rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                         p_rpt_blob   => l_result);
        replace_ekr (l_result);

        RETURN l_result;
    END ACT_DOC_896_R1;

    --94135 Оцінювання індивідуальних потреб дитини з інвалідністю для послуги 018.1
    FUNCTION ACT_DOC_898_R1 (p_at_id IN NUMBER)
        RETURN BLOB
    IS
        --секція ЖИТЛО/ДОКУМЕНТИ з розділу "Анкета визначення рейтингу соціальних потреб..."
        C_ATE_NNG_ANK   CONSTANT INTEGER := 343;

        CURSOR c_at IS
            SELECT a.at_dt,
                   a.at_sc,
                   a.At_rnspm,
                   a.at_wu,
                   a.at_cu,
                   a.at_ap
              FROM act a
             WHERE a.at_id = p_at_id;

        c                        c_at%ROWTYPE;

        l_str                    VARCHAR2 (32000);

        p1                       Api$Act_Rpt.R_Person_for_act;     --отримувач
        p2                       at_other_spec%ROWTYPE;             --Фахівець
        p3                       Api$Act_Rpt.R_Person_for_act; --Дитина з інвалідністю

        l_jbr_id                 NUMBER;
        l_result                 BLOB;

        --для Анкети (uss_ndi.V_DDN_SS_TFN1)
        PROCEDURE AddFtrT6 (p_Param_Name   VARCHAR2,
                            p_atp          at_person.atp_id%TYPE,
                            p_nda          NUMBER)
        IS
        BEGIN
            CASE Get_Ftr (p_at_id => p_at_id, p_atp => p_atp, p_nda => p_nda)
                WHEN 'T'
                THEN
                    AddParam (p_Param_Name, 'Так');
                WHEN 'F'
                THEN
                    AddParam (p_Param_Name, 'Ні');
                ELSE
                    AddParam (p_Param_Name, '--');
            END CASE;
        END;

        PROCEDURE AddFtrT6_2 (p_Param_Name   VARCHAR2,
                              p_Atop         At_Section.Ate_Atop%TYPE,
                              p_Nda          NUMBER)
        IS
            CURSOR Cur IS
                SELECT f.Atef_Feature
                  FROM Uss_Esr.At_Section s, Uss_Esr.At_Section_Feature f
                 WHERE     s.Ate_At = p_At_Id
                       AND s.Ate_Atop = p_Atop
                       AND f.Atef_Ate = s.Ate_Id
                       AND f.Atef_Nda = p_Nda;

            l_Res   At_Section_Feature.Atef_Feature%TYPE;
        BEGIN
            OPEN Cur;

            FETCH Cur INTO l_Res;

            CLOSE Cur;

            CASE l_Res
                WHEN 'T'
                THEN
                    Addparam (p_Param_Name, 'Так');
                WHEN 'F'
                THEN
                    Addparam (p_Param_Name, 'Ні');
                ELSE
                    Addparam (p_Param_Name, '--');
            END CASE;
        END;
    BEGIN
        rdm$rtfl_univ.initreport (p_code     => 'ACT_DOC_898_R1',
                                  p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);

        ------------------------------------
        OPEN c_at;

        FETCH c_at INTO c;

        CLOSE c_at;

        --шукаємо по секції з заповненими даними трьох осіб
        SELECT MAX (CASE WHEN p.atp_app_tp = 'OS' THEN p.atp_id END), --батьки
               MAX (
                   CASE
                       WHEN NVL (p.Atp_App_Tp, '***') NOT IN ('OS', 'AP')
                       THEN
                           p.atp_id
                   END)                                --Дитина з інвалідністю
          INTO p1.atp_id, p3.atp_id
          FROM uss_esr.at_section s, at_person p
         WHERE     1 = 1
               AND s.ate_at = p_at_id
               --секція з розділу Таблиця 6 (Анкета для визначення рейтингу соціальних потреб дитини з інвалідністю)
               AND s.ate_nng = C_ATE_NNG_ANK
               AND p.atp_at = s.ate_at
               AND p.atp_id = s.ate_atp;

        p1 := get_AtPerson (p_at => p_at_id, p_atp => p1.atp_id);
        p2 :=
            Get_Sctn_Specialist (p_At_Id         => p_at_id,
                                 p_Ate_Nng_Ank   => C_ATE_NNG_ANK); --Фахівець
        p3 := get_AtPerson (p_at => p_at_id, p_atp => p3.atp_id);


        --Таблиця 2 Шкала оцінювання можливості виконання елементарних дій
        AddParam ('t2.1.1', Get_Ftr_Ind (p_at_id, p_nda => 6810)); --1 Прийом їжі
        AddParam ('t2.1.2', Get_Ftr_Ind (p_at_id, p_nda => 6811));
        AddParam ('t2.1.3', Get_Ftr_Ind (p_at_id, p_nda => 6812));
        AddParam ('t2.1.4', Get_Ftr_Ind (p_at_id, p_nda => 6813));
        AddParam ('t2.1.5', Get_Ftr_Ind (p_at_id, p_nda => 6814));
        AddParam ('t2.1.6', Get_Ftr_Ind (p_at_id, p_nda => 6815));
        AddParam ('t2.1.7', Get_Ftr_Ind (p_at_id, p_nda => 6816));
        AddParam ('t2.1.8', Get_Ftr_Ind (p_at_id, p_nda => 6817));
        AddParam ('t2.1.9', Get_Ftr_Ind (p_at_id, p_nda => 6818));
        AddParam ('t2.2.1', Get_Ftr_Ind (p_at_id, p_nda => 6819)); --2 Купання
        AddParam ('t2.2.2', Get_Ftr_Ind (p_at_id, p_nda => 6820));
        AddParam ('t2.2.3', Get_Ftr_Ind (p_at_id, p_nda => 6821));
        AddParam ('t2.2.4', Get_Ftr_Ind (p_at_id, p_nda => 6822));
        AddParam ('t2.2.5', Get_Ftr_Ind (p_at_id, p_nda => 6823));
        AddParam ('t2.2.6', Get_Ftr_Ind (p_at_id, p_nda => 6824));
        AddParam ('t2.3.1', Get_Ftr_Ind (p_at_id, p_nda => 6825)); --3 Особистий туалет
        AddParam ('t2.3.2', Get_Ftr_Ind (p_at_id, p_nda => 6826));
        AddParam ('t2.3.3', Get_Ftr_Ind (p_at_id, p_nda => 6827));
        AddParam ('t2.3.4', Get_Ftr_Ind (p_at_id, p_nda => 6828));
        AddParam ('t2.3.5', Get_Ftr_Ind (p_at_id, p_nda => 6829));
        AddParam ('t2.3.6', Get_Ftr_Ind (p_at_id, p_nda => 6830));
        AddParam ('t2.4.1', Get_Ftr_Ind (p_at_id, p_nda => 6831)); --4 Одягання і взування
        AddParam ('t2.4.2', Get_Ftr_Ind (p_at_id, p_nda => 6832));
        AddParam ('t2.4.3', Get_Ftr_Ind (p_at_id, p_nda => 6833));
        AddParam ('t2.4.4', Get_Ftr_Ind (p_at_id, p_nda => 6834));
        AddParam ('t2.4.5', Get_Ftr_Ind (p_at_id, p_nda => 6835));
        AddParam ('t2.4.6', Get_Ftr_Ind (p_at_id, p_nda => 6836));
        AddParam ('t2.4.7', Get_Ftr_Ind (p_at_id, p_nda => 6837));
        AddParam ('t2.4.8', Get_Ftr_Ind (p_at_id, p_nda => 6838));
        AddParam ('t2.5.1', Get_Ftr_Ind (p_at_id, p_nda => 6839)); --5 Контроль дефекації
        AddParam ('t2.5.2', Get_Ftr_Ind (p_at_id, p_nda => 6840));
        AddParam ('t2.5.3', Get_Ftr_Ind (p_at_id, p_nda => 6841));
        AddParam ('t2.5.4', Get_Ftr_Ind (p_at_id, p_nda => 6842));
        AddParam ('t2.5.5', Get_Ftr_Ind (p_at_id, p_nda => 6843));
        AddParam ('t2.5.6', Get_Ftr_Ind (p_at_id, p_nda => 6844));
        AddParam ('t2.6.1', Get_Ftr_Ind (p_at_id, p_nda => 6845)); --6 Контроль сечовиділення
        AddParam ('t2.6.2', Get_Ftr_Ind (p_at_id, p_nda => 6846));
        AddParam ('t2.6.3', Get_Ftr_Ind (p_at_id, p_nda => 6847));
        AddParam ('t2.6.4', Get_Ftr_Ind (p_at_id, p_nda => 6848));
        AddParam ('t2.6.5', Get_Ftr_Ind (p_at_id, p_nda => 6849));
        AddParam ('t2.6.6', Get_Ftr_Ind (p_at_id, p_nda => 6850));
        AddParam ('t2.7.1', Get_Ftr_Ind (p_at_id, p_nda => 6851));         --7
        AddParam ('t2.7.2', Get_Ftr_Ind (p_at_id, p_nda => 6852));
        AddParam ('t2.7.3', Get_Ftr_Ind (p_at_id, p_nda => 6853));
        AddParam ('t2.7.4', Get_Ftr_Ind (p_at_id, p_nda => 6854));
        AddParam ('t2.7.5', Get_Ftr_Ind (p_at_id, p_nda => 6855));
        AddParam ('t2.7.6', Get_Ftr_Ind (p_at_id, p_nda => 6856));
        AddParam ('t2.7.7', Get_Ftr_Ind (p_at_id, p_nda => 6857));
        AddParam ('t2.8.1', Get_Ftr_Ind (p_at_id, p_nda => 6858));         --8
        AddParam ('t2.8.2', Get_Ftr_Ind (p_at_id, p_nda => 6859));
        AddParam ('t2.8.3', Get_Ftr_Ind (p_at_id, p_nda => 6860));
        AddParam ('t2.8.4', Get_Ftr_Ind (p_at_id, p_nda => 6861));
        AddParam ('t2.8.5', Get_Ftr_Ind (p_at_id, p_nda => 6862));
        AddParam ('t2.8.6', Get_Ftr_Ind (p_at_id, p_nda => 6863));
        AddParam ('t2.8.7', Get_Ftr_Ind (p_at_id, p_nda => 6864));
        AddParam ('t2.8.8', Get_Ftr_Ind (p_at_id, p_nda => 6865));
        AddParam ('t2.9.1', Get_Ftr_Ind (p_at_id, p_nda => 6866));         --9
        AddParam ('t2.9.2', Get_Ftr_Ind (p_at_id, p_nda => 6867));
        AddParam ('t2.9.3', Get_Ftr_Ind (p_at_id, p_nda => 6868));
        AddParam ('t2.9.4', Get_Ftr_Ind (p_at_id, p_nda => 6869));
        AddParam ('t2.9.5', Get_Ftr_Ind (p_at_id, p_nda => 6870));
        AddParam ('t2.9.6', Get_Ftr_Ind (p_at_id, p_nda => 6871));
        AddParam ('t2.9.7', Get_Ftr_Ind (p_at_id, p_nda => 6872));
        AddParam ('t2.9.8', Get_Ftr_Ind (p_at_id, p_nda => 6873));
        AddParam ('t2.10.1', Get_Ftr_Ind (p_at_id, p_nda => 6874));       --10
        AddParam ('t2.10.2', Get_Ftr_Ind (p_at_id, p_nda => 6875));
        AddParam ('t2.10.3', Get_Ftr_Ind (p_at_id, p_nda => 6876));
        AddParam ('t2.10.4', Get_Ftr_Ind (p_at_id, p_nda => 6877));
        AddParam ('t2.10.5', Get_Ftr_Ind (p_at_id, p_nda => 6878));
        AddParam ('t2.10.6', Get_Ftr_Ind (p_at_id, p_nda => 6879));
        --Сума балів
        AddParam (
            't2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 732).ate_indicator_value1);

        --Таблиця 3 Шкала оцінювання можливості виконання складних дій
        AddParam ('t3.1.1', Get_Ftr_Ind (p_at_id, p_nda => 6880));         --1
        AddParam ('t3.1.2', Get_Ftr_Ind (p_at_id, p_nda => 6881));
        AddParam ('t3.1.3', Get_Ftr_Ind (p_at_id, p_nda => 6882));
        AddParam ('t3.1.4', Get_Ftr_Ind (p_at_id, p_nda => 6883));
        AddParam ('t3.1.5', Get_Ftr_Ind (p_at_id, p_nda => 6884));
        AddParam ('t3.2.1', Get_Ftr_Ind (p_at_id, p_nda => 6885));         --2
        AddParam ('t3.2.2', Get_Ftr_Ind (p_at_id, p_nda => 6886));
        AddParam ('t3.2.3', Get_Ftr_Ind (p_at_id, p_nda => 6887));
        AddParam ('t3.2.4', Get_Ftr_Ind (p_at_id, p_nda => 6888));
        AddParam ('t3.2.5', Get_Ftr_Ind (p_at_id, p_nda => 6889));
        AddParam ('t3.3.1', Get_Ftr_Ind (p_at_id, p_nda => 6890));         --3
        AddParam ('t3.3.2', Get_Ftr_Ind (p_at_id, p_nda => 6891));
        AddParam ('t3.3.3', Get_Ftr_Ind (p_at_id, p_nda => 6892));
        AddParam ('t3.3.4', Get_Ftr_Ind (p_at_id, p_nda => 6893));
        AddParam ('t3.4.1', Get_Ftr_Ind (p_at_id, p_nda => 6894));         --4
        AddParam ('t3.4.2', Get_Ftr_Ind (p_at_id, p_nda => 6895));
        AddParam ('t3.4.3', Get_Ftr_Ind (p_at_id, p_nda => 6896));
        AddParam ('t3.4.4', Get_Ftr_Ind (p_at_id, p_nda => 6897));
        AddParam ('t3.4.5', Get_Ftr_Ind (p_at_id, p_nda => 6898));
        AddParam ('t3.5.1', Get_Ftr_Ind (p_at_id, p_nda => 6899));         --5
        AddParam ('t3.5.2', Get_Ftr_Ind (p_at_id, p_nda => 6900));
        AddParam ('t3.5.3', Get_Ftr_Ind (p_at_id, p_nda => 6901));
        AddParam ('t3.5.4', Get_Ftr_Ind (p_at_id, p_nda => 6902));
        AddParam ('t3.5.5', Get_Ftr_Ind (p_at_id, p_nda => 6903));
        AddParam ('t3.6.1', Get_Ftr_Ind (p_at_id, p_nda => 6904));         --6
        AddParam ('t3.6.2', Get_Ftr_Ind (p_at_id, p_nda => 6905));
        AddParam ('t3.6.3', Get_Ftr_Ind (p_at_id, p_nda => 6906));
        AddParam ('t3.6.4', Get_Ftr_Ind (p_at_id, p_nda => 6907));
        AddParam ('t3.7.1', Get_Ftr_Ind (p_at_id, p_nda => 6908));         --7
        AddParam ('t3.7.2', Get_Ftr_Ind (p_at_id, p_nda => 6909));
        AddParam ('t3.7.3', Get_Ftr_Ind (p_at_id, p_nda => 6910));
        AddParam ('t3.7.4', Get_Ftr_Ind (p_at_id, p_nda => 6911));
        AddParam ('t3.7.5', Get_Ftr_Ind (p_at_id, p_nda => 6912));
        AddParam ('t3.8.1', Get_Ftr_Ind (p_at_id, p_nda => 6913));         --8
        AddParam ('t3.8.2', Get_Ftr_Ind (p_at_id, p_nda => 6914));
        AddParam ('t3.8.3', Get_Ftr_Ind (p_at_id, p_nda => 6915));
        AddParam ('t3.8.4', Get_Ftr_Ind (p_at_id, p_nda => 6916));
        AddParam ('t3.9.1', Get_Ftr_Ind (p_at_id, p_nda => 6917));         --9
        AddParam ('t3.9.2', Get_Ftr_Ind (p_at_id, p_nda => 6918));
        AddParam ('t3.9.3', Get_Ftr_Ind (p_at_id, p_nda => 6919));
        AddParam ('t3.9.4', Get_Ftr_Ind (p_at_id, p_nda => 6920));
        --Сума балів
        AddParam (
            't3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 732).ate_indicator_value2);

        --Таблиця 4 Шкала оцінювання рівня навичок проживання за основними категоріями
        --1 Управління фінансами
        AddParam ('t41.1.1', Get_Ftr_Chk2 (p_at_id, p_nda => 6921)); --Низький
        AddParam ('t41.1.2', Get_Ftr_Chk2 (p_at_id, p_nda => 6922));
        AddParam ('t41.1.3', Get_Ftr_Chk2 (p_at_id, p_nda => 6923));
        AddParam ('t41.1.4', Get_Ftr_Chk2 (p_at_id, p_nda => 6924));
        AddParam ('t41.1.5', Get_Ftr_Chk2 (p_at_id, p_nda => 6925));
        AddParam ('t41.2.1', Get_Ftr_Chk2 (p_at_id, p_nda => 6926)); --Базовий
        AddParam ('t41.2.2', Get_Ftr_Chk2 (p_at_id, p_nda => 6927));
        AddParam ('t41.2.3', Get_Ftr_Chk2 (p_at_id, p_nda => 6928));
        AddParam ('t41.2.4', Get_Ftr_Chk2 (p_at_id, p_nda => 6929));
        AddParam ('t41.2.5', Get_Ftr_Chk2 (p_at_id, p_nda => 6930));
        AddParam ('t41.3.1', Get_Ftr_Chk2 (p_at_id, p_nda => 6931)); --Задовільний
        AddParam ('t41.3.2', Get_Ftr_Chk2 (p_at_id, p_nda => 6932));
        AddParam ('t41.3.3', Get_Ftr_Chk2 (p_at_id, p_nda => 6933));
        AddParam ('t41.3.4', Get_Ftr_Chk2 (p_at_id, p_nda => 6934));
        AddParam ('t41.3.5', Get_Ftr_Chk2 (p_at_id, p_nda => 6935));
        AddParam ('t41.4.1', Get_Ftr_Chk2 (p_at_id, p_nda => 6936));  --Добрий
        AddParam ('t41.4.2', Get_Ftr_Chk2 (p_at_id, p_nda => 6937));
        AddParam ('t41.4.3', Get_Ftr_Chk2 (p_at_id, p_nda => 6938));
        AddParam ('t41.4.4', Get_Ftr_Chk2 (p_at_id, p_nda => 6939));
        AddParam ('t41.4.5', Get_Ftr_Chk2 (p_at_id, p_nda => 6940));
        AddParam ('t41.5.1', Get_Ftr_Chk2 (p_at_id, p_nda => 6941)); --Високий
        AddParam ('t41.5.2', Get_Ftr_Chk2 (p_at_id, p_nda => 6942));
        AddParam ('t41.5.3', Get_Ftr_Chk2 (p_at_id, p_nda => 6943));
        AddParam ('t41.5.4', Get_Ftr_Chk2 (p_at_id, p_nda => 6944));
        AddParam ('t41.5.5', Get_Ftr_Chk2 (p_at_id, p_nda => 6945));
        --2 Організація харчування
        AddParam ('t42.1.1', Get_Ftr_Chk2 (p_at_id, p_nda => 6946)); --Низький
        AddParam ('t42.1.2', Get_Ftr_Chk2 (p_at_id, p_nda => 6947));
        AddParam ('t42.1.3', Get_Ftr_Chk2 (p_at_id, p_nda => 6948));
        AddParam ('t42.1.4', Get_Ftr_Chk2 (p_at_id, p_nda => 6949));
        AddParam ('t42.1.5', Get_Ftr_Chk2 (p_at_id, p_nda => 6950));
        AddParam ('t42.2.1', Get_Ftr_Chk2 (p_at_id, p_nda => 6951)); --Базовий
        AddParam ('t42.2.2', Get_Ftr_Chk2 (p_at_id, p_nda => 6952));
        AddParam ('t42.2.3', Get_Ftr_Chk2 (p_at_id, p_nda => 6953));
        AddParam ('t42.2.4', Get_Ftr_Chk2 (p_at_id, p_nda => 6954));
        AddParam ('t42.2.5', Get_Ftr_Chk2 (p_at_id, p_nda => 6955));
        AddParam ('t42.3.1', Get_Ftr_Chk2 (p_at_id, p_nda => 6956)); --Задовільний
        AddParam ('t42.3.2', Get_Ftr_Chk2 (p_at_id, p_nda => 6957));
        AddParam ('t42.3.3', Get_Ftr_Chk2 (p_at_id, p_nda => 6958));
        AddParam ('t42.3.4', Get_Ftr_Chk2 (p_at_id, p_nda => 6959));
        AddParam ('t42.3.5', Get_Ftr_Chk2 (p_at_id, p_nda => 6960));
        AddParam ('t42.4.1', Get_Ftr_Chk2 (p_at_id, p_nda => 6961));  --Добрий
        AddParam ('t42.4.2', Get_Ftr_Chk2 (p_at_id, p_nda => 6962));
        AddParam ('t42.4.3', Get_Ftr_Chk2 (p_at_id, p_nda => 6963));
        AddParam ('t42.4.4', Get_Ftr_Chk2 (p_at_id, p_nda => 6964));
        AddParam ('t42.4.5', Get_Ftr_Chk2 (p_at_id, p_nda => 6965));
        AddParam ('t42.5.1', Get_Ftr_Chk2 (p_at_id, p_nda => 6966)); --Високий
        AddParam ('t42.5.2', Get_Ftr_Chk2 (p_at_id, p_nda => 6967));
        AddParam ('t42.5.3', Get_Ftr_Chk2 (p_at_id, p_nda => 6968));
        AddParam ('t42.5.4', Get_Ftr_Chk2 (p_at_id, p_nda => 6969));
        AddParam ('t42.5.5', Get_Ftr_Chk2 (p_at_id, p_nda => 6970));
        --3 Зовнішній вигляд
        AddParam ('t43.1.1', Get_Ftr_Chk2 (p_at_id, p_nda => 6971)); --Низький
        AddParam ('t43.1.2', Get_Ftr_Chk2 (p_at_id, p_nda => 6972));
        AddParam ('t43.1.3', Get_Ftr_Chk2 (p_at_id, p_nda => 6973));
        AddParam ('t43.1.4', Get_Ftr_Chk2 (p_at_id, p_nda => 6974));
        AddParam ('t43.1.5', Get_Ftr_Chk2 (p_at_id, p_nda => 6975));
        AddParam ('t43.2.1', Get_Ftr_Chk2 (p_at_id, p_nda => 6976)); --Базовий
        AddParam ('t43.2.2', Get_Ftr_Chk2 (p_at_id, p_nda => 6977));
        AddParam ('t43.2.3', Get_Ftr_Chk2 (p_at_id, p_nda => 6978));
        AddParam ('t43.2.4', Get_Ftr_Chk2 (p_at_id, p_nda => 6979));
        AddParam ('t43.2.5', Get_Ftr_Chk2 (p_at_id, p_nda => 6980));
        AddParam ('t43.3.1', Get_Ftr_Chk2 (p_at_id, p_nda => 6981)); --Задовільний
        AddParam ('t43.3.2', Get_Ftr_Chk2 (p_at_id, p_nda => 6982));
        AddParam ('t43.3.3', Get_Ftr_Chk2 (p_at_id, p_nda => 6983));
        AddParam ('t43.3.4', Get_Ftr_Chk2 (p_at_id, p_nda => 6984));
        AddParam ('t43.3.5', Get_Ftr_Chk2 (p_at_id, p_nda => 6985));
        AddParam ('t43.4.1', Get_Ftr_Chk2 (p_at_id, p_nda => 6986));  --Добрий
        AddParam ('t43.4.2', Get_Ftr_Chk2 (p_at_id, p_nda => 6987));
        AddParam ('t43.4.3', Get_Ftr_Chk2 (p_at_id, p_nda => 6988));
        AddParam ('t43.4.4', Get_Ftr_Chk2 (p_at_id, p_nda => 6989));
        AddParam ('t43.4.5', Get_Ftr_Chk2 (p_at_id, p_nda => 6990));
        AddParam ('t43.5.1', Get_Ftr_Chk2 (p_at_id, p_nda => 6991)); --Високий
        AddParam ('t43.5.2', Get_Ftr_Chk2 (p_at_id, p_nda => 6992));
        AddParam ('t43.5.3', Get_Ftr_Chk2 (p_at_id, p_nda => 6993));
        AddParam ('t43.5.4', Get_Ftr_Chk2 (p_at_id, p_nda => 6994));
        AddParam ('t43.5.5', Get_Ftr_Chk2 (p_at_id, p_nda => 6995));
        --4 Здоров’я
        AddParam ('t44.1.1', Get_Ftr_Chk2 (p_at_id, p_nda => 6996)); --Низький
        AddParam ('t44.1.2', Get_Ftr_Chk2 (p_at_id, p_nda => 6997));
        AddParam ('t44.1.3', Get_Ftr_Chk2 (p_at_id, p_nda => 6998));
        AddParam ('t44.1.4', Get_Ftr_Chk2 (p_at_id, p_nda => 6999));
        AddParam ('t44.1.5', Get_Ftr_Chk2 (p_at_id, p_nda => 7000));
        AddParam ('t44.2.1', Get_Ftr_Chk2 (p_at_id, p_nda => 7001)); --Базовий
        AddParam ('t44.2.2', Get_Ftr_Chk2 (p_at_id, p_nda => 7002));
        AddParam ('t44.2.3', Get_Ftr_Chk2 (p_at_id, p_nda => 7003));
        AddParam ('t44.2.4', Get_Ftr_Chk2 (p_at_id, p_nda => 7004));
        AddParam ('t44.2.5', Get_Ftr_Chk2 (p_at_id, p_nda => 7005));
        AddParam ('t44.3.1', Get_Ftr_Chk2 (p_at_id, p_nda => 7006)); --Задовільний
        AddParam ('t44.3.2', Get_Ftr_Chk2 (p_at_id, p_nda => 7007));
        AddParam ('t44.3.3', Get_Ftr_Chk2 (p_at_id, p_nda => 7008));
        AddParam ('t44.3.4', Get_Ftr_Chk2 (p_at_id, p_nda => 7009));
        AddParam ('t44.3.5', Get_Ftr_Chk2 (p_at_id, p_nda => 7010));
        AddParam ('t44.4.1', Get_Ftr_Chk2 (p_at_id, p_nda => 7011));  --Добрий
        AddParam ('t44.4.2', Get_Ftr_Chk2 (p_at_id, p_nda => 7012));
        AddParam ('t44.4.3', Get_Ftr_Chk2 (p_at_id, p_nda => 7013));
        AddParam ('t44.4.4', Get_Ftr_Chk2 (p_at_id, p_nda => 7014));
        AddParam ('t44.4.5', Get_Ftr_Chk2 (p_at_id, p_nda => 7015));
        AddParam ('t44.5.1', Get_Ftr_Chk2 (p_at_id, p_nda => 7016)); --Високий
        AddParam ('t44.5.2', Get_Ftr_Chk2 (p_at_id, p_nda => 7017));
        AddParam ('t44.5.3', Get_Ftr_Chk2 (p_at_id, p_nda => 7018));
        AddParam ('t44.5.4', Get_Ftr_Chk2 (p_at_id, p_nda => 7019));
        AddParam ('t44.5.5', Get_Ftr_Chk2 (p_at_id, p_nda => 7020));
        --5 Утримання помешкання
        AddParam ('t45.1.1', Get_Ftr_Chk2 (p_at_id, p_nda => 7021)); --Низький
        AddParam ('t45.1.2', Get_Ftr_Chk2 (p_at_id, p_nda => 7022));
        AddParam ('t45.1.3', Get_Ftr_Chk2 (p_at_id, p_nda => 7023));
        AddParam ('t45.1.4', Get_Ftr_Chk2 (p_at_id, p_nda => 7024));
        AddParam ('t45.1.5', Get_Ftr_Chk2 (p_at_id, p_nda => 7025));
        AddParam ('t45.2.1', Get_Ftr_Chk2 (p_at_id, p_nda => 7026)); --Базовий
        AddParam ('t45.2.2', Get_Ftr_Chk2 (p_at_id, p_nda => 7027));
        AddParam ('t45.2.3', Get_Ftr_Chk2 (p_at_id, p_nda => 7028));
        AddParam ('t45.2.4', Get_Ftr_Chk2 (p_at_id, p_nda => 7029));
        AddParam ('t45.2.5', Get_Ftr_Chk2 (p_at_id, p_nda => 7030));
        AddParam ('t45.3.1', Get_Ftr_Chk2 (p_at_id, p_nda => 7031)); --Задовільний
        AddParam ('t45.3.2', Get_Ftr_Chk2 (p_at_id, p_nda => 7032));
        AddParam ('t45.3.3', Get_Ftr_Chk2 (p_at_id, p_nda => 7033));
        AddParam ('t45.3.4', Get_Ftr_Chk2 (p_at_id, p_nda => 7034));
        AddParam ('t45.3.5', Get_Ftr_Chk2 (p_at_id, p_nda => 7035));
        AddParam ('t45.4.1', Get_Ftr_Chk2 (p_at_id, p_nda => 7036));  --Добрий
        AddParam ('t45.4.2', Get_Ftr_Chk2 (p_at_id, p_nda => 7037));
        AddParam ('t45.4.3', Get_Ftr_Chk2 (p_at_id, p_nda => 7038));
        AddParam ('t45.4.4', Get_Ftr_Chk2 (p_at_id, p_nda => 7039));
        AddParam ('t45.4.5', Get_Ftr_Chk2 (p_at_id, p_nda => 7040));
        AddParam ('t45.5.1', Get_Ftr_Chk2 (p_at_id, p_nda => 7041)); --Високий
        AddParam ('t45.5.2', Get_Ftr_Chk2 (p_at_id, p_nda => 7042));
        AddParam ('t45.5.3', Get_Ftr_Chk2 (p_at_id, p_nda => 7043));
        AddParam ('t45.5.4', Get_Ftr_Chk2 (p_at_id, p_nda => 7044));
        AddParam ('t45.5.5', Get_Ftr_Chk2 (p_at_id, p_nda => 7045));
        --6 Користування транспортом
        AddParam ('t46.1.1', Get_Ftr_Chk2 (p_at_id, p_nda => 7046)); --Низький
        AddParam ('t46.1.2', Get_Ftr_Chk2 (p_at_id, p_nda => 7047));
        AddParam ('t46.1.3', Get_Ftr_Chk2 (p_at_id, p_nda => 7048));
        AddParam ('t46.1.4', Get_Ftr_Chk2 (p_at_id, p_nda => 7049));
        AddParam ('t46.1.5', Get_Ftr_Chk2 (p_at_id, p_nda => 7050));
        AddParam ('t46.2.1', Get_Ftr_Chk2 (p_at_id, p_nda => 7051)); --Базовий
        AddParam ('t46.2.2', Get_Ftr_Chk2 (p_at_id, p_nda => 7052));
        AddParam ('t46.2.3', Get_Ftr_Chk2 (p_at_id, p_nda => 7053));
        AddParam ('t46.2.4', Get_Ftr_Chk2 (p_at_id, p_nda => 7054));
        AddParam ('t46.2.5', Get_Ftr_Chk2 (p_at_id, p_nda => 7055));
        AddParam ('t46.3.1', Get_Ftr_Chk2 (p_at_id, p_nda => 7056)); --Задовільний
        AddParam ('t46.3.2', Get_Ftr_Chk2 (p_at_id, p_nda => 7057));
        AddParam ('t46.3.3', Get_Ftr_Chk2 (p_at_id, p_nda => 7058));
        AddParam ('t46.3.4', Get_Ftr_Chk2 (p_at_id, p_nda => 7059));
        AddParam ('t46.3.5', Get_Ftr_Chk2 (p_at_id, p_nda => 7060));
        AddParam ('t46.4.1', Get_Ftr_Chk2 (p_at_id, p_nda => 7061));  --Добрий
        AddParam ('t46.4.2', Get_Ftr_Chk2 (p_at_id, p_nda => 7062));
        AddParam ('t46.4.3', Get_Ftr_Chk2 (p_at_id, p_nda => 7063));
        AddParam ('t46.4.4', Get_Ftr_Chk2 (p_at_id, p_nda => 7064));
        AddParam ('t46.4.5', Get_Ftr_Chk2 (p_at_id, p_nda => 7065));
        AddParam ('t46.5.1', Get_Ftr_Chk2 (p_at_id, p_nda => 7066)); --Високий
        AddParam ('t46.5.2', Get_Ftr_Chk2 (p_at_id, p_nda => 7067));
        AddParam ('t46.5.3', Get_Ftr_Chk2 (p_at_id, p_nda => 7068));
        AddParam ('t46.5.4', Get_Ftr_Chk2 (p_at_id, p_nda => 7069));
        AddParam ('t46.5.5', Get_Ftr_Chk2 (p_at_id, p_nda => 7070));
        --7 Організація навчального процесу
        AddParam ('t47.1.1', Get_Ftr_Chk2 (p_at_id, p_nda => 7066)); --Низький
        AddParam ('t47.1.2', Get_Ftr_Chk2 (p_at_id, p_nda => 7067));
        AddParam ('t47.1.3', Get_Ftr_Chk2 (p_at_id, p_nda => 7068));
        AddParam ('t47.1.4', Get_Ftr_Chk2 (p_at_id, p_nda => 7069));
        AddParam ('t47.1.5', Get_Ftr_Chk2 (p_at_id, p_nda => 7070));
        AddParam ('t47.2.1', Get_Ftr_Chk2 (p_at_id, p_nda => 7071)); --Базовий
        AddParam ('t47.2.2', Get_Ftr_Chk2 (p_at_id, p_nda => 7072));
        AddParam ('t47.2.3', Get_Ftr_Chk2 (p_at_id, p_nda => 7073));
        AddParam ('t47.2.4', Get_Ftr_Chk2 (p_at_id, p_nda => 7074));
        AddParam ('t47.2.5', Get_Ftr_Chk2 (p_at_id, p_nda => 7075));
        AddParam ('t47.3.1', Get_Ftr_Chk2 (p_at_id, p_nda => 7076)); --Задовільний
        AddParam ('t47.3.2', Get_Ftr_Chk2 (p_at_id, p_nda => 7077));
        AddParam ('t47.3.3', Get_Ftr_Chk2 (p_at_id, p_nda => 7078));
        AddParam ('t47.3.4', Get_Ftr_Chk2 (p_at_id, p_nda => 7079));
        AddParam ('t47.3.5', Get_Ftr_Chk2 (p_at_id, p_nda => 7080));
        AddParam ('t47.4.1', Get_Ftr_Chk2 (p_at_id, p_nda => 7081));  --Добрий
        AddParam ('t47.4.2', Get_Ftr_Chk2 (p_at_id, p_nda => 7082));
        AddParam ('t47.4.3', Get_Ftr_Chk2 (p_at_id, p_nda => 7083));
        AddParam ('t47.4.4', Get_Ftr_Chk2 (p_at_id, p_nda => 7084));
        AddParam ('t47.4.5', Get_Ftr_Chk2 (p_at_id, p_nda => 7085));
        AddParam ('t47.5.1', Get_Ftr_Chk2 (p_at_id, p_nda => 7086)); --Високий
        AddParam ('t47.5.2', Get_Ftr_Chk2 (p_at_id, p_nda => 7087));
        AddParam ('t47.5.3', Get_Ftr_Chk2 (p_at_id, p_nda => 7088));
        AddParam ('t47.5.4', Get_Ftr_Chk2 (p_at_id, p_nda => 7089));
        AddParam ('t47.5.5', Get_Ftr_Chk2 (p_at_id, p_nda => 7090));
        --8 Навички пошуку роботи
        AddParam ('t48.1.1', Get_Ftr_Chk2 (p_at_id, p_nda => 7096)); --Низький
        AddParam ('t48.1.2', Get_Ftr_Chk2 (p_at_id, p_nda => 7097));
        AddParam ('t48.1.3', Get_Ftr_Chk2 (p_at_id, p_nda => 7098));
        AddParam ('t48.1.4', Get_Ftr_Chk2 (p_at_id, p_nda => 7099));
        AddParam ('t48.1.5', Get_Ftr_Chk2 (p_at_id, p_nda => 7100));
        AddParam ('t48.2.1', Get_Ftr_Chk2 (p_at_id, p_nda => 7101)); --Базовий
        AddParam ('t48.2.2', Get_Ftr_Chk2 (p_at_id, p_nda => 7102));
        AddParam ('t48.2.3', Get_Ftr_Chk2 (p_at_id, p_nda => 7103));
        AddParam ('t48.2.4', Get_Ftr_Chk2 (p_at_id, p_nda => 7104));
        AddParam ('t48.2.5', Get_Ftr_Chk2 (p_at_id, p_nda => 7105));
        AddParam ('t48.3.1', Get_Ftr_Chk2 (p_at_id, p_nda => 7106)); --Задовільний
        AddParam ('t48.3.2', Get_Ftr_Chk2 (p_at_id, p_nda => 7107));
        AddParam ('t48.3.3', Get_Ftr_Chk2 (p_at_id, p_nda => 7108));
        AddParam ('t48.3.4', Get_Ftr_Chk2 (p_at_id, p_nda => 7109));
        AddParam ('t48.3.5', Get_Ftr_Chk2 (p_at_id, p_nda => 7110));
        AddParam ('t48.4.1', Get_Ftr_Chk2 (p_at_id, p_nda => 7111));  --Добрий
        AddParam ('t48.4.2', Get_Ftr_Chk2 (p_at_id, p_nda => 7112));
        AddParam ('t48.4.3', Get_Ftr_Chk2 (p_at_id, p_nda => 7113));
        AddParam ('t48.4.4', Get_Ftr_Chk2 (p_at_id, p_nda => 7114));
        AddParam ('t48.4.5', Get_Ftr_Chk2 (p_at_id, p_nda => 7115));
        AddParam ('t48.5.1', Get_Ftr_Chk2 (p_at_id, p_nda => 7116)); --Високий
        AddParam ('t48.5.2', Get_Ftr_Chk2 (p_at_id, p_nda => 7117));
        AddParam ('t48.5.3', Get_Ftr_Chk2 (p_at_id, p_nda => 7118));
        AddParam ('t48.5.4', Get_Ftr_Chk2 (p_at_id, p_nda => 7119));
        AddParam ('t48.5.5', Get_Ftr_Chk2 (p_at_id, p_nda => 7120));
        --9 Організація роботи (зайнятості)
        AddParam ('t49.1.1', Get_Ftr_Chk2 (p_at_id, p_nda => 7121)); --Низький
        AddParam ('t49.1.2', Get_Ftr_Chk2 (p_at_id, p_nda => 7122));
        AddParam ('t49.1.3', Get_Ftr_Chk2 (p_at_id, p_nda => 7123));
        AddParam ('t49.1.4', Get_Ftr_Chk2 (p_at_id, p_nda => 7124));
        AddParam ('t49.1.5', Get_Ftr_Chk2 (p_at_id, p_nda => 7125));
        AddParam ('t49.2.1', Get_Ftr_Chk2 (p_at_id, p_nda => 7126)); --Базовий
        AddParam ('t49.2.2', Get_Ftr_Chk2 (p_at_id, p_nda => 7127));
        AddParam ('t49.2.3', Get_Ftr_Chk2 (p_at_id, p_nda => 7128));
        AddParam ('t49.2.4', Get_Ftr_Chk2 (p_at_id, p_nda => 7129));
        AddParam ('t49.2.5', Get_Ftr_Chk2 (p_at_id, p_nda => 7130));
        AddParam ('t49.3.1', Get_Ftr_Chk2 (p_at_id, p_nda => 7131)); --Задовільний
        AddParam ('t49.3.2', Get_Ftr_Chk2 (p_at_id, p_nda => 7132));
        AddParam ('t49.3.3', Get_Ftr_Chk2 (p_at_id, p_nda => 7133));
        AddParam ('t49.3.4', Get_Ftr_Chk2 (p_at_id, p_nda => 7134));
        AddParam ('t49.3.5', Get_Ftr_Chk2 (p_at_id, p_nda => 7135));
        AddParam ('t49.4.1', Get_Ftr_Chk2 (p_at_id, p_nda => 7136));  --Добрий
        AddParam ('t49.4.2', Get_Ftr_Chk2 (p_at_id, p_nda => 7137));
        AddParam ('t49.4.3', Get_Ftr_Chk2 (p_at_id, p_nda => 7138));
        AddParam ('t49.4.4', Get_Ftr_Chk2 (p_at_id, p_nda => 7139));
        AddParam ('t49.4.5', Get_Ftr_Chk2 (p_at_id, p_nda => 7140));
        AddParam ('t49.5.1', Get_Ftr_Chk2 (p_at_id, p_nda => 7141)); --Високий
        AddParam ('t49.5.2', Get_Ftr_Chk2 (p_at_id, p_nda => 7142));
        AddParam ('t49.5.3', Get_Ftr_Chk2 (p_at_id, p_nda => 7143));
        AddParam ('t49.5.4', Get_Ftr_Chk2 (p_at_id, p_nda => 7144));
        AddParam ('t49.5.5', Get_Ftr_Chk2 (p_at_id, p_nda => 7145));
        --10 Дотримання правил безпеки та поведінки в разі надзвичайних ситуацій
        AddParam ('t410.1.1', Get_Ftr_Chk2 (p_at_id, p_nda => 7146)); --Низький
        AddParam ('t410.1.2', Get_Ftr_Chk2 (p_at_id, p_nda => 7147));
        AddParam ('t410.1.3', Get_Ftr_Chk2 (p_at_id, p_nda => 7148));
        AddParam ('t410.1.4', Get_Ftr_Chk2 (p_at_id, p_nda => 7149));
        AddParam ('t410.1.5', Get_Ftr_Chk2 (p_at_id, p_nda => 7150));
        AddParam ('t410.2.1', Get_Ftr_Chk2 (p_at_id, p_nda => 7151)); --Базовий
        AddParam ('t410.2.2', Get_Ftr_Chk2 (p_at_id, p_nda => 7152));
        AddParam ('t410.2.3', Get_Ftr_Chk2 (p_at_id, p_nda => 7153));
        AddParam ('t410.2.4', Get_Ftr_Chk2 (p_at_id, p_nda => 7154));
        AddParam ('t410.2.5', Get_Ftr_Chk2 (p_at_id, p_nda => 7155));
        AddParam ('t410.3.1', Get_Ftr_Chk2 (p_at_id, p_nda => 7156)); --Задовільний
        AddParam ('t410.3.2', Get_Ftr_Chk2 (p_at_id, p_nda => 7157));
        AddParam ('t410.3.3', Get_Ftr_Chk2 (p_at_id, p_nda => 7158));
        AddParam ('t410.3.4', Get_Ftr_Chk2 (p_at_id, p_nda => 7159));
        AddParam ('t410.3.5', Get_Ftr_Chk2 (p_at_id, p_nda => 7160));
        AddParam ('t410.4.1', Get_Ftr_Chk2 (p_at_id, p_nda => 7161)); --Добрий
        AddParam ('t410.4.2', Get_Ftr_Chk2 (p_at_id, p_nda => 7162));
        AddParam ('t410.4.3', Get_Ftr_Chk2 (p_at_id, p_nda => 7163));
        AddParam ('t410.4.4', Get_Ftr_Chk2 (p_at_id, p_nda => 7164));
        AddParam ('t410.4.5', Get_Ftr_Chk2 (p_at_id, p_nda => 7165));
        AddParam ('t410.5.1', Get_Ftr_Chk2 (p_at_id, p_nda => 7166)); --Високий
        AddParam ('t410.5.2', Get_Ftr_Chk2 (p_at_id, p_nda => 7167));
        AddParam ('t410.5.3', Get_Ftr_Chk2 (p_at_id, p_nda => 7168));
        AddParam ('t410.5.4', Get_Ftr_Chk2 (p_at_id, p_nda => 7169));
        AddParam ('t410.5.5', Get_Ftr_Chk2 (p_at_id, p_nda => 7170));
        --11 Знання ресурсів громади
        AddParam ('t411.1.1', Get_Ftr_Chk2 (p_at_id, p_nda => 7171)); --Низький
        AddParam ('t411.1.2', Get_Ftr_Chk2 (p_at_id, p_nda => 7172));
        AddParam ('t411.1.3', Get_Ftr_Chk2 (p_at_id, p_nda => 7173));
        AddParam ('t411.1.4', Get_Ftr_Chk2 (p_at_id, p_nda => 7174));
        AddParam ('t411.1.5', Get_Ftr_Chk2 (p_at_id, p_nda => 7175));
        AddParam ('t411.2.1', Get_Ftr_Chk2 (p_at_id, p_nda => 7176)); --Базовий
        AddParam ('t411.2.2', Get_Ftr_Chk2 (p_at_id, p_nda => 7177));
        AddParam ('t411.2.3', Get_Ftr_Chk2 (p_at_id, p_nda => 7178));
        AddParam ('t411.2.4', Get_Ftr_Chk2 (p_at_id, p_nda => 7179));
        AddParam ('t411.2.5', Get_Ftr_Chk2 (p_at_id, p_nda => 7180));
        AddParam ('t411.3.1', Get_Ftr_Chk2 (p_at_id, p_nda => 7181)); --Задовільний
        AddParam ('t411.3.2', Get_Ftr_Chk2 (p_at_id, p_nda => 7182));
        AddParam ('t411.3.3', Get_Ftr_Chk2 (p_at_id, p_nda => 7183));
        AddParam ('t411.3.4', Get_Ftr_Chk2 (p_at_id, p_nda => 7184));
        AddParam ('t411.3.5', Get_Ftr_Chk2 (p_at_id, p_nda => 7185));
        AddParam ('t411.4.1', Get_Ftr_Chk2 (p_at_id, p_nda => 7186)); --Добрий
        AddParam ('t411.4.2', Get_Ftr_Chk2 (p_at_id, p_nda => 7187));
        AddParam ('t411.4.3', Get_Ftr_Chk2 (p_at_id, p_nda => 7188));
        AddParam ('t411.4.4', Get_Ftr_Chk2 (p_at_id, p_nda => 7189));
        AddParam ('t411.4.5', Get_Ftr_Chk2 (p_at_id, p_nda => 7190));
        AddParam ('t411.5.1', Get_Ftr_Chk2 (p_at_id, p_nda => 7191)); --Високий
        AddParam ('t411.5.2', Get_Ftr_Chk2 (p_at_id, p_nda => 7192));
        AddParam ('t411.5.3', Get_Ftr_Chk2 (p_at_id, p_nda => 7193));
        AddParam ('t411.5.4', Get_Ftr_Chk2 (p_at_id, p_nda => 7194));
        AddParam ('t411.5.5', Get_Ftr_Chk2 (p_at_id, p_nda => 7195));
        --12 Міжособистісні відносини
        AddParam ('t412.1.1', Get_Ftr_Chk2 (p_at_id, p_nda => 7196)); --Низький
        AddParam ('t412.1.2', Get_Ftr_Chk2 (p_at_id, p_nda => 7197));
        AddParam ('t412.1.3', Get_Ftr_Chk2 (p_at_id, p_nda => 7198));
        AddParam ('t412.1.4', Get_Ftr_Chk2 (p_at_id, p_nda => 7199));
        AddParam ('t412.1.5', Get_Ftr_Chk2 (p_at_id, p_nda => 7200));
        AddParam ('t412.2.1', Get_Ftr_Chk2 (p_at_id, p_nda => 7201)); --Базовий
        AddParam ('t412.2.2', Get_Ftr_Chk2 (p_at_id, p_nda => 7202));
        AddParam ('t412.2.3', Get_Ftr_Chk2 (p_at_id, p_nda => 7203));
        AddParam ('t412.2.4', Get_Ftr_Chk2 (p_at_id, p_nda => 7204));
        AddParam ('t412.2.5', Get_Ftr_Chk2 (p_at_id, p_nda => 7205));
        AddParam ('t412.3.1', Get_Ftr_Chk2 (p_at_id, p_nda => 7206)); --Задовільний
        AddParam ('t412.3.2', Get_Ftr_Chk2 (p_at_id, p_nda => 7207));
        AddParam ('t412.3.3', Get_Ftr_Chk2 (p_at_id, p_nda => 7208));
        AddParam ('t412.3.4', Get_Ftr_Chk2 (p_at_id, p_nda => 7209));
        AddParam ('t412.3.5', Get_Ftr_Chk2 (p_at_id, p_nda => 7210));
        AddParam ('t412.4.1', Get_Ftr_Chk2 (p_at_id, p_nda => 7211)); --Добрий
        AddParam ('t412.4.2', Get_Ftr_Chk2 (p_at_id, p_nda => 7212));
        AddParam ('t412.4.3', Get_Ftr_Chk2 (p_at_id, p_nda => 7213));
        AddParam ('t412.4.4', Get_Ftr_Chk2 (p_at_id, p_nda => 7214));
        AddParam ('t412.4.5', Get_Ftr_Chk2 (p_at_id, p_nda => 7215));
        AddParam ('t412.5.1', Get_Ftr_Chk2 (p_at_id, p_nda => 7216)); --Високий
        AddParam ('t412.5.2', Get_Ftr_Chk2 (p_at_id, p_nda => 7217));
        AddParam ('t412.5.3', Get_Ftr_Chk2 (p_at_id, p_nda => 7218));
        AddParam ('t412.5.4', Get_Ftr_Chk2 (p_at_id, p_nda => 7219));
        AddParam ('t412.5.5', Get_Ftr_Chk2 (p_at_id, p_nda => 7220));

        --Таблиця 5 Картка визначення рівня індивідуальних потреб дитини з інвалідністю (ітоги з Таблиці 4)
        --Управління фінансами
        AddParam (
            't51.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 733).ate_indicator_value1); --Низький
        AddParam (
            't51.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 734).ate_indicator_value1); --Базовий
        AddParam (
            't51.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 735).ate_indicator_value1); --Задовільний
        AddParam (
            't51.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 736).ate_indicator_value1); --Добрий
        AddParam (
            't51.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 737).ate_indicator_value1); --Високий
        --Організація харчування
        AddParam (
            't52.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 738).ate_indicator_value1); --Низький
        AddParam (
            't52.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 739).ate_indicator_value1); --Базовий
        AddParam (
            't52.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 740).ate_indicator_value1); --Задовільний
        AddParam (
            't52.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 741).ate_indicator_value1); --Добрий
        AddParam (
            't52.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 742).ate_indicator_value1); --Високий
        --3 Зовнішній вигляд
        AddParam (
            't53.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 743).ate_indicator_value1); --Низький
        AddParam (
            't53.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 744).ate_indicator_value1); --Базовий
        AddParam (
            't53.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 745).ate_indicator_value1); --Задовільний
        AddParam (
            't53.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 746).ate_indicator_value1); --Добрий
        AddParam (
            't53.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 747).ate_indicator_value1); --Високий
        --4 Здоров’я
        AddParam (
            't54.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 748).ate_indicator_value1); --Низький
        AddParam (
            't54.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 749).ate_indicator_value1); --Базовий
        AddParam (
            't54.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 750).ate_indicator_value1); --Задовільний
        AddParam (
            't54.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 751).ate_indicator_value1); --Добрий
        AddParam (
            't54.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 752).ate_indicator_value1); --Високий
        --5 Утримання помешкання
        AddParam (
            't55.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 753).ate_indicator_value1); --Низький
        AddParam (
            't55.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 754).ate_indicator_value1); --Базовий
        AddParam (
            't55.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 755).ate_indicator_value1); --Задовільний
        AddParam (
            't55.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 756).ate_indicator_value1); --Добрий
        AddParam (
            't55.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 757).ate_indicator_value1); --Високий
        --6 Користування транспортом
        AddParam (
            't56.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 758).ate_indicator_value1); --Низький
        AddParam (
            't56.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 759).ate_indicator_value1); --Базовий
        AddParam (
            't56.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 760).ate_indicator_value1); --Задовільний
        AddParam (
            't56.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 761).ate_indicator_value1); --Добрий
        AddParam (
            't56.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 762).ate_indicator_value1); --Високий
        --7 Організація навчального процесу
        AddParam (
            't57.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 763).ate_indicator_value1); --Низький
        AddParam (
            't57.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 764).ate_indicator_value1); --Базовий
        AddParam (
            't57.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 765).ate_indicator_value1); --Задовільний
        AddParam (
            't57.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 766).ate_indicator_value1); --Добрий
        AddParam (
            't57.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 767).ate_indicator_value1); --Високий
        --8 Навички пошуку роботи
        AddParam (
            't58.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 768).ate_indicator_value1); --Низький
        AddParam (
            't58.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 769).ate_indicator_value1); --Базовий
        AddParam (
            't58.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 770).ate_indicator_value1); --Задовільний
        AddParam (
            't58.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 771).ate_indicator_value1); --Добрий
        AddParam (
            't58.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 772).ate_indicator_value1); --Високий
        --9 Організація роботи (зайнятості)
        AddParam (
            't59.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 773).ate_indicator_value1); --Низький
        AddParam (
            't59.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 774).ate_indicator_value1); --Базовий
        AddParam (
            't59.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 775).ate_indicator_value1); --Задовільний
        AddParam (
            't59.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 776).ate_indicator_value1); --Добрий
        AddParam (
            't59.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 777).ate_indicator_value1); --Високий
        --10 Дотримання правил безпеки та поведінки в разі надзвичайних ситуацій
        AddParam (
            't510.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 778).ate_indicator_value1); --Низький
        AddParam (
            't510.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 779).ate_indicator_value1); --Базовий
        AddParam (
            't510.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 780).ate_indicator_value1); --Задовільний
        AddParam (
            't510.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 781).ate_indicator_value1); --Добрий
        AddParam (
            't510.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 782).ate_indicator_value1); --Високий
        --11 Знання ресурсів громади
        AddParam (
            't511.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 783).ate_indicator_value1); --Низький
        AddParam (
            't511.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 784).ate_indicator_value1); --Базовий
        AddParam (
            't511.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 785).ate_indicator_value1); --Задовільний
        AddParam (
            't511.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 786).ate_indicator_value1); --Добрий
        AddParam (
            't511.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 787).ate_indicator_value1); --Високий
        --12 Міжособистісні відносини
        AddParam (
            't512.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 788).ate_indicator_value1); --Низький
        AddParam (
            't512.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 789).ate_indicator_value1); --Базовий
        AddParam (
            't512.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 790).ate_indicator_value1); --Задовільний
        AddParam (
            't512.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 791).ate_indicator_value1); --Добрий
        AddParam (
            't512.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 792).ate_indicator_value1); --Високий
        --Загальна кількість балів nng_id = 793
        AddParam ('t51', Get_Ftr_Nt (p_at_id, p_nda => 7221));
        AddParam ('t52', Get_Ftr_Nt (p_at_id, p_nda => 7222));
        AddParam ('t53', Get_Ftr_Nt (p_at_id, p_nda => 7223));
        AddParam ('t54', Get_Ftr_Nt (p_at_id, p_nda => 7224));
        AddParam ('t55', Get_Ftr_Nt (p_at_id, p_nda => 7225));
        AddParam ('t56', Get_Ftr_Nt (p_at_id, p_nda => 7226));
        AddParam ('t57', Get_Ftr_Nt (p_at_id, p_nda => 7227));
        AddParam ('t58', Get_Ftr_Nt (p_at_id, p_nda => 7228));
        AddParam ('t59', Get_Ftr_Nt (p_at_id, p_nda => 7229));
        AddParam ('t510', Get_Ftr_Nt (p_at_id, p_nda => 7230));
        AddParam ('t511', Get_Ftr_Nt (p_at_id, p_nda => 7231));
        AddParam ('t512', Get_Ftr_Nt (p_at_id, p_nda => 7232));


        --Висновок
        AddParam ('v1', p3.pib);                                      --дитина
        AddParam (
            'v2',
            NVL (
                Api$Act_Rpt.v_ddn (
                    'uss_ndi.V_DDN_SS_LEVEL_LIV_SKL1',
                    Api$Act_Rpt.Get_Ftr (p_at_id, p_nda => 7233)),
                '______'));                                         --на рівні
        AddParam (
            'v3',
            NVL (
                TO_CHAR (
                    Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 793).ate_indicator_value1),
                '______'));                                     --усього балів
        AddParam (
            'v4',
            NVL (
                TO_CHAR (
                    Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 793).ate_indicator_value2),
                '______'));                               --в середньому годин

        --Особи, які брали участь в оцінюванні
        l_str :=
            q'[
    select p.pib                  as c1,
           p.Relation_Tp          as c2,
           null                   as c3,
           api$act_rpt.get_sign_mark(:p_at_id, p.Atp_Id, '') as c4
      from uss_esr.at_section s, table(uss_esr.Api$Act_Rpt.At_Person_for_act(:p_at_id)) p
     where 1=1
       and s.ate_at = :p_at_id
       --секція з розділу "Анкета для визначення рейтингу соціальних потреб"
       and s.ate_nng = :C_ATE_NNG_ANK
       and p.atp_id = s.ate_atp
       and atp_app_tp in ('OS')
    ]';
        l_str :=
            REGEXP_REPLACE (l_str,
                            ':p_at_id',
                            p_at_id,
                            1,
                            0,
                            'i');
        l_str :=
            REGEXP_REPLACE (
                l_str,
                'null',
                CHR (39) || TO_CHAR (c.at_dt, 'dd.mm.yyyy') || CHR (39),
                1,
                0,
                'i');
        l_str := REPLACE (l_str, ':C_ATE_NNG_ANK', C_ATE_NNG_ANK);
        rdm$rtfl_univ.AddDataset ('ds', l_str);

        AddParam ('sgn1',
                  p2.atop_ln || ' ' || p2.atop_fn || ' ' || p2.atop_mn); --Особа, яка провела оцінювання
        AddParam ('sgn3', TO_CHAR (c.at_dt, 'dd.mm.yyyy'));

        --Таблиця 6 Анкета для визначення рейтингу соціальних потреб дитини з інвалідністю
        AddParam ('a1', p3.pib);                                      --дитина
        AddParam ('a2', p3.birth_dt_str);
        AddParam ('a3', p3.live_address);
        AddParam ('a4', TO_CHAR (c.at_dt, 'dd.mm.yyyy') /*Get_Ftr_Nt(p_at_id, p_nda => null)*/
                                                       );    --Дата опитування

        --Сфера «Житло/документи»
        AddFtrT6 ('t6.1.1', p1.atp_id, 7234);
        AddFtrT6_2 ('t6.1.2', p2.atop_id, 7234);
        AddFtrT6 ('t6.1.3', p3.atp_id, 7234);
        AddFtrT6 ('t6.2.1', p1.atp_id, 7235);
        AddFtrT6_2 ('t6.2.2', p2.atop_id, 7235);
        AddFtrT6 ('t6.2.3', p3.atp_id, 7235);
        AddFtrT6 ('t6.3.1', p1.atp_id, 7236);
        AddFtrT6_2 ('t6.3.2', p2.atop_id, 7236);
        AddFtrT6 ('t6.3.3', p3.atp_id, 7236);
        AddFtrT6 ('t6.4.1', p1.atp_id, 7237);
        AddFtrT6_2 ('t6.4.2', p2.atop_id, 7237);
        AddFtrT6 ('t6.4.3', p3.atp_id, 7237);
        AddFtrT6 ('t6.5.1', p1.atp_id, 7238);
        AddFtrT6_2 ('t6.5.2', p2.atop_id, 7238);
        AddFtrT6 ('t6.5.3', p3.atp_id, 7238);
        --Сфера «Навички самостійного проживання»
        AddFtrT6 ('t6.7.1', p1.atp_id, 7239);
        AddFtrT6_2 ('t6.7.2', p2.atop_id, 7239);
        AddFtrT6 ('t6.7.3', p3.atp_id, 7239);
        AddFtrT6 ('t6.8.1', p1.atp_id, 7240);
        AddFtrT6_2 ('t6.8.2', p2.atop_id, 7240);
        AddFtrT6 ('t6.8.3', p3.atp_id, 7240);
        AddFtrT6 ('t6.9.1', p1.atp_id, 7241);
        AddFtrT6_2 ('t6.9.2', p2.atop_id, 7241);
        AddFtrT6 ('t6.9.3', p3.atp_id, 7241);
        AddFtrT6 ('t6.10.1', p1.atp_id, 7242);
        AddFtrT6_2 ('t6.10.2', p2.atop_id, 7242);
        AddFtrT6 ('t6.10.3', p3.atp_id, 7242);
        AddFtrT6 ('t6.12.1', p1.atp_id, 7243);
        AddFtrT6_2 ('t6.12.2', p2.atop_id, 7243);
        AddFtrT6 ('t6.12.3', p3.atp_id, 7243);
        --Сфера «Здоров’я»
        AddFtrT6 ('t6.13.1', p1.atp_id, 7244);
        AddFtrT6_2 ('t6.13.2', p2.atop_id, 7244);
        AddFtrT6 ('t6.13.3', p3.atp_id, 7244);
        AddFtrT6 ('t6.14.1', p1.atp_id, 7245);
        AddFtrT6_2 ('t6.14.2', p2.atop_id, 7245);
        AddFtrT6 ('t6.14.3', p3.atp_id, 7245);
        AddFtrT6 ('t6.15.1', p1.atp_id, 7246);
        AddFtrT6_2 ('t6.15.2', p2.atop_id, 7246);
        AddFtrT6 ('t6.15.3', p3.atp_id, 7246);
        AddFtrT6 ('t6.16.1', p1.atp_id, 7247);
        AddFtrT6_2 ('t6.16.2', p2.atop_id, 7247);
        AddFtrT6 ('t6.16.3', p3.atp_id, 7247);
        AddFtrT6 ('t6.17.1', p1.atp_id, 7248);
        AddFtrT6_2 ('t6.17.2', p2.atop_id, 7248);
        AddFtrT6 ('t6.17.3', p3.atp_id, 7248);
        AddFtrT6 ('t6.18.1', p1.atp_id, 7249);
        AddFtrT6_2 ('t6.18.2', p2.atop_id, 7249);
        AddFtrT6 ('t6.18.3', p3.atp_id, 7249);
        --Соціальна сфера
        AddFtrT6 ('t6.19.1', p1.atp_id, 7250);
        AddFtrT6_2 ('t6.19.2', p2.atop_id, 7250);
        AddFtrT6 ('t6.19.3', p3.atp_id, 7250);
        AddFtrT6 ('t6.20.1', p1.atp_id, 7251);
        AddFtrT6_2 ('t6.20.2', p2.atop_id, 7251);
        AddFtrT6 ('t6.20.3', p3.atp_id, 7251);
        AddFtrT6 ('t6.21.1', p1.atp_id, 7252);
        AddFtrT6_2 ('t6.21.2', p2.atop_id, 7252);
        AddFtrT6 ('t6.21.3', p3.atp_id, 7252);
        AddFtrT6 ('t6.22.1', p1.atp_id, 7253);
        AddFtrT6_2 ('t6.22.2', p2.atop_id, 7253);
        AddFtrT6 ('t6.22.3', p3.atp_id, 7253);
        AddFtrT6 ('t6.23.1', p1.atp_id, 7254);
        AddFtrT6_2 ('t6.23.2', p2.atop_id, 7254);
        AddFtrT6 ('t6.23.3', p3.atp_id, 7254);
        AddFtrT6 ('t6.24.1', p1.atp_id, 7255);
        AddFtrT6_2 ('t6.24.2', p2.atop_id, 7255);
        AddFtrT6 ('t6.24.3', p3.atp_id, 7255);
        --Загальна сума балів за сферами
        AddParam (
            'itg1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 343).ate_indicator_value1); --Житло/документи
        AddParam (
            'itg2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 344).ate_indicator_value1); --Навички самостійного проживання
        AddParam (
            'itg3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 345).ate_indicator_value1); --Здоров’я
        AddParam (
            'itg4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 346).ate_indicator_value1); --Соціальна сфера

        ------------------------------------
        rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                         p_rpt_blob   => l_result);
        replace_ekr (l_result);

        RETURN l_result;
    END ACT_DOC_898_R1;

    --#94250 Акт проведення оцінки рівня безпеки дитини для послуги 012.0
    FUNCTION ACT_DOC_1000_R1 (p_at_id IN NUMBER)
        RETURN BLOB
    IS
        CURSOR c_at IS
            SELECT a.at_dt,
                   a.at_sc,
                   a.at_wu,
                   a.at_cu,
                   a.at_ap
              FROM act a
             WHERE a.at_id = p_at_id;

        c          c_at%ROWTYPE;

        l_str      VARCHAR2 (32000);

        p          Api$Act_Rpt.R_Person_for_act;                   --отримувач
        f          Api$Act_Rpt.R_Person_for_act;                        --мати
        f2         Api$Act_Rpt.R_Person_for_act;            --представник мати
        m          Api$Act_Rpt.R_Person_for_act;                      --батько
        m2         Api$Act_Rpt.R_Person_for_act;          --представник батька

        l_jbr_id   NUMBER;
        l_result   BLOB;
    BEGIN
        rdm$rtfl_univ.initreport (p_code     => 'ACT_DOC_1000_R1',
                                  p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);

        ------------------------------------
        OPEN c_at;

        FETCH c_at INTO c;

        CLOSE c_at;

        p :=
            get_AtPerson (p_at    => p_at_id,
                          p_atp   => get_AtPerson_id (p_at_id, 'OS'));


        --шукаємо по секції з заповненими даними осіб
        SELECT MAX (DECODE (s.ate_nng, 347, s.ate_atp)),
               MAX (DECODE (s.ate_nng, 348, s.ate_atp)),
               MAX (DECODE (s.ate_nng, 349, s.ate_atp)),
               MAX (DECODE (s.ate_nng, 350, s.ate_atp))
          INTO f.atp_id,
               f2.atp_id,
               m.atp_id,
               m2.atp_id
          FROM uss_esr.at_section s
         WHERE s.ate_at = p_at_id;

        f := get_AtPerson (p_at => p_at_id, p_atp => f.atp_id);
        f2 := get_AtPerson (p_at => p_at_id, p_atp => f2.atp_id);
        m := get_AtPerson (p_at => p_at_id, p_atp => m.atp_id);
        m2 := get_AtPerson (p_at => p_at_id, p_atp => m2.atp_id);

        AddParam ('1', p.pib);
        AddParam ('2', CASE p.sex WHEN 'F' THEN 'Ж' WHEN 'M' THEN 'Ч' END);
        AddParam ('3', p.birth_dt_str);
        --Статус uss_ndi.V_DDN_SS_ST_CHILD
        AddParam ('4-1', Get_Ftr_Chk2 (p_at_id, p_nda => 4672, p_chk => 'O'));
        AddParam ('4-2', Get_Ftr_Chk2 (p_at_id, p_nda => 4672, p_chk => 'D'));
        AddParam ('4-3', Get_Ftr_Chk2 (p_at_id, p_nda => 4672, p_chk => 'W'));
        --Свідоцтво про народження/ паспорт (номер, ким і коли виданий )
        AddParam ('5',
                  COALESCE (Get_Passport (c.at_ap, 1),
                            Get_Passport (c.at_ap, 2),
                            Get_Passport (c.at_ap, 3),
                            Get_Ftr_Nt (p_at_id, p_nda => 4673)));
        AddParam ('6', p.live_address);
        AddParam ('7', p.phone);
        AddParam ('8', p.fact_address);
        AddParam ('9', Get_Ftr_Nt (p_at_id, p_nda => 4674));
        --II. Дані про батьків дитини, інших законних представників
        AddParam ('t1.1', f.pib);                                       --мати
        AddParam ('t1.2', f.birth_dt_str);
        AddParam ('t1.3', f.work_place);
        AddParam ('t1.4', f.phone);
        AddParam ('t1.5', f.live_address);
        AddParam ('t1.7', f.fact_address);
        AddParam ('t1.1.2', f2.pib);                        --представник мати
        AddParam ('t1.2.2', f2.birth_dt_str);
        AddParam ('t1.3.2', f2.work_place);
        AddParam ('t1.4.2', f2.phone);
        AddParam ('t1.5.2', f2.live_address);
        AddParam ('t1.7.2', f2.fact_address);
        AddParam ('t1.1.3', m.pib);                                   --батько
        AddParam ('t1.2.3', m.birth_dt_str);
        AddParam ('t1.3.3', m.work_place);
        AddParam ('t1.4.3', m.phone);
        AddParam ('t1.5.3', m.live_address);
        AddParam ('t1.7.3', m.fact_address);
        AddParam ('t1.1.4', m2.pib);                      --представник батька
        AddParam ('t1.2.4', m2.birth_dt_str);
        AddParam ('t1.3.4', m2.work_place);
        AddParam ('t1.4.4', m2.phone);
        AddParam ('t1.5.4', m2.live_address);
        AddParam ('t1.7.4', m2.fact_address);
        --Дані про батьків або інших законних представників відсутні
        AddParam ('t1', Get_Ftr_Chk2 (p_at_id, p_nda => 5349));
        --Дані про осіб, які фактично здійснюють догляд за дитиною, родичів
        AddParam (
            '2.1',
               Get_Ftr_Nt (p_at_id, p_nda => 5350)
            || NVL2 (Get_Ftr_Nt (p_at_id, p_nda => 5351),
                     ' тел.' || Get_Ftr_Nt (p_at_id, p_nda => 5351)));
        AddParam (
            '2.2',
               Get_Ftr_Nt (p_at_id, p_nda => 5352)
            || NVL2 (Get_Ftr_Nt (p_at_id, p_nda => 5352),
                     ' тел.' || Get_Ftr_Nt (p_at_id, p_nda => 5352)));

        --III. Стан дитини на момент виявлення
        --1. Дитина повідомляє про небезпеку та просить допомоги
        AddParam ('3.1.1-1', Get_Ftr_Chk2 (p_at_id, p_nda => 4676));
        AddParam ('3.1.1-2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4676, p_chk => 'F'));
        --Джерела інформації
        AddParam ('3.1.2-1', Get_Ftr_Chk2 (p_at_id, p_nda => 4677));
        AddParam ('3.1.2-2', Get_Ftr_Chk2 (p_at_id, p_nda => 4678));
        AddParam ('3.1.2-3', Get_Ftr_Chk2 (p_at_id, p_nda => 4679));
        AddParam ('3.1.2-4', Get_Ftr_Chk2 (p_at_id, p_nda => 4680));
        AddParam ('3.1.3-1', Get_Ftr_Chk2 (p_at_id, p_nda => 4681));
        AddParam ('3.1.3-2', Get_Ftr_Nt (p_at_id, p_nda => 4681));
        AddParam ('3.1.4-1',
                  Api$Act_Rpt.get_AtSctChld (p_at_id, p_nng => 163));
        AddParam ('3.1.4-2',
                  Api$Act_Rpt.get_AtSctPrnt (p_at_id, p_nng => 163));
        AddParam ('3.1.5', Api$Act_Rpt.get_AtSctNt (p_at_id, p_nng => 163));
        --2. Наявні фізичні та поведінкові ознаки, що можуть свідчити про жорстоке поводження з дитиною uss_ndi.V_DDN_SS_TFN
        AddParam ('3.2.1-1',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4682, p_chk => 'T'));
        AddParam ('3.2.1-2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4682, p_chk => 'F'));
        AddParam ('3.2.1-3',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4682, p_chk => 'N'));

        AddParam ('3.2.2', Get_Ftr_Chk2 (p_at_id, p_nda => 4683));
        AddParam ('3.2.3', Get_Ftr_Chk2 (p_at_id, p_nda => 4684));
        AddParam ('3.2.4', Get_Ftr_Chk2 (p_at_id, p_nda => 4685));
        AddParam ('3.2.5', Get_Ftr_Chk2 (p_at_id, p_nda => 4686));
        AddParam ('3.2.6', Get_Ftr_Chk2 (p_at_id, p_nda => 4687));
        AddParam ('3.2.7', Get_Ftr_Chk2 (p_at_id, p_nda => 4688));
        AddParam ('3.2.8', Get_Ftr_Chk2 (p_at_id, p_nda => 4689));
        AddParam ('3.2.9', Get_Ftr_Chk2 (p_at_id, p_nda => 4690));
        AddParam ('3.2.10', Get_Ftr_Chk2 (p_at_id, p_nda => 4691));
        AddParam ('3.2.11-1', Get_Ftr_Chk2 (p_at_id, p_nda => 4692));
        AddParam ('3.2.11-2', Get_Ftr_Nt (p_at_id, p_nda => 4692));
        --Місце травми
        AddParam ('3.2.12', Get_Ftr_Chk2 (p_at_id, p_nda => 4693));
        AddParam ('3.2.13', Get_Ftr_Chk2 (p_at_id, p_nda => 4694));
        AddParam ('3.2.14', Get_Ftr_Chk2 (p_at_id, p_nda => 4695));
        AddParam ('3.2.15', Get_Ftr_Chk2 (p_at_id, p_nda => 4696));
        AddParam ('3.2.16', Get_Ftr_Chk2 (p_at_id, p_nda => 4697));
        AddParam ('3.2.17', Get_Ftr_Chk2 (p_at_id, p_nda => 4698));
        AddParam ('3.2.18', Get_Ftr_Chk2 (p_at_id, p_nda => 4699));
        AddParam ('3.2.19', Get_Ftr_Chk2 (p_at_id, p_nda => 4700));
        AddParam ('3.2.20', Get_Ftr_Chk2 (p_at_id, p_nda => 4701));
        AddParam ('3.2.21', Get_Ftr_Chk2 (p_at_id, p_nda => 4702));
        AddParam ('3.2.22', Get_Ftr_Chk2 (p_at_id, p_nda => 4703));
        AddParam ('3.2.23', Get_Ftr_Chk2 (p_at_id, p_nda => 4704));
        AddParam ('3.2.24', Get_Ftr_Chk2 (p_at_id, p_nda => 4705));
        AddParam ('3.2.25', Get_Ftr_Chk2 (p_at_id, p_nda => 4706));
        AddParam ('3.2.251', Get_Ftr_Chk2 (p_at_id, p_nda => 4707));
        AddParam ('3.2.26', Get_Ftr_Chk2 (p_at_id, p_nda => 4708));
        AddParam ('3.2.27', Get_Ftr_Chk2 (p_at_id, p_nda => 4709));
        AddParam ('3.2.28', Get_Ftr_Chk2 (p_at_id, p_nda => 4710));
        AddParam ('3.2.29', Get_Ftr_Chk2 (p_at_id, p_nda => 4711));
        AddParam ('3.2.30', Get_Ftr_Chk2 (p_at_id, p_nda => 4712));
        AddParam ('3.2.31', Get_Ftr_Chk2 (p_at_id, p_nda => 4713));
        AddParam ('3.2.32', Get_Ftr_Chk2 (p_at_id, p_nda => 4714));
        AddParam ('3.2.33-1', Get_Ftr_Chk2 (p_at_id, p_nda => 4715));
        AddParam ('3.2.33-2', Get_Ftr_Chk2 (p_at_id, p_nda => 4715));

        --3. Наявні факти, що можуть свідчити про те, що з дитиною вступали в статеві зносини uss_ndi.V_DDN_SS_TFN
        AddParam ('3.3.1-1',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4716, p_chk => 'T'));
        AddParam ('3.3.1-2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4716, p_chk => 'F'));
        AddParam ('3.3.1-3',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4716, p_chk => 'N'));

        AddParam ('3.3.2', Get_Ftr_Chk2 (p_at_id, p_nda => 4717));
        AddParam ('3.3.3', Get_Ftr_Chk2 (p_at_id, p_nda => 4718));
        AddParam ('3.3.4', Get_Ftr_Chk2 (p_at_id, p_nda => 4719));
        AddParam ('3.3.5', Get_Ftr_Chk2 (p_at_id, p_nda => 4720));
        AddParam ('3.3.6', Get_Ftr_Chk2 (p_at_id, p_nda => 4721));
        AddParam ('3.3.7', Get_Ftr_Chk2 (p_at_id, p_nda => 4722));
        --Джерела інформації
        AddParam ('3.3.8', Get_Ftr_Chk2 (p_at_id, p_nda => 4723));
        AddParam ('3.3.9', Get_Ftr_Chk2 (p_at_id, p_nda => 4724));
        AddParam ('3.3.10', Get_Ftr_Chk2 (p_at_id, p_nda => 4725));
        AddParam ('3.3.11', Get_Ftr_Chk2 (p_at_id, p_nda => 4726));
        AddParam ('3.3.12-1', Get_Ftr_Chk2 (p_at_id, p_nda => 4727));
        AddParam ('3.3.12-2', Get_Ftr_Nt (p_at_id, p_nda => 4727));
        AddParam ('3.3.13-1',
                  Api$Act_Rpt.get_AtSctChld (p_at_id, p_nng => 244));
        AddParam ('3.3.13-2',
                  Api$Act_Rpt.get_AtSctPrnt (p_at_id, p_nng => 244));
        AddParam ('3.3.14', Api$Act_Rpt.get_AtSctNt (p_at_id, p_nng => 244));

        --4. Наявні ознаки погіршення стану здоров’я на момент виявлення дитини uss_ndi.V_DDN_SS_TFN
        AddParam ('3.4.1-1',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4728, p_chk => 'T'));
        AddParam ('3.4.1-2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4728, p_chk => 'F'));
        AddParam ('3.4.1-3',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4728, p_chk => 'N'));

        AddParam ('3.4.2', Get_Ftr_Chk2 (p_at_id, p_nda => 4729));
        AddParam ('3.4.3', Get_Ftr_Chk2 (p_at_id, p_nda => 4730));
        AddParam ('3.4.4', Get_Ftr_Chk2 (p_at_id, p_nda => 4731));
        AddParam ('3.4.5', Get_Ftr_Chk2 (p_at_id, p_nda => 4732));
        AddParam ('3.4.6', Get_Ftr_Chk2 (p_at_id, p_nda => 4733));
        AddParam ('3.4.7', Get_Ftr_Chk2 (p_at_id, p_nda => 4734));
        AddParam ('3.4.8', Get_Ftr_Chk2 (p_at_id, p_nda => 4735));
        AddParam ('3.4.9-1', Get_Ftr_Chk2 (p_at_id, p_nda => 4736));
        AddParam ('3.4.9-2', Get_Ftr_Nt (p_at_id, p_nda => 4736));
        --Джерела інформації
        AddParam ('3.4.10', Get_Ftr_Chk2 (p_at_id, p_nda => 4737));
        AddParam ('3.4.11', Get_Ftr_Chk2 (p_at_id, p_nda => 4738));
        AddParam ('3.4.12', Get_Ftr_Chk2 (p_at_id, p_nda => 4739));
        AddParam ('3.4.13', Get_Ftr_Chk2 (p_at_id, p_nda => 4740));
        AddParam ('3.4.14', Get_Ftr_Chk2 (p_at_id, p_nda => 4741));
        AddParam ('3.4.15-1', Get_Ftr_Chk2 (p_at_id, p_nda => 4742));   --інше
        AddParam ('3.4.15-2', Get_Ftr_Nt (p_at_id, p_nda => 4742));
        AddParam ('3.4.16-1',
                  Api$Act_Rpt.get_AtSctChld (p_at_id, p_nng => 245)); --Розповідь дитини
        AddParam ('3.4.16-2',
                  Api$Act_Rpt.get_AtSctPrnt (p_at_id, p_nng => 245));
        AddParam ('3.4.17', Api$Act_Rpt.get_AtSctNt (p_at_id, p_nng => 245));

        --5. Дитина має зовнішні ознаки недогляду чи  занедбаності
        AddParam ('3.5.1-1', Get_Ftr_Chk2 (p_at_id, p_nda => 4743));
        AddParam ('3.5.1-2', Get_Ftr_Chk2 (p_at_id, p_nda => 4743));

        AddParam ('3.5.2', Get_Ftr_Chk2 (p_at_id, p_nda => 4744));
        --підкеслення з галочкой
        l_str :=
               Api$Act_Rpt.Underline (
                   'не ходить',
                   Api$Act_Rpt.Get_Ftr (p_at_id, p_nda => 4745) = 'T')
            || '/'
            || Api$Act_Rpt.Underline (
                   'не сидить',
                   Api$Act_Rpt.Get_Ftr (p_at_id, p_nda => 4746) = 'T')
            || '/'
            || Api$Act_Rpt.Underline (
                   'не розмовляє',
                   Api$Act_Rpt.Get_Ftr (p_at_id, p_nda => 4747) = 'T');
        AddParam (
            '3.5.3',
            Api$Act_Rpt.chk_val2 (
                CASE
                    WHEN    Api$Act_Rpt.Get_Ftr (p_at_id, p_nda => 4745)
                         || Api$Act_Rpt.Get_Ftr (p_at_id, p_nda => 4746)
                         || Api$Act_Rpt.Get_Ftr (p_at_id, p_nda => 4747) LIKE
                             '%T%'
                    THEN
                        'T'
                END,
                'T'));
        AddParam ('3.5.3-1', l_str);

        AddParam ('3.5.4', Get_Ftr_Chk2 (p_at_id, p_nda => 4748));
        AddParam ('3.5.5', Get_Ftr_Chk2 (p_at_id, p_nda => 4749));
        AddParam ('3.5.6', Get_Ftr_Chk2 (p_at_id, p_nda => 4750));
        AddParam ('3.5.7', Get_Ftr_Chk2 (p_at_id, p_nda => 4751));
        AddParam ('3.5.8', Get_Ftr_Chk2 (p_at_id, p_nda => 4752));
        AddParam ('3.5.9-1', Get_Ftr_Chk2 (p_at_id, p_nda => 4753));    --інше
        AddParam ('3.5.9-2', Get_Ftr_Chk2 (p_at_id, p_nda => 4753));
        --Джерела інформації
        AddParam ('3.5.10', Get_Ftr_Chk2 (p_at_id, p_nda => 4754));
        AddParam ('3.5.11', Get_Ftr_Chk2 (p_at_id, p_nda => 4755));
        AddParam ('3.5.12', Get_Ftr_Chk2 (p_at_id, p_nda => 4756));
        AddParam ('3.5.13', Get_Ftr_Chk2 (p_at_id, p_nda => 4757));
        AddParam ('3.5.14', Get_Ftr_Chk2 (p_at_id, p_nda => 4758));
        AddParam ('3.5.15-1', Get_Ftr_Chk2 (p_at_id, p_nda => 4759));   --інше
        AddParam ('3.5.15-2', Get_Ftr_Nt (p_at_id, p_nda => 4759));
        AddParam ('3.5.16-1',
                  Api$Act_Rpt.get_AtSctChld (p_at_id, p_nng => 246)); --Розповідь дитини
        AddParam ('3.5.16-2',
                  Api$Act_Rpt.get_AtSctPrnt (p_at_id, p_nng => 246));
        AddParam ('3.5.17', Api$Act_Rpt.get_AtSctNt (p_at_id, p_nng => 246));

        --6. Наявні факти залучення дитини до протиправної діяльності uss_ndi.V_DDN_SS_TFN
        AddParam ('3.6.1-1',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4760, p_chk => 'T'));
        AddParam ('3.6.1-2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4760, p_chk => 'F'));
        AddParam ('3.6.1-3',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4760, p_chk => 'N'));

        AddParam ('3.6.2', Get_Ftr_Chk2 (p_at_id, p_nda => 4761));
        AddParam ('3.6.2-1', Get_Ftr_Nt (p_at_id, p_nda => 4761));
        AddParam ('3.6.3', Get_Ftr_Chk2 (p_at_id, p_nda => 4762));
        AddParam ('3.6.4', Get_Ftr_Chk2 (p_at_id, p_nda => 4763));
        AddParam ('3.6.5', Get_Ftr_Chk2 (p_at_id, p_nda => 4764));
        AddParam ('3.6.6', Get_Ftr_Chk2 (p_at_id, p_nda => 4765));
        AddParam ('3.6.7', Get_Ftr_Chk2 (p_at_id, p_nda => 4766));
        AddParam ('3.6.7-1', Get_Ftr_Nt (p_at_id, p_nda => 4766));
        AddParam ('3.6.8', Get_Ftr_Chk2 (p_at_id, p_nda => 4767));
        --робота, яка за характером чи умовами виконання може заподіяти шкоду фізичному або психічному здоров’ю дитини uss_ndi.V_DDN_SS_TFN
        AddParam ('3.6.9', Get_Ftr_Chk2 (p_at_id, p_nda => 4768, p_chk => 'T')); --якщо позначка ТАК
        AddParam ('3.6.9-1',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4768, p_chk => 'T'));  --так
        AddParam ('3.6.9-2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4768, p_chk => 'F'));   --ні
        AddParam ('3.6.9-3',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4768, p_chk => 'N')); --неможливо визначити
        --використання або втягнення у жебрацтво uss_ndi.V_DDN_SS_TFN
        AddParam ('3.6.10',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4769, p_chk => 'T')); --якщо позначка ТАК
        AddParam ('3.6.10-1',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4768, p_chk => 'T'));  --так
        AddParam ('3.6.10-2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4768, p_chk => 'F'));   --ні
        AddParam ('3.6.10-3',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4768, p_chk => 'N')); --неможливо визначити
        --втягнення у злочинну діяльність uss_ndi.V_DDN_SS_TFN
        AddParam ('3.6.11',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5354, p_chk => 'T')); --якщо позначка ТАК
        AddParam ('3.6.11-1',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5354, p_chk => 'T'));  --так
        AddParam ('3.6.11-2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5354, p_chk => 'F'));   --ні
        AddParam ('3.6.11-3',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5354, p_chk => 'N')); --неможливо визначити
        --інше
        AddParam ('3.6.12', Get_Ftr_Chk2 (p_at_id, p_nda => 4770));
        AddParam ('3.6.12-1', Get_Ftr_Nt (p_at_id, p_nda => 4770));
        --Джерела інформації
        AddParam ('3.6.13', Get_Ftr_Chk2 (p_at_id, p_nda => 4771));
        AddParam ('3.6.14', Get_Ftr_Chk2 (p_at_id, p_nda => 4772));
        AddParam ('3.6.15', Get_Ftr_Chk2 (p_at_id, p_nda => 4773));
        AddParam ('3.6.16', Get_Ftr_Chk2 (p_at_id, p_nda => 4774));
        AddParam ('3.6.17', Get_Ftr_Chk2 (p_at_id, p_nda => 4775));
        AddParam ('3.6.18-1', Get_Ftr_Chk2 (p_at_id, p_nda => 4776));   --інше
        AddParam ('3.6.18-2', Get_Ftr_Nt (p_at_id, p_nda => 4776));
        AddParam ('3.6.19-1',
                  Api$Act_Rpt.get_AtSctChld (p_at_id, p_nng => 247)); --Розповідь дитини
        AddParam ('3.6.19-2',
                  Api$Act_Rpt.get_AtSctPrnt (p_at_id, p_nng => 247));
        AddParam ('3.6.20', Api$Act_Rpt.get_AtSctNt (p_at_id, p_nng => 247));

        --7. Дитина стала очевидцем злочину uss_ndi.V_DDN_SS_TFN
        AddParam ('3.7.1-1',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4777, p_chk => 'T'));  --так
        AddParam ('3.7.1-2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4777, p_chk => 'F'));   --ні
        AddParam ('3.7.1-3',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4777, p_chk => 'N')); --неможливо визначити
        --Джерела інформації
        AddParam ('3.7.13', Get_Ftr_Chk2 (p_at_id, p_nda => 4778));
        AddParam ('3.7.14', Get_Ftr_Chk2 (p_at_id, p_nda => 4779));
        AddParam ('3.7.15', Get_Ftr_Chk2 (p_at_id, p_nda => 4780));
        AddParam ('3.7.16', Get_Ftr_Chk2 (p_at_id, p_nda => 4781));
        AddParam ('3.7.17', Get_Ftr_Chk2 (p_at_id, p_nda => 4782));
        AddParam ('3.7.18-1', Get_Ftr_Chk2 (p_at_id, p_nda => 4783));   --інше
        AddParam ('3.7.18-2', Get_Ftr_Nt (p_at_id, p_nda => 4783));
        AddParam ('3.7.19-1',
                  Api$Act_Rpt.get_AtSctChld (p_at_id, p_nng => 248)); --Розповідь дитини
        AddParam ('3.7.19-2',
                  Api$Act_Rpt.get_AtSctPrnt (p_at_id, p_nng => 248));
        AddParam ('3.7.20', Api$Act_Rpt.get_AtSctNt (p_at_id, p_nng => 248));
        --8. Інша важлива інформація
        AddParam ('3.8', Get_Ftr_Nt (p_at_id, p_nda => 4784));

        --IV. Факти, що свідчать про нездатність батьків, гарантувати безпеку дитині (дітям)
        AddParam ('4.1.1-1', Get_Ftr_Chk2 (p_at_id, p_nda => 4785));
        AddParam ('4.1.1-2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4785, p_chk => 'F'));
        AddParam ('4.1.2', Api$Act_Rpt.get_AtSctNt (p_at_id, p_nng => 250));

        AddParam ('4.2.1-1', Get_Ftr_Chk2 (p_at_id, p_nda => 4786));
        AddParam ('4.2.1-2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4786, p_chk => 'F'));

        --Тривалість перебування дитини без нагляду uss_ndi.V_DDN_SS_UNSUPERVISED
        AddParam ('4.2.2-1',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4787, p_chk => 'H'));
        AddParam ('4.2.2-2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4787, p_chk => 'MH'));
        AddParam ('4.2.2-3',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4787, p_chk => 'D'));
        AddParam ('4.2.2-4',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4787, p_chk => 'MD'));
        AddParam ('4.2.2-5',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4787, p_chk => 'N'));
        --Місце перебування дитини на момент виявлення uss_ndi.V_DDN_SS_LOC_CHLD
        AddParam ('4.2.3-1',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4788, p_chk => 'R'));
        AddParam ('4.2.3-2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4788, p_chk => 'PP'));
        AddParam ('4.2.3-3',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4788, p_chk => 'S'));
        AddParam ('4.2.3-4',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4788, p_chk => 'AN'));
        --Джерела інформації
        AddParam ('4.2.4', Get_Ftr_Chk2 (p_at_id, p_nda => 4789));
        AddParam ('4.2.5', Get_Ftr_Chk2 (p_at_id, p_nda => 4790));
        AddParam ('4.2.6', Get_Ftr_Chk2 (p_at_id, p_nda => 4791));
        AddParam ('4.2.7', Get_Ftr_Chk2 (p_at_id, p_nda => 4792));
        AddParam ('4.2.8', Get_Ftr_Chk2 (p_at_id, p_nda => 4793));
        AddParam ('4.2.9-1', Get_Ftr_Chk2 (p_at_id, p_nda => 4794));    --інше
        AddParam ('4.2.9-2', Get_Ftr_Nt (p_at_id, p_nda => 4794));
        AddParam ('4.2.10-1',
                  Api$Act_Rpt.get_AtSctChld (p_at_id, p_nng => 251)); --Розповідь дитини
        AddParam ('4.2.10-2',
                  Api$Act_Rpt.get_AtSctPrnt (p_at_id, p_nng => 251));
        AddParam ('4.2.11', Api$Act_Rpt.get_AtSctNt (p_at_id, p_nng => 251));
        --3. Дитина залишена під наглядом осіб з наявними ознаками алкогольного чи наркотичного сп’яніння
        AddParam ('4.3.1-1', Get_Ftr_Chk2 (p_at_id, p_nda => 4795));     --так
        AddParam ('4.3.1-2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4795, p_chk => 'F'));   --ні
        --Тривалість перебування дитини під наглядом зазначених осіб uss_ndi.V_DDN_SS_UNSUPERVISED
        AddParam ('4.3.2-1',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4796, p_chk => 'H'));
        AddParam ('4.3.2-2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4796, p_chk => 'MH'));
        AddParam ('4.3.2-3',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4796, p_chk => 'D'));
        AddParam ('4.3.2-4',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4796, p_chk => 'MD'));
        AddParam ('4.3.2-5',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4796, p_chk => 'N'));
        --Місце перебування дитини на момент виявлення uss_ndi.V_DDN_SS_LOC_CHLD1
        AddParam ('4.3.3-1',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4797, p_chk => 'RC'));
        AddParam ('4.3.3-2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4797, p_chk => 'RO'));
        AddParam ('4.3.3-3',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4797, p_chk => 'PP'));
        AddParam ('4.3.3-4',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4797, p_chk => 'S'));
        AddParam ('4.3.3-5',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4797, p_chk => 'AN'));
        --Джерела інформації
        AddParam ('4.3.4', Get_Ftr_Chk2 (p_at_id, p_nda => 4798));
        AddParam ('4.3.5', Get_Ftr_Chk2 (p_at_id, p_nda => 4799));
        AddParam ('4.3.6', Get_Ftr_Chk2 (p_at_id, p_nda => 4800));
        AddParam ('4.3.7', Get_Ftr_Chk2 (p_at_id, p_nda => 4801));
        AddParam ('4.3.8', Get_Ftr_Chk2 (p_at_id, p_nda => 4802));
        AddParam ('4.3.9-1', Get_Ftr_Chk2 (p_at_id, p_nda => 4803));    --інше
        AddParam ('4.3.9-2', Get_Ftr_Nt (p_at_id, p_nda => 4803));
        AddParam ('4.3.10-1',
                  Api$Act_Rpt.get_AtSctChld (p_at_id, p_nng => 252)); --Розповідь дитини
        AddParam ('4.3.10-2',
                  Api$Act_Rpt.get_AtSctPrnt (p_at_id, p_nng => 252));
        AddParam ('4.3.11', Api$Act_Rpt.get_AtSctNt (p_at_id, p_nng => 252));

        --4. Наявність небезпечної поведінки або ознак психічних та поведінкових розладів uss_ndi.V_DDN_SS_TFN
        AddParam ('4.4.3-1',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4804, p_chk => 'T'));  --так
        AddParam ('4.4.3-2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4804, p_chk => 'F'));   --ні
        AddParam ('4.4.3-3',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4804, p_chk => 'N')); --неможливо визначити

        AddParam ('4.4.1', Get_Ftr_Chk2 (p_at_id, p_nda => 4805));
        AddParam ('4.4.2', Get_Ftr_Chk2 (p_at_id, p_nda => 4806));
        --Спостерігаються:
        AddParam ('4.4.4', Get_Ftr_Chk2 (p_at_id, p_nda => 4807));
        AddParam ('4.4.5', Get_Ftr_Chk2 (p_at_id, p_nda => 4808));
        AddParam ('4.4.6', Get_Ftr_Chk2 (p_at_id, p_nda => 4809));
        AddParam ('4.4.7', Get_Ftr_Chk2 (p_at_id, p_nda => 4810));
        AddParam ('4.4.8-1', Get_Ftr_Chk2 (p_at_id, p_nda => 4811));
        AddParam ('4.4.8-2', Get_Ftr_Nt (p_at_id, p_nda => 4811));
        --Джерела інформації
        AddParam ('4.4.9', Get_Ftr_Chk2 (p_at_id, p_nda => 4812));
        AddParam ('4.4.10', Get_Ftr_Chk2 (p_at_id, p_nda => 4813));
        AddParam ('4.4.11', Get_Ftr_Chk2 (p_at_id, p_nda => 4814));
        AddParam ('4.4.12', Get_Ftr_Chk2 (p_at_id, p_nda => 4815));
        AddParam ('4.4.13', Get_Ftr_Chk2 (p_at_id, p_nda => 4816));
        AddParam ('4.4.14-1', Get_Ftr_Chk2 (p_at_id, p_nda => 4817));   --інше
        AddParam ('4.4.14-2', Get_Ftr_Nt (p_at_id, p_nda => 4817));
        AddParam ('4.4.15-1',
                  Api$Act_Rpt.get_AtSctChld (p_at_id, p_nng => 253)); --Розповідь дитини
        AddParam ('4.4.15-2',
                  Api$Act_Rpt.get_AtSctPrnt (p_at_id, p_nng => 253));
        AddParam ('4.4.16', Api$Act_Rpt.get_AtSctNt (p_at_id, p_nng => 253));

        --5. Батьки, інші законні представники, особи, які фактично здійснюють догляд за дитиною, перебувають у невідкладному стані uss_ndi.V_DDN_SS_TFN
        AddParam ('4.5.1-1',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4818, p_chk => 'T'));  --так
        AddParam ('4.5.1-2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4818, p_chk => 'F'));   --ні
        AddParam ('4.5.1-3',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4818, p_chk => 'N')); --неможливо визначити

        AddParam ('4.5.2', Get_Ftr_Chk2 (p_at_id, p_nda => 4819));
        AddParam ('4.5.3', Get_Ftr_Chk2 (p_at_id, p_nda => 4820));
        AddParam ('4.5.4', Get_Ftr_Chk2 (p_at_id, p_nda => 4821));
        AddParam ('4.5.5', Get_Ftr_Chk2 (p_at_id, p_nda => 4822));
        --Джерела інформації
        AddParam ('4.5.6', Get_Ftr_Chk2 (p_at_id, p_nda => 4823));
        AddParam ('4.5.7', Get_Ftr_Chk2 (p_at_id, p_nda => 4824));
        AddParam ('4.5.8', Get_Ftr_Chk2 (p_at_id, p_nda => 4825));
        AddParam ('4.5.9', Get_Ftr_Chk2 (p_at_id, p_nda => 4826));
        AddParam ('4.5.10', Get_Ftr_Chk2 (p_at_id, p_nda => 4827));
        AddParam ('4.5.11-1', Get_Ftr_Chk2 (p_at_id, p_nda => 4828));   --інше
        AddParam ('4.5.11-2', Get_Ftr_Nt (p_at_id, p_nda => 4828));
        AddParam ('4.5.12-1',
                  Api$Act_Rpt.get_AtSctChld (p_at_id, p_nng => 254)); --Розповідь дитини
        AddParam ('4.5.12-2',
                  Api$Act_Rpt.get_AtSctPrnt (p_at_id, p_nng => 254));
        AddParam ('4.5.13', Api$Act_Rpt.get_AtSctNt (p_at_id, p_nng => 254));
        --6. Інша важлива інформація
        AddParam ('4.6', Get_Ftr_Nt (p_at_id, p_nda => 4829));

        --V. Інші факти, що свідчать про небезпеку для дитини uss_ndi.V_DDN_SS_TFN
        AddParam ('5.1.1-1',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4830, p_chk => 'T'));  --так
        AddParam ('5.1.1-2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4830, p_chk => 'F'));   --ні
        AddParam ('5.1.1-3',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4830, p_chk => 'N')); --неможливо визначити

        AddParam ('5.1.2', Get_Ftr_Chk2 (p_at_id, p_nda => 4831));
        AddParam ('5.1.3', Get_Ftr_Chk2 (p_at_id, p_nda => 4832));
        AddParam ('5.1.4', Get_Ftr_Chk2 (p_at_id, p_nda => 4833));
        --Джерела інформації
        AddParam ('5.1.5', Get_Ftr_Chk2 (p_at_id, p_nda => 4834));
        AddParam ('5.1.6', Get_Ftr_Chk2 (p_at_id, p_nda => 4835));
        AddParam ('5.1.7', Get_Ftr_Chk2 (p_at_id, p_nda => 4836));
        AddParam ('5.1.8', Get_Ftr_Chk2 (p_at_id, p_nda => 4837));
        AddParam ('5.1.9', Get_Ftr_Chk2 (p_at_id, p_nda => 4838));
        AddParam ('5.1.10-1', Get_Ftr_Chk2 (p_at_id, p_nda => 4839));   --інше
        AddParam ('5.1.10-2', Get_Ftr_Nt (p_at_id, p_nda => 4839));
        AddParam ('5.1.11-1',
                  Api$Act_Rpt.get_AtSctChld (p_at_id, p_nng => 256)); --Розповідь дитини
        AddParam ('5.1.11-2',
                  Api$Act_Rpt.get_AtSctPrnt (p_at_id, p_nng => 256));
        AddParam ('5.1.12', Api$Act_Rpt.get_AtSctNt (p_at_id, p_nng => 256));

        --2. Наявні ознаки незабезпечення дитини: uss_ndi.V_DDN_SS_TFN
        AddParam ('5.2.1-1',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4840, p_chk => 'T'));  --так
        AddParam ('5.2.1-2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4840, p_chk => 'F'));   --ні
        AddParam ('5.2.1-3',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4840, p_chk => 'N')); --неможливо визначити

        AddParam ('5.2.2', Get_Ftr_Chk2 (p_at_id, p_nda => 4841));
        AddParam ('5.2.3', Get_Ftr_Chk2 (p_at_id, p_nda => 4842));
        AddParam ('5.2.4', Get_Ftr_Chk2 (p_at_id, p_nda => 4843));
        --Джерела інформації
        AddParam ('5.2.5', Get_Ftr_Chk2 (p_at_id, p_nda => 4844));
        AddParam ('5.2.6', Get_Ftr_Chk2 (p_at_id, p_nda => 4845));
        AddParam ('5.2.7', Get_Ftr_Chk2 (p_at_id, p_nda => 4846));
        AddParam ('5.2.8', Get_Ftr_Chk2 (p_at_id, p_nda => 4847));
        AddParam ('5.2.9', Get_Ftr_Chk2 (p_at_id, p_nda => 4848));
        AddParam ('5.2.10-1', Get_Ftr_Chk2 (p_at_id, p_nda => 4849));   --інше
        AddParam ('5.2.10-2', Get_Ftr_Nt (p_at_id, p_nda => 4849));
        AddParam ('5.2.11-1',
                  Api$Act_Rpt.get_AtSctChld (p_at_id, p_nng => 257)); --Розповідь дитини
        AddParam ('5.2.11-2',
                  Api$Act_Rpt.get_AtSctPrnt (p_at_id, p_nng => 257));
        AddParam ('5.2.12', Api$Act_Rpt.get_AtSctNt (p_at_id, p_nng => 257));

        --3. Помешкання, в якому проживає дитина, не пристосоване для її проживання: uss_ndi.V_DDN_SS_TFN
        AddParam ('5.3.1-1',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4850, p_chk => 'T'));  --так
        AddParam ('5.3.1-2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4850, p_chk => 'F'));   --ні
        AddParam ('5.3.1-3',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4850, p_chk => 'N')); --неможливо визначити

        AddParam ('5.3.2', Get_Ftr_Chk2 (p_at_id, p_nda => 4851));
        AddParam ('5.3.3', Get_Ftr_Chk2 (p_at_id, p_nda => 4852));
        AddParam ('5.3.4', Get_Ftr_Chk2 (p_at_id, p_nda => 4853));
        AddParam ('5.3.5', Get_Ftr_Chk2 (p_at_id, p_nda => 4854));
        AddParam ('5.3.6', Get_Ftr_Chk2 (p_at_id, p_nda => 4855));
        AddParam ('5.3.7', Get_Ftr_Chk2 (p_at_id, p_nda => 4856));
        AddParam ('5.3.8', Get_Ftr_Chk2 (p_at_id, p_nda => 4857));
        AddParam ('5.3.9', Get_Ftr_Chk2 (p_at_id, p_nda => 4858));
        AddParam ('5.3.10', Get_Ftr_Chk2 (p_at_id, p_nda => 4859));
        AddParam ('5.3.11', Get_Ftr_Chk2 (p_at_id, p_nda => 4860));
        AddParam ('5.3.12-1', Get_Ftr_Chk2 (p_at_id, p_nda => 4861));
        AddParam ('5.3.12-2', Get_Ftr_Nt (p_at_id, p_nda => 4861));
        --Джерела інформації
        AddParam ('5.3.13', Get_Ftr_Chk2 (p_at_id, p_nda => 4862));
        AddParam ('5.3.14', Get_Ftr_Chk2 (p_at_id, p_nda => 4863));
        AddParam ('5.3.15', Get_Ftr_Chk2 (p_at_id, p_nda => 4864));
        AddParam ('5.3.16', Get_Ftr_Chk2 (p_at_id, p_nda => 4865));
        AddParam ('5.3.17', Get_Ftr_Chk2 (p_at_id, p_nda => 4866));
        AddParam ('5.3.18-1', Get_Ftr_Chk2 (p_at_id, p_nda => 4867));   --інше
        AddParam ('5.3.18-2', Get_Ftr_Nt (p_at_id, p_nda => 4867));
        AddParam ('5.3.19-1',
                  Api$Act_Rpt.get_AtSctChld (p_at_id, p_nng => 258)); --Розповідь дитини
        AddParam ('5.3.19-2',
                  Api$Act_Rpt.get_AtSctPrnt (p_at_id, p_nng => 258));
        AddParam ('5.3.20', Api$Act_Rpt.get_AtSctNt (p_at_id, p_nng => 258));

        --4. Дитину виявлено внаслідок:
        AddParam ('5.4.1-1', Get_Ftr_Chk2 (p_at_id, p_nda => 4868));     --так
        AddParam ('5.4.1-2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4868, p_chk => 'F'));   --ні

        AddParam ('5.4.2', Get_Ftr_Chk2 (p_at_id, p_nda => 4869));
        AddParam ('5.4.3', Get_Ftr_Chk2 (p_at_id, p_nda => 4870));
        AddParam ('5.4.4', Get_Ftr_Chk2 (p_at_id, p_nda => 4871));
        AddParam ('5.4.5', Get_Ftr_Chk2 (p_at_id, p_nda => 4872));
        AddParam ('5.4.6', Get_Ftr_Chk2 (p_at_id, p_nda => 4873));
        --Джерела інформації
        AddParam ('5.4.7', Get_Ftr_Chk2 (p_at_id, p_nda => 4874));
        AddParam ('5.4.8', Get_Ftr_Chk2 (p_at_id, p_nda => 4875));
        AddParam ('5.4.9', Get_Ftr_Chk2 (p_at_id, p_nda => 4876));
        AddParam ('5.4.10', Get_Ftr_Chk2 (p_at_id, p_nda => 4877));
        AddParam ('5.4.11', Get_Ftr_Chk2 (p_at_id, p_nda => 4878));
        AddParam ('5.4.12-1', Get_Ftr_Chk2 (p_at_id, p_nda => 4879));   --інше
        AddParam ('5.4.12-2', Get_Ftr_Nt (p_at_id, p_nda => 4879));
        AddParam ('5.4.13-1',
                  Api$Act_Rpt.get_AtSctChld (p_at_id, p_nng => 259)); --Розповідь дитини
        AddParam ('5.4.13-2',
                  Api$Act_Rpt.get_AtSctPrnt (p_at_id, p_nng => 259));
        AddParam ('5.4.14', Api$Act_Rpt.get_AtSctNt (p_at_id, p_nng => 259));
        --5. Інша важлива інформація:
        AddParam ('5.5', Get_Ftr_Nt (p_at_id, p_nda => 4880));

        --VI. Результати проведення оцінки рівня безпеки дитини
        --1. Висновок щодо рівня безпеки дитини  uss_ndi.V_DDN_SS_CHLD_SF_LV
        AddParam ('6.1-1',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4881, p_chk => 'VD')); --дуже небезпечно
        AddParam ('6.1-2', Get_Ftr_Chk2 (p_at_id, p_nda => 4881, p_chk => 'D')); --небезпечно
        AddParam ('6.1-3',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 4881, p_chk => 'ND')); --ознаки  небезпеки відсутні
        AddParam ('6.1-4', Get_Ftr_Chk2 (p_at_id, p_nda => 4881, p_chk => 'S')); --безпечно

        --2. Інформація про вжиті негайні заходи для безпеки та захисту дитини
        l_str :=
            q'[
     select
           row_number() over(order by nsa.nsa_order) as c1,
           nsa.nsa_name as c2,
           to_char(atr.atr_dt, 'dd.mm.yyyy hh24:mi') as c3,
           (select listagg(s.atop_ln||' '||s.atop_fn||' '||s.atop_mn) within group(order by s.atop_ln)
              from uss_esr.at_other_spec s where s.atop_at = atr.atr_at and s.history_status = 'A'
               and s.atop_atr = atr.atr_id
           )            as c4,
           atr.atr_result as c5
      from uss_esr.at_results atr, uss_ndi.v_ndi_nst_activities nsa
     where 1=1
       and atr.atr_at = :p_at_id
       and nsa.nsa_id = atr.atr_nsa
     order by c1
    ]';
        l_str :=
            REGEXP_REPLACE (l_str,
                            ':p_at_id',
                            p_at_id,
                            1,
                            0,
                            'i');
        rdm$rtfl_univ.AddDataset ('ds2', l_str);

        --3. Інформація про роботу, яку необхідно провести
        AddParam ('6.3.1', Get_Ftr_Nt (p_at_id, p_nda => 4882));

        --Відмітка про ознайомлення батьків, інших законних представників
        AddParam ('sgn1', '______________________________');
        AddParam ('sgn2', '______________________________');
        AddParam ('sgn_mark_1', '________________');
        AddParam ('sgn_mark_2', '________________');

        FOR c
            IN (  SELECT ROW_NUMBER ()
                             OVER (
                                 ORDER BY
                                     CASE
                                         WHEN atp.atp_id IN (f.atp_id, m.atp_id)
                                         THEN
                                             1
                                         ELSE
                                             2
                                     END)
                             rn,                        --батькі йдуть першими
                         atp.atp_ln || ' ' || atp.atp_fn || ' ' || atp.atp_mn
                             pib,
                         atp.*
                    FROM at_person atp
                   WHERE     atp.atp_at = p_at_id
                         AND atp.history_status = 'A'
                         AND atp.atp_id IN (f.atp_id,
                                            f2.atp_id,
                                            m.atp_id,
                                            m2.atp_id)
                ORDER BY rn)
        LOOP
            EXIT WHEN c.rn > 2;
            AddParam ('sgn' || c.rn, Api$Act_Rpt.GetPIB (c.pib));
            AddParam (
                'sgn_mark_' || c.rn,
                api$act_rpt.get_sign_mark (p_at_id,
                                           c.atp_id,
                                           '________________'));
        END LOOP;

        --Коментарі батьків або інших законних представників
        AddParam ('6.3.2', Api$Act_Rpt.get_AtSctPrnt (p_at_id, p_nng => 261));
        AddParam ('6.3.3', Api$Act_Rpt.get_AtSctNt (p_at_id, p_nng => 261));
        AddParam ('6.3.4', TO_CHAR (c.at_dt, 'dd.mm.yyyy')); --Get_Ftr_Nt(p_at_id, p_nda => null)); --дата оцінки

        --Оцінку рівня безпеки дитини проведено #6.3.4# р. комісією у складі:
        l_str :=
            q'[
    select row_number() over(order by decode(s.atop_tp, 'MC', 1, 2), s.atop_ln)||'. '||
             uss_esr.Api$Act_Rpt.GetPIB(s.atop_ln||' '||s.atop_fn||' '||s.atop_mn)||', '||s.atop_position c1,  --ПІБ, посада
           decode(s.atop_tp, 'MC', 'голови комісії', 'OC', 'члена комісії') c1_2,
           s.atop_phone c3 --телефон
      from uss_esr.v_at_other_spec s
     where s.atop_at = :p_at_id
       and s.history_status = 'A'
     order by c1
    ]';
        l_str :=
            REGEXP_REPLACE (l_str,
                            ':p_at_id',
                            p_at_id,
                            1,
                            0,
                            'i');
        rdm$rtfl_univ.AddDataset ('ds_spc', l_str);

        ------------------------------------
        rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                         p_rpt_blob   => l_result);
        replace_ekr (l_result);

        RETURN l_result;
    END ACT_DOC_1000_R1;

    --#94137 Карта визначення СП фізичного супроводу для послуги 021.0
    FUNCTION ACT_DOC_1002_R1 (p_at_id IN NUMBER)
        RETURN BLOB
    IS
        CURSOR c_at IS
            SELECT a.at_dt,
                   a.at_sc,
                   a.At_rnspm,
                   a.at_wu,
                   a.at_cu,
                   a.at_ap
              FROM act a
             WHERE a.at_id = p_at_id;

        c          c_at%ROWTYPE;

        l_str      VARCHAR2 (32000);
        l_bal      NUMBER;

        p          Api$Act_Rpt.R_Person_for_act;                   --отримувач

        l_jbr_id   NUMBER;
        l_result   BLOB;
    BEGIN
        rdm$rtfl_univ.initreport (p_code     => 'ACT_DOC_1002_R1',
                                  p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);

        ------------------------------------
        OPEN c_at;

        FETCH c_at INTO c;

        CLOSE c_at;

        p :=
            get_AtPerson (p_at    => p_at_id,
                          p_atp   => get_AtPerson_id (p_at_id, 'OS'));

        AddParam ('1', Api$Act_Rpt.Get_Nsp_Name (p_rnspm_id => c.At_rnspm)); --назва надавача
        AddParam ('2', Api$Act_Rpt.Date2Str (c.at_dt));

        AddParam ('3', p.pib);
        AddParam ('4', p.birth_dt_str);
        AddParam ('5',
                  p.live_address || NVL2 (p.phone, ', тел. ' || p.phone));
        AddParam ('6-1', Api$Act_Rpt.chk_val2 (p.sex, 'M'));           --стать
        AddParam ('6-2', Api$Act_Rpt.chk_val2 (p.sex, 'F'));
        --Правовий статус uss_ndi.V_DDN_SS_CAPABLE_2
        AddParam ('7-1', Get_Ftr_Chk2 (p_at_id, p_nda => 5363, p_chk => 'CP'));
        AddParam ('7-2', Get_Ftr_Chk2 (p_at_id, p_nda => 5363, p_chk => 'LCP'));
        AddParam ('7-3', Get_Ftr_Chk2 (p_at_id, p_nda => 5363, p_chk => 'NCP'));

        AddParam (
            '8',
            Api$Act_Rpt.v_ddn ('uss_ndi.V_DDN_SCY_GROUP',
                               Api$Act_Rpt.Get_Ftr (p_at_id, p_nda => 5364))); --Інвалідність
        --Стан втрати зору uss_ndi.V_DDN_SS_VISION_LOSS
        AddParam ('9-1', Get_Ftr_Chk2 (p_at_id, p_nda => 5365, p_chk => 'C'));
        AddParam ('9-2', Get_Ftr_Chk2 (p_at_id, p_nda => 5365, p_chk => 'P'));
        AddParam ('9-3', Get_Ftr_Chk2 (p_at_id, p_nda => 5365, p_chk => 'S'));
        --Наявність технічних засобів uss_ndi.V_DDN_SS_TCH_ORIENTATION
        AddParam ('10-1', Get_Ftr_Chk2 (p_at_id, p_nda => 5366, p_chk => 'C'));
        AddParam ('10-2', Get_Ftr_Chk2 (p_at_id, p_nda => 5366, p_chk => 'G'));
        AddParam ('10-3', Get_Ftr_Chk2 (p_at_id, p_nda => 5366, p_chk => 'N'));

        --II. Сім’я та оточення
        --Сімейний стан uss_ndi.V_DDN_SS_MARITAL_STT1
        AddParam ('11-1', Get_Ftr_Chk2 (p_at_id, p_nda => 5367, p_chk => 'M'));
        AddParam ('11-2', Get_Ftr_Chk2 (p_at_id, p_nda => 5367, p_chk => 'S'));
        --Найближче оточення
        AddParam ('12-1', Get_Ftr_Chk2 (p_at_id, p_nda => 5368));
        AddParam ('12-2', Get_Ftr_Chk2 (p_at_id, p_nda => 5568));
        AddParam ('12-3', Get_Ftr_Chk2 (p_at_id, p_nda => 5569));
        AddParam ('12-4', Get_Ftr_Chk2 (p_at_id, p_nda => 5570));
        -- Наявність в найближчому оточенні осіб, які допомагають
        AddParam ('14-1', Get_Ftr_Chk2 (p_at_id, p_nda => 5369, p_chk => 'T'));
        AddParam ('14-2', Get_Ftr_Chk2 (p_at_id, p_nda => 5369, p_chk => 'F'));
        --Наявність осіб, які надають допомогу з фізичного супроводу
        AddParam ('15-1', Get_Ftr_Chk2 (p_at_id, p_nda => 5370));
        AddParam ('15-2', Get_Ftr_Chk2 (p_at_id, p_nda => 5571));
        AddParam ('15-3', Get_Ftr_Chk2 (p_at_id, p_nda => 5572));
        AddParam ('15-4', Get_Ftr_Chk2 (p_at_id, p_nda => 5573));
        AddParam ('15-5', Get_Ftr_Chk2 (p_at_id, p_nda => 5574));

        --ІІІ. Оцінка потреби отримувача в соціальній послузі фізичного супроводу
        --Шкала оцінки потреби отримувача у соціальній послузі фізичного супроводу
        AddParam ('t1.1.1', Get_Ftr_Ind (p_at_id, p_nda => 5371));
        AddParam ('t1.1.2', Get_Ftr_Ind (p_at_id, p_nda => 5372));
        AddParam ('t1.1.3', Get_Ftr_Ind (p_at_id, p_nda => 5373));
        AddParam ('t1.2.1', Get_Ftr_Ind (p_at_id, p_nda => 5374));
        AddParam ('t1.2.2', Get_Ftr_Ind (p_at_id, p_nda => 5375));
        AddParam ('t1.2.3', Get_Ftr_Ind (p_at_id, p_nda => 5376));
        AddParam ('t1.3.1', Get_Ftr_Ind (p_at_id, p_nda => 5377));
        AddParam ('t1.3.2', Get_Ftr_Ind (p_at_id, p_nda => 5378));
        --
        AddParam ('t1.4.1', Get_Ftr_Ind (p_at_id, p_nda => 5379));
        AddParam ('t1.4.2', Get_Ftr_Ind (p_at_id, p_nda => 5380));
        AddParam ('t1.4.3', Get_Ftr_Ind (p_at_id, p_nda => 5381));
        AddParam ('t1.5.1', Get_Ftr_Ind (p_at_id, p_nda => 5382));
        AddParam ('t1.5.2', Get_Ftr_Ind (p_at_id, p_nda => 5383));
        AddParam ('t1.6.1', Get_Ftr_Ind (p_at_id, p_nda => 5384));
        AddParam ('t1.6.2', Get_Ftr_Ind (p_at_id, p_nda => 5385));
        AddParam ('t1.6.3', Get_Ftr_Ind (p_at_id, p_nda => 5386));
        AddParam ('t1.7.1', Get_Ftr_Ind (p_at_id, p_nda => 5387));
        AddParam ('t1.7.2', Get_Ftr_Ind (p_at_id, p_nda => 5388));
        AddParam ('t1.7.3', Get_Ftr_Ind (p_at_id, p_nda => 5389));
        AddParam ('t1.8.1', Get_Ftr_Ind (p_at_id, p_nda => 5390));
        AddParam ('t1.8.2', Get_Ftr_Ind (p_at_id, p_nda => 5391));
        AddParam ('t1.8.3', Get_Ftr_Ind (p_at_id, p_nda => 5392));
        AddParam ('t1.9.1', Get_Ftr_Ind (p_at_id, p_nda => 5393));
        AddParam ('t1.9.2', Get_Ftr_Ind (p_at_id, p_nda => 5394));
        AddParam ('t1.9.3', Get_Ftr_Ind (p_at_id, p_nda => 5395));
        AddParam ('t1.10.1', Get_Ftr_Ind (p_at_id, p_nda => 5396));
        AddParam ('t1.10.2', Get_Ftr_Ind (p_at_id, p_nda => 5397));
        AddParam ('t1.11.1', Get_Ftr_Ind (p_at_id, p_nda => 5398));
        AddParam ('t1.11.2', Get_Ftr_Ind (p_at_id, p_nda => 5399));
        AddParam ('t1.11.3', Get_Ftr_Ind (p_at_id, p_nda => 5400));
        AddParam ('t1.11.4', Get_Ftr_Ind (p_at_id, p_nda => 5401));
        AddParam ('t1.12.1', Get_Ftr_Ind (p_at_id, p_nda => 5402));
        AddParam ('t1.12.2', Get_Ftr_Ind (p_at_id, p_nda => 5403));
        AddParam ('t1.13.1', Get_Ftr_Ind (p_at_id, p_nda => 5404));
        AddParam ('t1.13.2', Get_Ftr_Ind (p_at_id, p_nda => 5405));
        AddParam ('t1.13.3', Get_Ftr_Ind (p_at_id, p_nda => 5406));
        AddParam ('t1.13.4', Get_Ftr_Ind (p_at_id, p_nda => 5407));
        AddParam ('t1.14.1', Get_Ftr_Ind (p_at_id, p_nda => 5408));
        AddParam ('t1.14.2', Get_Ftr_Ind (p_at_id, p_nda => 5409));
        AddParam ('t1.15.1', Get_Ftr_Ind (p_at_id, p_nda => 5410));
        AddParam ('t1.15.2', Get_Ftr_Ind (p_at_id, p_nda => 5411));
        AddParam ('t1.16.1', Get_Ftr_Ind (p_at_id, p_nda => 5412));
        AddParam ('t1.16.2', Get_Ftr_Ind (p_at_id, p_nda => 5413));
        AddParam ('t1.16.3', Get_Ftr_Ind (p_at_id, p_nda => 5414));
        AddParam ('t1.17.1', Get_Ftr_Ind (p_at_id, p_nda => 5415));
        AddParam ('t1.17.2', Get_Ftr_Ind (p_at_id, p_nda => 5416));
        AddParam ('t1.17.3', Get_Ftr_Ind (p_at_id, p_nda => 5417));

        --ІV. Висновки
        l_bal :=
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 371).ate_indicator_value1;
        l_str :=
            CASE
                WHEN l_bal <= 22 THEN 1
                WHEN l_bal BETWEEN 23 AND 34 THEN 2
                WHEN l_bal >= 35 THEN 3
            END;
        AddParam ('40-1', Api$Act_Rpt.chk_val2 (1, l_str)); --низький ступінь;
        AddParam ('40-2', Api$Act_Rpt.chk_val2 (2, l_str)); --помірний ступінь;
        AddParam ('40-3', Api$Act_Rpt.chk_val2 (3, l_str)); --високий ступінь.

        AddParam ('41', l_bal);                           -- усього #41# балів
        AddParam (
            '42',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 371).ate_indicator_value2); --в середньому #42# годин

        AddParam ('sgn1',
                  Api$Act_Rpt.Get_IPr (Api$Act_Rpt.GetCuPIB (c.at_cu))); --Підпис працівника, який визначав індивідуальні потреби
        AddParam ('sgn2', Api$Act_Rpt.Get_IPr (p.pib));         --Одержувач СП
        AddParam (
            'sgn3',
            Api$Act_Rpt.Get_IPr (
                get_signers_wucu_pib (p_at_id => p_at_id, p_ati_tp => 'PR'))); --Керівник надавача


        AddParam (
            'sgn_mark',
            api$act_rpt.get_sign_mark (p_at_id,
                                       p.Atp_Id,
                                       '_________________'));

        ------------------------------------
        rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                         p_rpt_blob   => l_result);
        replace_ekr (l_result);

        RETURN l_result;
    END ACT_DOC_1002_R1;

    --#94136 КАРТКА ОЦІНЮВАННЯ індивідуальних потреб отримувача соціальної послуги 020.0
    FUNCTION ACT_DOC_1005_R1 (p_at_id IN NUMBER)
        RETURN BLOB
    IS
        CURSOR c_at IS
            SELECT a.at_dt,
                   a.at_sc,
                   a.at_wu,
                   a.at_cu,
                   a.at_ap
              FROM act a
             WHERE a.at_id = p_at_id;

        c          c_at%ROWTYPE;

        l_str      VARCHAR2 (32000);

        p          Api$Act_Rpt.R_Person_for_act;                   --отримувач

        l_jbr_id   NUMBER;
        l_result   BLOB;
    BEGIN
        rdm$rtfl_univ.initreport (p_code     => 'ACT_DOC_1005_R1',
                                  p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);

        ------------------------------------
        OPEN c_at;

        FETCH c_at INTO c;

        CLOSE c_at;

        p :=
            get_AtPerson (p_at    => p_at_id,
                          p_atp   => get_AtPerson_id (p_at_id, 'OS'));
        AddParam ('1', p.live_address);

        l_str := q'[
       select
             pib                             as c1,
             birth_dt_str                    as c2,
             Relation_Tp                     as c3,
             case when is_disabled = 'T' then 'Так' else 'Ні' end as c4,
             work_place                      as c5,
             decode(is_adr_matching, 'T', 'Так') as c6,
             decode(is_adr_matching, 'F', 'Ні')  as c7,
             phone                           as c8
       from table(uss_esr.Api$Act_Rpt.At_Person_for_act(:p_at_id)) t
       where atp_app_tp = 'OS'
       order by birth_dt desc
  ]';
        l_str :=
            REGEXP_REPLACE (l_str,
                            ':p_at_id',
                            p_at_id,
                            1,
                            0,
                            'i');
        rdm$rtfl_univ.AddDataset ('ds1', l_str);

        l_str := q'[
       select
             pib                             as c1,
             birth_dt_str                    as c2,
             Relation_Tp                     as c3,
             case when is_disabled = 'T' then 'Так' else 'Ні' end as c4,
             work_place                      as c5,
             decode(is_adr_matching, 'T', 'Так') as c6,
             decode(is_adr_matching, 'F', 'Ні')  as c7,
             phone                           as c8
       from table(uss_esr.Api$Act_Rpt.At_Person_for_act(:p_at_id)) t
       where atp_app_tp <> 'OS'
       order by birth_dt desc
  ]';
        l_str :=
            REGEXP_REPLACE (l_str,
                            ':p_at_id',
                            p_at_id,
                            1,
                            0,
                            'i');
        rdm$rtfl_univ.AddDataset ('ds2', l_str);

        AddParam ('t1', Api$Act_Rpt.get_AtSctNt (p_at_id, p_nng => 372)); --Додаткова інформація

        --2. Загальна характеристика отримувача соціальної послуги
        --1) попередня підготовка
        AddParam ('t2.1.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5419));
        AddParam ('t2.1.1.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5419, p_chk => 'F'));
        AddParam ('t2.1.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5420));
        AddParam ('t2.1.2.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5420, p_chk => 'F'));
        AddParam ('t2.1.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5421));
        AddParam ('t2.1.3.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5421, p_chk => 'F'));
        AddParam ('t2.1.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5422));
        AddParam ('t2.1.4.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5422, p_chk => 'F'));
        AddParam ('t2.1.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5423));
        AddParam ('t2.1.5.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5423, p_chk => 'F'));
        AddParam ('t2.1.6', Get_Ftr_Chk2 (p_at_id, p_nda => 5424));
        AddParam ('t2.1.6.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5424, p_chk => 'F'));
        AddParam ('t2.1.7', Get_Ftr_Chk2 (p_at_id, p_nda => 5425));
        AddParam ('t2.1.7.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5425, p_chk => 'F'));
        AddParam ('t2.1', Api$Act_Rpt.get_AtSctNt (p_at_id, p_nng => 373)); --Додаткова інформація
        --2) соціальні навички
        AddParam ('t2.2.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5426));
        AddParam ('t2.2.1.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5426, p_chk => 'F'));
        AddParam ('t2.2.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5427));
        AddParam ('t2.2.2.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5427, p_chk => 'F'));
        AddParam ('t2.2.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5428));
        AddParam ('t2.2.3.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5428, p_chk => 'F'));
        AddParam ('t2.2.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5429));
        AddParam ('t2.2.4.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5429, p_chk => 'F'));
        AddParam ('t2.2.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5430));
        AddParam ('t2.2.5.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5430, p_chk => 'F'));
        AddParam ('t2.2.6', Get_Ftr_Chk2 (p_at_id, p_nda => 5431));
        AddParam ('t2.2.6.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5431, p_chk => 'F'));
        AddParam ('t2.2.7', Get_Ftr_Chk2 (p_at_id, p_nda => 5432));
        AddParam ('t2.2.7.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5432, p_chk => 'F'));
        AddParam ('t2.2.8', Get_Ftr_Chk2 (p_at_id, p_nda => 5433));
        AddParam ('t2.2.8.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5433, p_chk => 'F'));
        AddParam ('t2.2', Api$Act_Rpt.get_AtSctNt (p_at_id, p_nng => 374)); --Додаткова інформація
        --3) емоційна та поведінкова складові
        AddParam ('t2.3.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5434));
        AddParam ('t2.3.1.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5434, p_chk => 'F'));
        AddParam ('t2.3.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5435));
        AddParam ('t2.3.2.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5435, p_chk => 'F'));
        AddParam ('t2.3.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5436));
        AddParam ('t2.3.3.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5436, p_chk => 'F'));
        AddParam ('t2.3.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5437));
        AddParam ('t2.3.4.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5437, p_chk => 'F'));
        AddParam ('t2.3.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5438));
        AddParam ('t2.3.5.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5438, p_chk => 'F'));
        AddParam ('t2.3.6', Get_Ftr_Chk2 (p_at_id, p_nda => 5439));
        AddParam ('t2.3.6.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5439, p_chk => 'F'));
        AddParam ('t2.3.7', Get_Ftr_Chk2 (p_at_id, p_nda => 5440));
        AddParam ('t2.3.7.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5440, p_chk => 'F'));
        AddParam ('t2.3.8', Get_Ftr_Chk2 (p_at_id, p_nda => 5441));
        AddParam ('t2.3.8.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5441, p_chk => 'F'));
        AddParam ('t2.3.9', Get_Ftr_Chk2 (p_at_id, p_nda => 5442));
        AddParam ('t2.3.9.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5442, p_chk => 'F'));
        AddParam ('t2.3.10', Get_Ftr_Chk2 (p_at_id, p_nda => 5443));
        AddParam ('t2.3.10.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5443, p_chk => 'F'));
        AddParam ('t2.3.11', Get_Ftr_Chk2 (p_at_id, p_nda => 5444));
        AddParam ('t2.3.11.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5444, p_chk => 'F'));
        AddParam ('t2.3', Api$Act_Rpt.get_AtSctNt (p_at_id, p_nng => 375)); --Додаткова інформація

        --3. Потреби дитини
        --1) мобільність
        AddParam ('t3.1.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5445));
        AddParam ('t3.1.1.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5445, p_chk => 'F'));
        AddParam ('t3.1.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5446));
        AddParam ('t3.1.2.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5446, p_chk => 'F'));
        AddParam ('t3.1.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5447));
        AddParam ('t3.1.3.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5447, p_chk => 'F'));
        AddParam ('t3.1.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5448));
        AddParam ('t3.1.4.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5448, p_chk => 'F'));
        AddParam ('t3.1.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5449));
        AddParam ('t3.1.5.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5449, p_chk => 'F'));
        AddParam ('t3.1.6', Get_Ftr_Chk2 (p_at_id, p_nda => 5450));
        AddParam ('t3.1.6.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5450, p_chk => 'F'));
        AddParam ('t3.1.7', Get_Ftr_Chk2 (p_at_id, p_nda => 5451));
        AddParam ('t3.1.7.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5451, p_chk => 'F'));
        AddParam ('t3.1.8', Get_Ftr_Chk2 (p_at_id, p_nda => 5452));
        AddParam ('t3.1.8.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5452, p_chk => 'F'));
        AddParam ('t3.1.9', Get_Ftr_Chk2 (p_at_id, p_nda => 5453));
        AddParam ('t3.1.9.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5453, p_chk => 'F'));
        AddParam ('t3.1.10', Get_Ftr_Chk2 (p_at_id, p_nda => 5454));
        AddParam ('t3.1.10.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5454, p_chk => 'F'));
        AddParam ('t3.1.11', Get_Ftr_Chk2 (p_at_id, p_nda => 5455));
        AddParam ('t3.1.11.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5455, p_chk => 'F'));
        AddParam ('t3.1.12', Get_Ftr_Chk2 (p_at_id, p_nda => 5456));
        AddParam ('t3.1.12.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5456, p_chk => 'F'));
        AddParam ('t3.1.13', Get_Ftr_Chk2 (p_at_id, p_nda => 5457));
        AddParam ('t3.1.13.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5457, p_chk => 'F'));
        AddParam ('t3.1.14', Get_Ftr_Chk2 (p_at_id, p_nda => 5458));
        AddParam ('t3.1.14.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5458, p_chk => 'F'));
        AddParam ('t3.1.15', Get_Ftr_Chk2 (p_at_id, p_nda => 5459));
        AddParam ('t3.1.15.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5459, p_chk => 'F'));
        AddParam ('t3.1', Api$Act_Rpt.get_AtSctNt (p_at_id, p_nng => 376)); --Додаткова інформація
        --2) самообслуговування
        AddParam ('t3.2.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5460));
        AddParam ('t3.2.1.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5460, p_chk => 'F'));
        AddParam ('t3.2.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5461));
        AddParam ('t3.2.2.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5461, p_chk => 'F'));
        AddParam ('t3.2.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5462));
        AddParam ('t3.2.3.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5462, p_chk => 'F'));
        AddParam ('t3.2.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5463));
        AddParam ('t3.2.4.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5463, p_chk => 'F'));
        AddParam ('t3.2.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5464));
        AddParam ('t3.2.5.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5464, p_chk => 'F'));
        AddParam ('t3.2.6', Get_Ftr_Chk2 (p_at_id, p_nda => 5465));
        AddParam ('t3.2.6.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5465, p_chk => 'F'));
        AddParam ('t3.2.7', Get_Ftr_Chk2 (p_at_id, p_nda => 5466));
        AddParam ('t3.2.7.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5466, p_chk => 'F'));
        AddParam ('t3.2.8', Get_Ftr_Chk2 (p_at_id, p_nda => 5467));
        AddParam ('t3.2.8.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5467, p_chk => 'F'));
        AddParam ('t3.2', Api$Act_Rpt.get_AtSctNt (p_at_id, p_nng => 377)); --Додаткова інформація
        --3) харчування
        AddParam ('t3.3.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5468));
        AddParam ('t3.3.1.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5468, p_chk => 'F'));
        AddParam ('t3.3.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5469));
        AddParam ('t3.3.2.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5469, p_chk => 'F'));
        AddParam ('t3.3.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5470));
        AddParam ('t3.3.3.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5470, p_chk => 'F'));
        AddParam ('t3.3.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5471));
        AddParam ('t3.3.4.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5471, p_chk => 'F'));
        AddParam ('t3.3.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5472));
        AddParam ('t3.3.5.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5472, p_chk => 'F'));
        AddParam ('t3.3.6', Get_Ftr_Chk2 (p_at_id, p_nda => 5473));
        AddParam ('t3.3.6.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5473, p_chk => 'F'));
        AddParam ('t3.3.7', Get_Ftr_Chk2 (p_at_id, p_nda => 5474));
        AddParam ('t3.3.7.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5474, p_chk => 'F'));
        AddParam ('t3.3.8', Get_Ftr_Chk2 (p_at_id, p_nda => 5475));
        AddParam ('t3.3.8.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5475, p_chk => 'F'));
        AddParam ('t3.3.9', Get_Ftr_Chk2 (p_at_id, p_nda => 5476));
        AddParam ('t3.3.9.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5476, p_chk => 'F'));
        AddParam ('t3.3.10', Get_Ftr_Chk2 (p_at_id, p_nda => 5477));
        AddParam ('t3.3.10.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5477, p_chk => 'F'));
        AddParam ('t3.3.11', Get_Ftr_Chk2 (p_at_id, p_nda => 5478));
        AddParam ('t3.3.11.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5478, p_chk => 'F'));
        AddParam ('t3.2', Api$Act_Rpt.get_AtSctNt (p_at_id, p_nng => 378)); --Додаткова інформація
        --4) комунікація
        AddParam ('t3.4.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5479));
        AddParam ('t3.4.2.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5479, p_chk => 'F'));
        AddParam ('t3.4.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5480));
        AddParam ('t3.4.3.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5480, p_chk => 'F'));
        AddParam ('t3.4.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5481));
        AddParam ('t3.4.4.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5481, p_chk => 'F'));
        AddParam ('t3.4.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5482));
        AddParam ('t3.4.5.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5482, p_chk => 'F'));
        AddParam ('t3.4.6', Get_Ftr_Chk2 (p_at_id, p_nda => 5483));
        AddParam ('t3.4.6.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5483, p_chk => 'F'));
        AddParam ('t3.4.8', Get_Ftr_Chk2 (p_at_id, p_nda => 5484));
        AddParam ('t3.4.8.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5484, p_chk => 'F'));
        AddParam ('t3.4.9', Get_Ftr_Chk2 (p_at_id, p_nda => 5485));
        AddParam ('t3.4.9.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5485, p_chk => 'F'));
        AddParam ('t3.4.10', Get_Ftr_Chk2 (p_at_id, p_nda => 5486));
        AddParam ('t3.4.10.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5486, p_chk => 'F'));
        AddParam ('t3.4.11', Get_Ftr_Chk2 (p_at_id, p_nda => 5487));
        AddParam ('t3.4.11.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5487, p_chk => 'F'));
        AddParam ('t3.4.13', Get_Ftr_Chk2 (p_at_id, p_nda => 5488));
        AddParam ('t3.4.13.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5488, p_chk => 'F'));
        AddParam ('t3.4.14', Get_Ftr_Chk2 (p_at_id, p_nda => 5489));
        AddParam ('t3.4.14.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5489, p_chk => 'F'));
        AddParam ('t3.4.15', Get_Ftr_Chk2 (p_at_id, p_nda => 5490));
        AddParam ('t3.4.15.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5490, p_chk => 'F'));
        AddParam ('t3.4.16', Get_Ftr_Chk2 (p_at_id, p_nda => 5491));
        AddParam ('t3.4.16.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5491, p_chk => 'F'));
        AddParam ('t3.4.17', Get_Ftr_Chk2 (p_at_id, p_nda => 5492));
        AddParam ('t3.4.17.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5492, p_chk => 'F'));
        AddParam ('t3.4.18', Get_Ftr_Chk2 (p_at_id, p_nda => 5493));
        AddParam ('t3.4.18.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5493, p_chk => 'F'));
        AddParam ('t3.4.19', Get_Ftr_Chk2 (p_at_id, p_nda => 5494));
        AddParam ('t3.4.19.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5494, p_chk => 'F'));
        AddParam ('t3.4.20', Get_Ftr_Chk2 (p_at_id, p_nda => 5495));
        AddParam ('t3.4.20.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5495, p_chk => 'F'));
        AddParam ('t3.4.21', Get_Ftr_Chk2 (p_at_id, p_nda => 5496));
        AddParam ('t3.4.21.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5496, p_chk => 'F'));
        AddParam ('t3.4.22', Get_Ftr_Chk2 (p_at_id, p_nda => 5497));
        AddParam ('t3.4.22.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5497, p_chk => 'F'));
        AddParam ('t3.4.23', Get_Ftr_Chk2 (p_at_id, p_nda => 5498));
        AddParam ('t3.4.23.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5498, p_chk => 'F'));
        AddParam ('t3.4.24', Get_Ftr_Chk2 (p_at_id, p_nda => 5499));
        AddParam ('t3.4.24.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5499, p_chk => 'F'));
        AddParam ('t3.4.25', Get_Ftr_Chk2 (p_at_id, p_nda => 5500));
        AddParam ('t3.4.25.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5500, p_chk => 'F'));
        AddParam ('t3.4.26', Get_Ftr_Chk2 (p_at_id, p_nda => 5501));
        AddParam ('t3.4.26.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5501, p_chk => 'F'));
        AddParam ('t3.4.27', Get_Ftr_Chk2 (p_at_id, p_nda => 5502));
        AddParam ('t3.4.27.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5502, p_chk => 'F'));
        AddParam ('t3.4.28', Get_Ftr_Chk2 (p_at_id, p_nda => 5503));
        AddParam ('t3.4.28.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5503, p_chk => 'F'));
        AddParam ('t3.4.29', Get_Ftr_Chk2 (p_at_id, p_nda => 5504));
        AddParam ('t3.4.29.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5504, p_chk => 'F'));
        AddParam ('t3.4.30', Get_Ftr_Chk2 (p_at_id, p_nda => 5505));
        AddParam ('t3.4.30.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5505, p_chk => 'F'));
        AddParam ('t3.4', Api$Act_Rpt.get_AtSctNt (p_at_id, p_nng => 379)); --Додаткова інформація
        --5) безпека
        AddParam ('t3.5.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5506));
        AddParam ('t3.5.1.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5506, p_chk => 'F'));
        AddParam ('t3.5.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5507));
        AddParam ('t3.5.2.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5507, p_chk => 'F'));
        AddParam ('t3.5.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5508));
        AddParam ('t3.5.3.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5508, p_chk => 'F'));
        AddParam ('t3.5.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5509));
        AddParam ('t3.5.4.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5509, p_chk => 'F'));
        AddParam ('t3.5.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5510));
        AddParam ('t3.5.5.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5510, p_chk => 'F'));
        AddParam ('t3.5.6', Get_Ftr_Chk2 (p_at_id, p_nda => 5511));
        AddParam ('t3.5.6.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5511, p_chk => 'F'));
        AddParam ('t3.5.7', Get_Ftr_Chk2 (p_at_id, p_nda => 5512));
        AddParam ('t3.5.7.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5512, p_chk => 'F'));
        AddParam ('t3.5.8', Get_Ftr_Chk2 (p_at_id, p_nda => 5513));
        AddParam ('t3.5.8.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5513, p_chk => 'F'));
        AddParam ('t3.5.9', Get_Ftr_Chk2 (p_at_id, p_nda => 5514));
        AddParam ('t3.5.9.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5514, p_chk => 'F'));
        AddParam ('t3.5.10', Get_Ftr_Chk2 (p_at_id, p_nda => 5515));
        AddParam ('t3.5.10.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5515, p_chk => 'F'));
        AddParam ('t3.5.11', Get_Ftr_Chk2 (p_at_id, p_nda => 5516));
        AddParam ('t3.5.11.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5516, p_chk => 'F'));
        AddParam ('t3.5.12', Get_Ftr_Chk2 (p_at_id, p_nda => 5517));
        AddParam ('t3.5.12.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5517, p_chk => 'F'));
        AddParam ('t3.5.13', Get_Ftr_Chk2 (p_at_id, p_nda => 5518));
        AddParam ('t3.5.13.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5518, p_chk => 'F'));
        AddParam ('t3.5.15', Get_Ftr_Chk2 (p_at_id, p_nda => 5519));
        AddParam ('t3.5.15.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5519, p_chk => 'F'));
        AddParam ('t3.5.16', Get_Ftr_Chk2 (p_at_id, p_nda => 5520));
        AddParam ('t3.5.16.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5520, p_chk => 'F'));
        AddParam ('t3.5.17', Get_Ftr_Chk2 (p_at_id, p_nda => 5521));
        AddParam ('t3.5.17.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5521, p_chk => 'F'));
        AddParam ('t3.5.19', Get_Ftr_Chk2 (p_at_id, p_nda => 5522));
        AddParam ('t3.5.19.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5522, p_chk => 'F'));
        AddParam ('t3.5.20', Get_Ftr_Chk2 (p_at_id, p_nda => 5523));
        AddParam ('t3.5.20.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5523, p_chk => 'F'));
        AddParam ('t3.5', Api$Act_Rpt.get_AtSctNt (p_at_id, p_nng => 379)); --Додаткова інформація
        --6) орієнтація в просторі та навколишньому середовищі
        AddParam ('t3.6.1', Get_Ftr_Chk2 (p_at_id, p_nda => 5524));
        AddParam ('t3.6.1.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5524, p_chk => 'F'));
        AddParam ('t3.6.2', Get_Ftr_Chk2 (p_at_id, p_nda => 5525));
        AddParam ('t3.6.2.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5525, p_chk => 'F'));
        AddParam ('t3.6.3', Get_Ftr_Chk2 (p_at_id, p_nda => 5526));
        AddParam ('t3.6.3.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5526, p_chk => 'F'));
        AddParam ('t3.6.4', Get_Ftr_Chk2 (p_at_id, p_nda => 5527));
        AddParam ('t3.6.4.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5527, p_chk => 'F'));
        AddParam ('t3.6.5', Get_Ftr_Chk2 (p_at_id, p_nda => 5528));
        AddParam ('t3.6.5.2',
                  Get_Ftr_Chk2 (p_at_id, p_nda => 5528, p_chk => 'F'));
        AddParam ('t3.6', Api$Act_Rpt.get_AtSctNt (p_at_id, p_nng => 379)); --Додаткова інформація

        --Підпис працівника, який оцінював індивідуальні потреби
        AddParam ('sgn1',
                  Api$Act_Rpt.Get_IPr (Api$Act_Rpt.GetCuPIB (c.at_Cu)));

        --Батько / мати / інший законний представник
        FOR s IN (SELECT *
                    FROM uss_esr.At_Person p
                   WHERE p.atp_at = p_at_id AND atp_app_tp <> 'OS')
        LOOP
            p := Api$Act_Rpt.get_at_signers_pers (p_at_id, s.atp_id);
            EXIT WHEN p.pib IS NOT NULL;
        END LOOP;

        AddParam ('sgn2', Api$Act_Rpt.Get_IPr (p.pib));
        AddParam (
            'sgn_mark',
            api$act_rpt.get_sign_mark (p_at_id, p.Atp_Id, '____________'));

        --Керівник надавача
        AddParam (
            'sgn3',
            Api$Act_Rpt.Get_IPr (
                get_signers_wucu_pib (p_at_id => p_at_id, p_ati_tp => 'PR')));

        ------------------------------------
        rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                         p_rpt_blob   => l_result);
        replace_ekr (l_result);

        RETURN l_result;
    END ACT_DOC_1005_R1;

    --#98708 015.1- Соціальна послуга Догляд вдома
    FUNCTION ACT_DOC_1013_R1 (p_at_id IN NUMBER)
        RETURN BLOB
    IS
        --секція ЖИТЛО/ДОКУМЕНТИ з розділу "Анкета визначення рейтингу соціальних потреб..."
        C_ATE_NNG_ANK   CONSTANT INTEGER := 890;

        CURSOR c_at IS
            SELECT a.at_dt,
                   a.at_sc,
                   a.at_wu,
                   a.at_cu,
                   a.at_ap,
                   ikis_rbm.tools.GetCuPib (a.at_cu)     AS cu_pib
              FROM act a
             WHERE a.at_id = p_at_id;

        c                        c_at%ROWTYPE;

        l_str                    VARCHAR2 (32000);

        p1                       Api$Act_Rpt.R_Person_for_act;     --отримувач
        p2                       at_other_spec%ROWTYPE;             --Фахівець
        p3                       Api$Act_Rpt.R_Person_for_act; --Законний представник
        l_id                     NUMBER;
        l_jbr_id                 NUMBER;
        l_result                 BLOB;

        --для Анкети (uss_ndi.V_DDN_SS_TFN1)
        PROCEDURE AddFtrAnk (p_Param_Name   VARCHAR2,
                             p_atp          at_person.atp_id%TYPE,
                             p_nda          NUMBER)
        IS
        BEGIN
            CASE Get_Ftr (p_at_id => p_at_id, p_atp => p_atp, p_nda => p_nda)
                WHEN 'T'
                THEN
                    AddParam (p_Param_Name, 'Так');
                WHEN 'F'
                THEN
                    AddParam (p_Param_Name, 'Ні');
                ELSE
                    AddParam (p_Param_Name, '--');
            END CASE;
        END;

        PROCEDURE AddFtrAnk2 (p_Param_Name   VARCHAR2,
                              p_Atop         At_Section.Ate_Atop%TYPE,
                              p_Nda          NUMBER)
        IS
            CURSOR Cur IS
                SELECT f.Atef_Feature
                  FROM Uss_Esr.At_Section s, Uss_Esr.At_Section_Feature f
                 WHERE     s.Ate_At = p_At_Id
                       AND s.Ate_Atop = p_Atop
                       AND f.Atef_Ate = s.Ate_Id
                       AND f.Atef_Nda = p_Nda;

            l_Res   At_Section_Feature.Atef_Feature%TYPE;
        BEGIN
            OPEN Cur;

            FETCH Cur INTO l_Res;

            CLOSE Cur;

            CASE l_Res
                WHEN 'T'
                THEN
                    Addparam (p_Param_Name, 'Так');
                WHEN 'F'
                THEN
                    Addparam (p_Param_Name, 'Ні');
                ELSE
                    Addparam (p_Param_Name, '--');
            END CASE;
        END;

        PROCEDURE AddCnk (p_param VARCHAR2, p_nda NUMBER)
        IS
        BEGIN
            AddParam (p_param, Get_Ftr_Chk2 (p_at_id, p_nda => p_nda));
        END;

        FUNCTION AddCnkWithNumber (p_val        NUMBER,
                                   p_start      NUMBER,
                                   p_stop       NUMBER,
                                   p_check   IN VARCHAR2 DEFAULT NULL,
                                   p_at_id   IN NUMBER DEFAULT NULL)
            RETURN VARCHAR2
        IS
            l_check   NUMBER := 1;
            l_res     VARCHAR2 (4000);
        BEGIN
            IF (p_check IS NOT NULL)
            THEN
                l_check :=
                    CASE
                        WHEN Get_Ftr (p_at_id => p_at_id, p_nda => 8537) =
                             p_check
                        THEN
                            1
                        ELSE
                            0
                    END;
            END IF;

            IF (p_val BETWEEN p_start AND p_stop AND l_check = 1)
            THEN
                RETURN USS_ESR.Api$act_Rpt.Cnst_Check || ' (' || p_val || ')';
            END IF;

            RETURN NULL;
        END;

        --для заповнення таблиці 7:
        PROCEDURE AddChkT7 (p_Param_Name_lst VARCHAR2, p_nda NUMBER)
        IS
            l_ftr                at_section_feature.atef_feature%TYPE;

            c_val_lst   CONSTANT VARCHAR2 (1000) := '5,4,3,2,1,0'; --значення довідника для кожної колонки таблиці 7  uss_ndi.V_DDN_SS_TFN1

            l_Param_Name_lst     VARCHAR2 (1000);
            Result               VARCHAR2 (1000);
        BEGIN
            l_Param_Name_lst :=
                   CHR (39)
                || REPLACE (p_Param_Name_lst,
                            ',',
                            CHR (39) || ',' || CHR (39))
                || CHR (39);    --привести до виду "'t6.1.1.1','t6.1.1.2',..."
            l_ftr := Get_Ftr (p_at_id => p_at_id, p_nda => p_nda); --значення фічі

            FOR c
                IN (SELECT Param_Name, val
                      FROM (SELECT ROWNUM                                   rn,
                                   CAST (COLUMN_VALUE AS VARCHAR2 (100))    Param_Name
                              FROM XMLTABLE (l_Param_Name_lst)) t1,
                           (SELECT ROWNUM                                   rn,
                                   CAST (COLUMN_VALUE AS VARCHAR2 (100))    val
                              FROM XMLTABLE (c_val_lst)
                             WHERE c_val_lst IS NOT NULL) t2
                     WHERE t2.rn(+) = t1.rn)
            LOOP
                IF l_ftr = c.val
                THEN                                          --ставлю галочку
                    Result := USS_ESR.Api$act_Rpt.Cnst_Check;
                ELSE
                    Result := NULL;                        --org2ekr(c_unchk);
                END IF;

                AddParam (c.Param_Name, Result);
            END LOOP;
        END AddChkT7;
    BEGIN
        rdm$rtfl_univ.initreport (p_code     => 'ACT_DOC_1013_R1',
                                  p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);

        ------------------------------------
        OPEN c_at;

        FETCH c_at INTO c;

        CLOSE c_at;

        --шукаємо по секції з заповненими даними трьох осіб
        SELECT MAX (CASE WHEN p.atp_app_tp = 'OS' THEN p.atp_id END), --отримувач
               MAX (CASE WHEN p.atp_app_tp = 'Z' THEN p.atp_id END), --отримувач
               MAX (CASE WHEN p.Atp_App_Tp = 'OR' THEN p.atp_id END) --Законний представник
          INTO p1.atp_id, l_id, p3.atp_id
          FROM uss_esr.at_section s, at_person p
         WHERE     1 = 1
               AND s.ate_at = p_at_id
               --секція ЖИТЛО/ДОКУМЕНТИ з розділу Таблиця 6 "Анкета визначення рейтингу соціальних потреб..."
               AND s.ate_nng = C_ATE_NNG_ANK
               AND p.atp_at = s.ate_at
               AND p.atp_id = s.ate_atp;

        p1 := get_AtPerson (p_at => p_at_id, p_atp => NVL (p1.atp_id, l_id));
        p2 :=
            Get_Sctn_Specialist (p_At_Id         => p_at_id,
                                 p_Ate_Nng_Ank   => C_ATE_NNG_ANK); --Фахівець
        p3 := get_AtPerson (p_at => p_at_id, p_atp => p3.atp_id);

        --Таблиця 2 Шкала оцінювання можливості виконання елементарних дій
        /*for c in
        (
         select row_number() over(order by nng.nng_order, a.nda_order) rn, nng.nng_name, a.nda_id, a.nda_name, nng.nng_order, a.nda_order
           from uss_ndi.v_ndi_document_attr a, uss_ndi.v_ndi_nda_group nng
          where a.history_status = 'A' and nng.nng_id = a.nda_nng and a.nda_ndt = 1013 and a.nda_nng between 262 and 810
         order by rn
        )
        loop
          AddParam('t2.'||c.nda_id, Get_Ftr_Ind(p_at_id, p_nda => c.nda_id));
        end loop;*/
        --Сума балів
        AddParam ('t2.4883', Get_Ftr_Ind (p_at_id, p_nda => 4883));
        AddParam ('t2.4884', Get_Ftr_Ind (p_at_id, p_nda => 4884));
        AddParam ('t2.4885', Get_Ftr_Ind (p_at_id, p_nda => 4885));
        AddParam ('t2.4886', Get_Ftr_Ind (p_at_id, p_nda => 4886));
        AddParam ('t2.4887', Get_Ftr_Ind (p_at_id, p_nda => 4887));
        AddParam ('t2.4888', Get_Ftr_Ind (p_at_id, p_nda => 4888));
        AddParam ('t2.4889', Get_Ftr_Ind (p_at_id, p_nda => 4889));
        AddParam ('t2.4890', Get_Ftr_Ind (p_at_id, p_nda => 4890));
        AddParam ('t2.4891', Get_Ftr_Ind (p_at_id, p_nda => 4891));
        AddParam ('t2.4892', Get_Ftr_Ind (p_at_id, p_nda => 4892));
        AddParam ('t2.4893', Get_Ftr_Ind (p_at_id, p_nda => 4893));
        AddParam ('t2.4894', Get_Ftr_Ind (p_at_id, p_nda => 4894));
        AddParam ('t2.4895', Get_Ftr_Ind (p_at_id, p_nda => 4895));
        AddParam ('t2.4896', Get_Ftr_Ind (p_at_id, p_nda => 4896));
        AddParam ('t2.4897', Get_Ftr_Ind (p_at_id, p_nda => 4897));
        AddParam ('t2.4898', Get_Ftr_Ind (p_at_id, p_nda => 4898));
        AddParam ('t2.4899', Get_Ftr_Ind (p_at_id, p_nda => 4899));
        AddParam ('t2.4900', Get_Ftr_Ind (p_at_id, p_nda => 4900));
        AddParam ('t2.4901', Get_Ftr_Ind (p_at_id, p_nda => 4901));
        AddParam ('t2.4902', Get_Ftr_Ind (p_at_id, p_nda => 4902));
        AddParam ('t2.4903', Get_Ftr_Ind (p_at_id, p_nda => 4903));
        AddParam ('t2.4904', Get_Ftr_Ind (p_at_id, p_nda => 4904));
        AddParam ('t2.4905', Get_Ftr_Ind (p_at_id, p_nda => 4905));
        AddParam ('t2.4906', Get_Ftr_Ind (p_at_id, p_nda => 4906));
        AddParam ('t2.4907', Get_Ftr_Ind (p_at_id, p_nda => 4907));
        AddParam ('t2.4908', Get_Ftr_Ind (p_at_id, p_nda => 4908));
        AddParam ('t2.4909', Get_Ftr_Ind (p_at_id, p_nda => 4909));
        AddParam ('t2.4910', Get_Ftr_Ind (p_at_id, p_nda => 4910));
        AddParam ('t2.4911', Get_Ftr_Ind (p_at_id, p_nda => 4911));
        AddParam ('t2.4912', Get_Ftr_Ind (p_at_id, p_nda => 4912));
        AddParam ('t2.4913', Get_Ftr_Ind (p_at_id, p_nda => 4913));
        AddParam ('t2.4914', Get_Ftr_Ind (p_at_id, p_nda => 4914));
        AddParam ('t2.4915', Get_Ftr_Ind (p_at_id, p_nda => 4915));
        AddParam ('t2.4916', Get_Ftr_Ind (p_at_id, p_nda => 4916));
        AddParam ('t2.4917', Get_Ftr_Ind (p_at_id, p_nda => 4917));
        AddParam ('t2.4918', Get_Ftr_Ind (p_at_id, p_nda => 4918));
        AddParam ('t2.4919', Get_Ftr_Ind (p_at_id, p_nda => 4919));
        AddParam ('t2.4920', Get_Ftr_Ind (p_at_id, p_nda => 4920));
        AddParam ('t2.4921', Get_Ftr_Ind (p_at_id, p_nda => 4921));
        AddParam ('t2.4922', Get_Ftr_Ind (p_at_id, p_nda => 4922));
        AddParam ('t2.4923', Get_Ftr_Ind (p_at_id, p_nda => 4923));
        AddParam ('t2.4924', Get_Ftr_Ind (p_at_id, p_nda => 4924));
        AddParam ('t2.4925', Get_Ftr_Ind (p_at_id, p_nda => 4925));
        AddParam ('t2.4926', Get_Ftr_Ind (p_at_id, p_nda => 4926));
        AddParam ('t2.4927', Get_Ftr_Ind (p_at_id, p_nda => 4927));
        AddParam ('t2.4928', Get_Ftr_Ind (p_at_id, p_nda => 4928));
        AddParam ('t2.4929', Get_Ftr_Ind (p_at_id, p_nda => 4929));
        AddParam ('t2.4930', Get_Ftr_Ind (p_at_id, p_nda => 4930));
        AddParam ('t2.4931', Get_Ftr_Ind (p_at_id, p_nda => 4931));
        AddParam ('t2.4932', Get_Ftr_Ind (p_at_id, p_nda => 4932));
        AddParam ('t2.4933', Get_Ftr_Ind (p_at_id, p_nda => 4933));
        AddParam ('t2.4934', Get_Ftr_Ind (p_at_id, p_nda => 4934));
        AddParam ('t2.4935', Get_Ftr_Ind (p_at_id, p_nda => 4935));
        AddParam ('t2.4936', Get_Ftr_Ind (p_at_id, p_nda => 4936));
        AddParam ('t2.4937', Get_Ftr_Ind (p_at_id, p_nda => 4937));
        AddParam ('t2.4938', Get_Ftr_Ind (p_at_id, p_nda => 4938));
        AddParam ('t2.4939', Get_Ftr_Ind (p_at_id, p_nda => 4939));
        AddParam ('t2.4940', Get_Ftr_Ind (p_at_id, p_nda => 4940));
        AddParam ('t2.4941', Get_Ftr_Ind (p_at_id, p_nda => 4941));
        AddParam ('t2.4942', Get_Ftr_Ind (p_at_id, p_nda => 4942));
        AddParam ('t2.4943', Get_Ftr_Ind (p_at_id, p_nda => 4943));
        AddParam ('t2.4944', Get_Ftr_Ind (p_at_id, p_nda => 4944));
        AddParam ('t2.4945', Get_Ftr_Ind (p_at_id, p_nda => 4945));
        AddParam ('t2.4946', Get_Ftr_Ind (p_at_id, p_nda => 4946));
        AddParam ('t2.4947', Get_Ftr_Ind (p_at_id, p_nda => 4947));
        AddParam ('t2.4948', Get_Ftr_Ind (p_at_id, p_nda => 4948));
        AddParam ('t2.4949', Get_Ftr_Ind (p_at_id, p_nda => 4949));
        AddParam ('t2.4950', Get_Ftr_Ind (p_at_id, p_nda => 4950));
        AddParam ('t2.4951', Get_Ftr_Ind (p_at_id, p_nda => 4951));
        AddParam ('t2.4952', Get_Ftr_Ind (p_at_id, p_nda => 4952));
        AddParam (
            't2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 894).ate_indicator_value1);

        --Таблиця 3 Шкала оцінювання можливості виконання складних дій
        /*for c in
        (
         select row_number() over(order by nng.nng_order, a.nda_order) rn, nng.nng_name, a.nda_id, a.nda_name, nng.nng_order, a.nda_order
           from uss_ndi.v_ndi_document_attr a, uss_ndi.v_ndi_nda_group nng
          where a.history_status = 'A' and nng.nng_id = a.nda_nng and a.nda_ndt = 1013 and a.nda_nng between 811 and 819
         order by rn
        )
        loop
          AddParam('t3.'||c.nda_id, Get_Ftr_Ind(p_at_id, p_nda => c.nda_id));
        end loop;*/
        AddParam ('t3.4953', Get_Ftr_Ind (p_at_id, p_nda => 4953));
        AddParam ('t3.4954', Get_Ftr_Ind (p_at_id, p_nda => 4954));
        AddParam ('t3.7435', Get_Ftr_Ind (p_at_id, p_nda => 7435));
        AddParam ('t3.7436', Get_Ftr_Ind (p_at_id, p_nda => 7436));
        AddParam ('t3.7437', Get_Ftr_Ind (p_at_id, p_nda => 7437));
        AddParam ('t3.7438', Get_Ftr_Ind (p_at_id, p_nda => 7438));
        AddParam ('t3.7439', Get_Ftr_Ind (p_at_id, p_nda => 7439));
        AddParam ('t3.7440', Get_Ftr_Ind (p_at_id, p_nda => 7440));
        AddParam ('t3.7441', Get_Ftr_Ind (p_at_id, p_nda => 7441));
        AddParam ('t3.7442', Get_Ftr_Ind (p_at_id, p_nda => 7442));
        AddParam ('t3.7443', Get_Ftr_Ind (p_at_id, p_nda => 7443));
        AddParam ('t3.7444', Get_Ftr_Ind (p_at_id, p_nda => 7444));
        AddParam ('t3.7445', Get_Ftr_Ind (p_at_id, p_nda => 7445));
        AddParam ('t3.7446', Get_Ftr_Ind (p_at_id, p_nda => 7446));
        AddParam ('t3.7447', Get_Ftr_Ind (p_at_id, p_nda => 7447));
        AddParam ('t3.7448', Get_Ftr_Ind (p_at_id, p_nda => 7448));
        AddParam ('t3.7449', Get_Ftr_Ind (p_at_id, p_nda => 7449));
        AddParam ('t3.7450', Get_Ftr_Ind (p_at_id, p_nda => 7450));
        AddParam ('t3.7451', Get_Ftr_Ind (p_at_id, p_nda => 7451));
        AddParam ('t3.7452', Get_Ftr_Ind (p_at_id, p_nda => 7452));
        AddParam ('t3.7453', Get_Ftr_Ind (p_at_id, p_nda => 7453));
        AddParam ('t3.7454', Get_Ftr_Ind (p_at_id, p_nda => 7454));
        AddParam ('t3.7455', Get_Ftr_Ind (p_at_id, p_nda => 7455));
        AddParam ('t3.7456', Get_Ftr_Ind (p_at_id, p_nda => 7456));
        AddParam ('t3.7457', Get_Ftr_Ind (p_at_id, p_nda => 7457));
        AddParam ('t3.7458', Get_Ftr_Ind (p_at_id, p_nda => 7458));
        AddParam ('t3.7459', Get_Ftr_Ind (p_at_id, p_nda => 7459));
        AddParam ('t3.7460', Get_Ftr_Ind (p_at_id, p_nda => 7460));
        AddParam ('t3.7461', Get_Ftr_Ind (p_at_id, p_nda => 7461));
        AddParam ('t3.7462', Get_Ftr_Ind (p_at_id, p_nda => 7462));
        AddParam ('t3.7463', Get_Ftr_Ind (p_at_id, p_nda => 7463));
        AddParam ('t3.7464', Get_Ftr_Ind (p_at_id, p_nda => 7464));
        AddParam ('t3.7465', Get_Ftr_Ind (p_at_id, p_nda => 7465));
        AddParam ('t3.7466', Get_Ftr_Ind (p_at_id, p_nda => 7466));
        AddParam ('t3.7467', Get_Ftr_Ind (p_at_id, p_nda => 7467));
        AddParam ('t3.7468', Get_Ftr_Ind (p_at_id, p_nda => 7468));
        AddParam ('t3.7469', Get_Ftr_Ind (p_at_id, p_nda => 7469));
        AddParam ('t3.7470', Get_Ftr_Ind (p_at_id, p_nda => 7470));
        AddParam ('t3.7471', Get_Ftr_Ind (p_at_id, p_nda => 7471));
        AddParam ('t3.7472', Get_Ftr_Ind (p_at_id, p_nda => 7472));
        --Сума балів
        AddParam (
            't3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 894).ate_indicator_value2);

        --Таблиця 4 Шкала оцінювання навичок проживання за основними категоріями
        /*for c in
        (
         select row_number() over(order by nng.nng_order, a.nda_order) rn, nng.nng_name, a.nda_id, a.nda_name, nng.nng_order, a.nda_order
           from uss_ndi.v_ndi_document_attr a, uss_ndi.v_ndi_nda_group nng
          where a.history_status = 'A' and nng.nng_id = a.nda_nng and a.nda_ndt = 1013 and a.nda_nng between 820 and 889
         order by rn
        )
        loop
          AddCnk('t4.'||c.nda_id,  c.nda_id);
        end loop;*/
        AddCnk ('t4.7473', 7473);
        AddCnk ('t4.7474', 7474);
        AddCnk ('t4.7475', 7475);
        AddCnk ('t4.7476', 7476);
        AddCnk ('t4.7477', 7477);
        AddCnk ('t4.7478', 7478);
        AddCnk ('t4.7479', 7479);
        AddCnk ('t4.7480', 7480);
        AddCnk ('t4.7481', 7481);
        AddCnk ('t4.7482', 7482);
        AddCnk ('t4.7483', 7483);
        AddCnk ('t4.7484', 7484);
        AddCnk ('t4.7485', 7485);
        AddCnk ('t4.7486', 7486);
        AddCnk ('t4.7487', 7487);
        AddCnk ('t4.7488', 7488);
        AddCnk ('t4.7489', 7489);
        AddCnk ('t4.7490', 7490);
        AddCnk ('t4.7491', 7491);
        AddCnk ('t4.7492', 7492);
        AddCnk ('t4.7493', 7493);
        AddCnk ('t4.7494', 7494);
        AddCnk ('t4.7495', 7495);
        AddCnk ('t4.7496', 7496);
        AddCnk ('t4.7497', 7497);
        AddCnk ('t4.7498', 7498);
        AddCnk ('t4.7499', 7499);
        AddCnk ('t4.7500', 7500);
        AddCnk ('t4.7501', 7501);
        AddCnk ('t4.7502', 7502);
        AddCnk ('t4.7503', 7503);
        AddCnk ('t4.7504', 7504);
        AddCnk ('t4.7505', 7505);
        AddCnk ('t4.7506', 7506);
        AddCnk ('t4.7507', 7507);
        AddCnk ('t4.7508', 7508);
        AddCnk ('t4.7509', 7509);
        AddCnk ('t4.7510', 7510);
        AddCnk ('t4.7511', 7511);
        AddCnk ('t4.7512', 7512);
        AddCnk ('t4.7513', 7513);
        AddCnk ('t4.7514', 7514);
        AddCnk ('t4.7515', 7515);
        AddCnk ('t4.7516', 7516);
        AddCnk ('t4.7517', 7517);
        AddCnk ('t4.7518', 7518);
        AddCnk ('t4.7519', 7519);
        AddCnk ('t4.7520', 7520);
        AddCnk ('t4.7521', 7521);
        AddCnk ('t4.7522', 7522);
        AddCnk ('t4.7523', 7523);
        AddCnk ('t4.7524', 7524);
        AddCnk ('t4.7525', 7525);
        AddCnk ('t4.7526', 7526);
        AddCnk ('t4.7527', 7527);
        AddCnk ('t4.7528', 7528);
        AddCnk ('t4.7529', 7529);
        AddCnk ('t4.7530', 7530);
        AddCnk ('t4.7531', 7531);
        AddCnk ('t4.7532', 7532);
        AddCnk ('t4.7533', 7533);
        AddCnk ('t4.7534', 7534);
        AddCnk ('t4.7535', 7535);
        AddCnk ('t4.7536', 7536);
        AddCnk ('t4.7537', 7537);
        AddCnk ('t4.7538', 7538);
        AddCnk ('t4.7539', 7539);
        AddCnk ('t4.7540', 7540);
        AddCnk ('t4.7541', 7541);
        AddCnk ('t4.7542', 7542);
        AddCnk ('t4.7543', 7543);
        AddCnk ('t4.7544', 7544);
        AddCnk ('t4.7545', 7545);
        AddCnk ('t4.7546', 7546);
        AddCnk ('t4.7547', 7547);
        AddCnk ('t4.7548', 7548);
        AddCnk ('t4.7549', 7549);
        AddCnk ('t4.7550', 7550);
        AddCnk ('t4.7551', 7551);
        AddCnk ('t4.7552', 7552);
        AddCnk ('t4.7553', 7553);
        AddCnk ('t4.7554', 7554);
        AddCnk ('t4.7555', 7555);
        AddCnk ('t4.7556', 7556);
        AddCnk ('t4.7557', 7557);
        AddCnk ('t4.7558', 7558);
        AddCnk ('t4.7559', 7559);
        AddCnk ('t4.7560', 7560);
        AddCnk ('t4.7561', 7561);
        AddCnk ('t4.7562', 7562);
        AddCnk ('t4.7563', 7563);
        AddCnk ('t4.7564', 7564);
        AddCnk ('t4.7565', 7565);
        AddCnk ('t4.7566', 7566);
        AddCnk ('t4.7567', 7567);
        AddCnk ('t4.7568', 7568);
        AddCnk ('t4.7569', 7569);
        AddCnk ('t4.7570', 7570);
        AddCnk ('t4.7571', 7571);
        AddCnk ('t4.7572', 7572);
        AddCnk ('t4.7573', 7573);
        AddCnk ('t4.7574', 7574);
        AddCnk ('t4.7575', 7575);
        AddCnk ('t4.7576', 7576);
        AddCnk ('t4.7577', 7577);
        AddCnk ('t4.7578', 7578);
        AddCnk ('t4.7579', 7579);
        AddCnk ('t4.7580', 7580);
        AddCnk ('t4.7581', 7581);
        AddCnk ('t4.7582', 7582);
        AddCnk ('t4.7583', 7583);
        AddCnk ('t4.7584', 7584);
        AddCnk ('t4.7585', 7585);
        AddCnk ('t4.7586', 7586);
        AddCnk ('t4.7587', 7587);
        AddCnk ('t4.7588', 7588);
        AddCnk ('t4.7589', 7589);
        AddCnk ('t4.7590', 7590);
        AddCnk ('t4.7591', 7591);
        AddCnk ('t4.7592', 7592);
        AddCnk ('t4.7593', 7593);
        AddCnk ('t4.7594', 7594);
        AddCnk ('t4.7595', 7595);
        AddCnk ('t4.7596', 7596);
        AddCnk ('t4.7597', 7597);
        AddCnk ('t4.7598', 7598);
        AddCnk ('t4.7599', 7599);
        AddCnk ('t4.7600', 7600);
        AddCnk ('t4.7601', 7601);
        AddCnk ('t4.7602', 7602);
        AddCnk ('t4.7603', 7603);
        AddCnk ('t4.7604', 7604);
        AddCnk ('t4.7605', 7605);
        AddCnk ('t4.7606', 7606);
        AddCnk ('t4.7607', 7607);
        AddCnk ('t4.7608', 7608);
        AddCnk ('t4.7609', 7609);
        AddCnk ('t4.7610', 7610);
        AddCnk ('t4.7611', 7611);
        AddCnk ('t4.7612', 7612);
        AddCnk ('t4.7613', 7613);
        AddCnk ('t4.7614', 7614);
        AddCnk ('t4.7615', 7615);
        AddCnk ('t4.7616', 7616);
        AddCnk ('t4.7617', 7617);
        AddCnk ('t4.7618', 7618);
        AddCnk ('t4.7619', 7619);
        AddCnk ('t4.7620', 7620);
        AddCnk ('t4.7621', 7621);
        AddCnk ('t4.7622', 7622);
        AddCnk ('t4.7623', 7623);
        AddCnk ('t4.7624', 7624);
        AddCnk ('t4.7625', 7625);
        AddCnk ('t4.7626', 7626);
        AddCnk ('t4.7627', 7627);
        AddCnk ('t4.7628', 7628);
        AddCnk ('t4.7629', 7629);
        AddCnk ('t4.7630', 7630);
        AddCnk ('t4.7631', 7631);
        AddCnk ('t4.7632', 7632);
        AddCnk ('t4.7633', 7633);
        AddCnk ('t4.7634', 7634);
        AddCnk ('t4.7635', 7635);
        AddCnk ('t4.7636', 7636);
        AddCnk ('t4.7637', 7637);
        AddCnk ('t4.7638', 7638);
        AddCnk ('t4.7639', 7639);
        AddCnk ('t4.7640', 7640);
        AddCnk ('t4.7641', 7641);
        AddCnk ('t4.7642', 7642);
        AddCnk ('t4.7643', 7643);
        AddCnk ('t4.7644', 7644);
        AddCnk ('t4.7645', 7645);
        AddCnk ('t4.7646', 7646);
        AddCnk ('t4.7647', 7647);
        AddCnk ('t4.7648', 7648);
        AddCnk ('t4.7649', 7649);
        AddCnk ('t4.7650', 7650);
        AddCnk ('t4.7651', 7651);
        AddCnk ('t4.7652', 7652);
        AddCnk ('t4.7653', 7653);
        AddCnk ('t4.7654', 7654);
        AddCnk ('t4.7655', 7655);
        AddCnk ('t4.7656', 7656);
        AddCnk ('t4.7657', 7657);
        AddCnk ('t4.7658', 7658);
        AddCnk ('t4.7659', 7659);
        AddCnk ('t4.7660', 7660);
        AddCnk ('t4.7661', 7661);
        AddCnk ('t4.7662', 7662);
        AddCnk ('t4.7663', 7663);
        AddCnk ('t4.7664', 7664);
        AddCnk ('t4.7665', 7665);
        AddCnk ('t4.7666', 7666);
        AddCnk ('t4.7667', 7667);
        AddCnk ('t4.7668', 7668);
        AddCnk ('t4.7669', 7669);
        AddCnk ('t4.7670', 7670);
        AddCnk ('t4.7671', 7671);
        AddCnk ('t4.7672', 7672);
        AddCnk ('t4.7673', 7673);
        AddCnk ('t4.7674', 7674);
        AddCnk ('t4.7675', 7675);
        AddCnk ('t4.7676', 7676);
        AddCnk ('t4.7677', 7677);
        AddCnk ('t4.7678', 7678);
        AddCnk ('t4.7679', 7679);
        AddCnk ('t4.7680', 7680);
        AddCnk ('t4.7681', 7681);
        AddCnk ('t4.7682', 7682);
        AddCnk ('t4.7683', 7683);
        AddCnk ('t4.7684', 7684);
        AddCnk ('t4.7685', 7685);
        AddCnk ('t4.7686', 7686);
        AddCnk ('t4.7687', 7687);
        AddCnk ('t4.7688', 7688);
        AddCnk ('t4.7689', 7689);
        AddCnk ('t4.7690', 7690);
        AddCnk ('t4.7691', 7691);
        AddCnk ('t4.7692', 7692);
        AddCnk ('t4.7693', 7693);
        AddCnk ('t4.7694', 7694);
        AddCnk ('t4.7695', 7695);
        AddCnk ('t4.7696', 7696);
        AddCnk ('t4.7697', 7697);
        AddCnk ('t4.7698', 7698);
        AddCnk ('t4.7699', 7699);
        AddCnk ('t4.7700', 7700);
        AddCnk ('t4.7701', 7701);
        AddCnk ('t4.7702', 7702);
        AddCnk ('t4.7703', 7703);
        AddCnk ('t4.7704', 7704);
        AddCnk ('t4.7705', 7705);
        AddCnk ('t4.7706', 7706);
        AddCnk ('t4.7707', 7707);
        AddCnk ('t4.7708', 7708);
        AddCnk ('t4.7709', 7709);
        AddCnk ('t4.7710', 7710);
        AddCnk ('t4.7711', 7711);
        AddCnk ('t4.7712', 7712);
        AddCnk ('t4.7713', 7713);
        AddCnk ('t4.7714', 7714);
        AddCnk ('t4.7715', 7715);
        AddCnk ('t4.7716', 7716);
        AddCnk ('t4.7717', 7717);
        AddCnk ('t4.7718', 7718);
        AddCnk ('t4.7719', 7719);
        AddCnk ('t4.7720', 7720);
        AddCnk ('t4.7721', 7721);
        AddCnk ('t4.7722', 7722);
        AddCnk ('t4.7723', 7723);
        AddCnk ('t4.7724', 7724);
        AddCnk ('t4.7725', 7725);
        AddCnk ('t4.7726', 7726);
        AddCnk ('t4.7727', 7727);
        AddCnk ('t4.7728', 7728);
        AddCnk ('t4.7729', 7729);
        AddCnk ('t4.7730', 7730);
        AddCnk ('t4.7731', 7731);
        AddCnk ('t4.7732', 7732);
        AddCnk ('t4.7733', 7733);
        AddCnk ('t4.7734', 7734);
        AddCnk ('t4.7735', 7735);
        AddCnk ('t4.7736', 7736);
        AddCnk ('t4.7737', 7737);
        AddCnk ('t4.7738', 7738);
        AddCnk ('t4.7739', 7739);
        AddCnk ('t4.7740', 7740);
        AddCnk ('t4.7741', 7741);
        AddCnk ('t4.7742', 7742);
        AddCnk ('t4.7743', 7743);
        AddCnk ('t4.7744', 7744);
        AddCnk ('t4.7745', 7745);
        AddCnk ('t4.7746', 7746);
        AddCnk ('t4.7747', 7747);
        AddCnk ('t4.7748', 7748);
        AddCnk ('t4.7749', 7749);
        AddCnk ('t4.7750', 7750);
        AddCnk ('t4.7751', 7751);
        AddCnk ('t4.7752', 7752);
        AddCnk ('t4.7753', 7753);
        AddCnk ('t4.7754', 7754);
        AddCnk ('t4.7755', 7755);
        AddCnk ('t4.7756', 7756);
        AddCnk ('t4.7757', 7757);
        AddCnk ('t4.7758', 7758);
        AddCnk ('t4.7759', 7759);
        AddCnk ('t4.7760', 7760);
        AddCnk ('t4.7761', 7761);
        AddCnk ('t4.7762', 7762);
        AddCnk ('t4.7763', 7763);
        AddCnk ('t4.7764', 7764);
        AddCnk ('t4.7765', 7765);
        AddCnk ('t4.7766', 7766);
        AddCnk ('t4.7767', 7767);
        AddCnk ('t4.7768', 7768);
        AddCnk ('t4.7769', 7769);
        AddCnk ('t4.7770', 7770);
        AddCnk ('t4.7771', 7771);
        AddCnk ('t4.7772', 7772);
        AddCnk ('t4.7773', 7773);
        AddCnk ('t4.7774', 7774);
        AddCnk ('t4.7775', 7775);
        AddCnk ('t4.7776', 7776);
        AddCnk ('t4.7777', 7777);
        AddCnk ('t4.7778', 7778);
        AddCnk ('t4.7779', 7779);
        AddCnk ('t4.7780', 7780);
        AddCnk ('t4.7781', 7781);
        AddCnk ('t4.7782', 7782);
        AddCnk ('t4.7783', 7783);
        AddCnk ('t4.7784', 7784);
        AddCnk ('t4.7785', 7785);
        AddCnk ('t4.7786', 7786);
        AddCnk ('t4.7787', 7787);
        AddCnk ('t4.7788', 7788);
        AddCnk ('t4.7789', 7789);
        AddCnk ('t4.7790', 7790);
        AddCnk ('t4.7791', 7791);
        AddCnk ('t4.7792', 7792);
        AddCnk ('t4.7793', 7793);
        AddCnk ('t4.7794', 7794);
        AddCnk ('t4.7795', 7795);
        AddCnk ('t4.7796', 7796);
        AddCnk ('t4.7797', 7797);
        AddCnk ('t4.7798', 7798);
        AddCnk ('t4.7799', 7799);
        AddCnk ('t4.7800', 7800);
        AddCnk ('t4.7801', 7801);
        AddCnk ('t4.7802', 7802);
        AddCnk ('t4.7803', 7803);
        AddCnk ('t4.7804', 7804);
        AddCnk ('t4.7805', 7805);
        AddCnk ('t4.7806', 7806);
        AddCnk ('t4.7807', 7807);
        AddCnk ('t4.7808', 7808);
        AddCnk ('t4.7809', 7809);
        AddCnk ('t4.7810', 7810);
        AddCnk ('t4.7811', 7811);
        AddCnk ('t4.7812', 7812);
        AddCnk ('t4.7813', 7813);
        AddCnk ('t4.7814', 7814);
        AddCnk ('t4.7815', 7815);
        AddCnk ('t4.7816', 7816);
        AddCnk ('t4.7817', 7817);
        AddCnk ('t4.7818', 7818);
        AddCnk ('t4.7819', 7819);
        AddCnk ('t4.7820', 7820);
        AddCnk ('t4.7821', 7821);
        AddCnk ('t4.7822', 7822);

        --Таблиця 5 Картка визначення індивідуальних потреб отримувача соціальної послуги (ітоги з Таблиці 4)
        AddParam (
            't5.1.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 820).ate_indicator_value1); --1 організація харчування
        AddParam (
            't5.1.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 821).ate_indicator_value1);
        AddParam (
            't5.1.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 822).ate_indicator_value1);
        AddParam (
            't5.1.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 823).ate_indicator_value1);
        AddParam (
            't5.1.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 824).ate_indicator_value1);
        AddParam (
            't5.2.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 825).ate_indicator_value1); --2 Зовнішній вигляд
        AddParam (
            't5.2.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 826).ate_indicator_value1);
        AddParam (
            't5.2.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 827).ate_indicator_value1);
        AddParam (
            't5.2.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 828).ate_indicator_value1);
        AddParam (
            't5.2.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 829).ate_indicator_value1);
        AddParam (
            't5.3.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 830).ate_indicator_value1); --3 здоров’я
        AddParam (
            't5.3.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 831).ate_indicator_value1);
        AddParam (
            't5.3.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 832).ate_indicator_value1);
        AddParam (
            't5.3.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 833).ate_indicator_value1);
        AddParam (
            't5.3.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 834).ate_indicator_value1);
        AddParam (
            't5.4.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 835).ate_indicator_value1); --4 утримання помешкання
        AddParam (
            't5.4.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 836).ate_indicator_value1);
        AddParam (
            't5.4.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 837).ate_indicator_value1);
        AddParam (
            't5.4.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 838).ate_indicator_value1);
        AddParam (
            't5.4.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 839).ate_indicator_value1);
        AddParam (
            't5.5.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 840).ate_indicator_value1); --5 дотримання правил безпеки
        AddParam (
            't5.5.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 841).ate_indicator_value1);
        AddParam (
            't5.5.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 842).ate_indicator_value1);
        AddParam (
            't5.5.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 843).ate_indicator_value1);
        AddParam (
            't5.5.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 844).ate_indicator_value1);
        AddParam (
            't5.6.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 850).ate_indicator_value1); --6 знання ресурсів громади
        AddParam (
            't5.6.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 851).ate_indicator_value1);
        AddParam (
            't5.6.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 852).ate_indicator_value1);
        AddParam (
            't5.6.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 853).ate_indicator_value1);
        AddParam (
            't5.6.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 854).ate_indicator_value1);
        AddParam (
            't5.7.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 845).ate_indicator_value1); --7 міжособистісні відносини
        AddParam (
            't5.7.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 846).ate_indicator_value1);
        AddParam (
            't5.7.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 847).ate_indicator_value1);
        AddParam (
            't5.7.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 848).ate_indicator_value1);
        AddParam (
            't5.7.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 849).ate_indicator_value1);
        AddParam (
            't5.8.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 855).ate_indicator_value1); --8 обізнаність у юридичній сфері
        AddParam (
            't5.8.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 856).ate_indicator_value1);
        AddParam (
            't5.8.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 857).ate_indicator_value1);
        AddParam (
            't5.8.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 858).ate_indicator_value1);
        AddParam (
            't5.8.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 859).ate_indicator_value1);
        --9 Кількість балів по 8-ми категоріях
        AddParam ('t5.9.1', Get_Ftr_Nt (p_at_id, p_nda => 7911));
        AddParam ('t5.9.2', Get_Ftr_Nt (p_at_id, p_nda => 8206));
        AddParam ('t5.9.3', Get_Ftr_Nt (p_at_id, p_nda => 8207));
        AddParam ('t5.9.4', Get_Ftr_Nt (p_at_id, p_nda => 8208));
        AddParam ('t5.9.5', Get_Ftr_Nt (p_at_id, p_nda => 8209));

        AddParam (
            't5.10.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 860).ate_indicator_value1); --10 управління фінансами
        AddParam (
            't5.10.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 861).ate_indicator_value1);
        AddParam (
            't5.10.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 862).ate_indicator_value1);
        AddParam (
            't5.10.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 863).ate_indicator_value1);
        AddParam (
            't5.10.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 864).ate_indicator_value1);
        AddParam (
            't5.11.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 870).ate_indicator_value1); --11 користування транспортом
        AddParam (
            't5.11.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 871).ate_indicator_value1);
        AddParam (
            't5.11.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 872).ate_indicator_value1);
        AddParam (
            't5.11.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 873).ate_indicator_value1);
        AddParam (
            't5.11.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 874).ate_indicator_value1);
        AddParam (
            't5.12.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 875).ate_indicator_value1); --12 організація навчального процесу
        AddParam (
            't5.12.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 876).ate_indicator_value1);
        AddParam (
            't5.12.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 877).ate_indicator_value1);
        AddParam (
            't5.12.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 878).ate_indicator_value1);
        AddParam (
            't5.12.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 879).ate_indicator_value1);
        AddParam (
            't5.13.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 880).ate_indicator_value1); --13 навички пошуку роботи
        AddParam (
            't5.13.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 881).ate_indicator_value1);
        AddParam (
            't5.13.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 882).ate_indicator_value1);
        AddParam (
            't5.13.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 883).ate_indicator_value1);
        AddParam (
            't5.13.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 884).ate_indicator_value1);
        AddParam (
            't5.14.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 885).ate_indicator_value1); --14 організація роботи (зайнятості)
        AddParam (
            't5.14.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 886).ate_indicator_value1);
        AddParam (
            't5.14.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 887).ate_indicator_value1);
        AddParam (
            't5.14.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 888).ate_indicator_value1);
        AddParam (
            't5.14.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 889).ate_indicator_value1);
        AddParam (
            't5.15.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 865).ate_indicator_value1); --15 обізнаність у сфері нерухомості
        AddParam (
            't5.15.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 866).ate_indicator_value1);
        AddParam (
            't5.15.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 867).ate_indicator_value1);
        AddParam (
            't5.15.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 868).ate_indicator_value1);
        AddParam (
            't5.15.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 869).ate_indicator_value1);
        --Кількість балів по 6-и категоріях
        AddParam ('t5.16.1', Get_Ftr_Nt (p_at_id, p_nda => 7918));
        AddParam ('t5.16.2', Get_Ftr_Nt (p_at_id, p_nda => 8210));
        AddParam ('t5.16.3', Get_Ftr_Nt (p_at_id, p_nda => 8211));
        AddParam ('t5.16.4', Get_Ftr_Nt (p_at_id, p_nda => 8212));
        AddParam ('t5.16.5', Get_Ftr_Nt (p_at_id, p_nda => 8213));

        --Загальна кількість балів nng_id=622
        AddParam ('t5.1.6', Get_Ftr_Nt (p_at_id, p_nda => 7903));
        AddParam ('t5.2.6', Get_Ftr_Nt (p_at_id, p_nda => 7904));
        AddParam ('t5.3.6', Get_Ftr_Nt (p_at_id, p_nda => 7905));
        AddParam ('t5.4.6', Get_Ftr_Nt (p_at_id, p_nda => 7906));
        AddParam ('t5.5.6', Get_Ftr_Nt (p_at_id, p_nda => 7907));
        AddParam ('t5.6.6', Get_Ftr_Nt (p_at_id, p_nda => 7908));
        AddParam ('t5.7.6', Get_Ftr_Nt (p_at_id, p_nda => 7909));
        AddParam ('t5.8.6', Get_Ftr_Nt (p_at_id, p_nda => 7910));
        AddParam ('t5.9.6', Get_Ftr_Nt (p_at_id, p_nda => 8214));
        AddParam ('t5.10.6', Get_Ftr_Nt (p_at_id, p_nda => 7912));
        AddParam ('t5.11.6', Get_Ftr_Nt (p_at_id, p_nda => 7913));
        AddParam ('t5.12.6', Get_Ftr_Nt (p_at_id, p_nda => 7914));
        AddParam ('t5.13.6', Get_Ftr_Nt (p_at_id, p_nda => 7915));
        AddParam ('t5.14.6', Get_Ftr_Nt (p_at_id, p_nda => 7916));
        AddParam ('t5.15.6', Get_Ftr_Nt (p_at_id, p_nda => 7917));
        AddParam ('t5.16.6', Get_Ftr_Nt (p_at_id, p_nda => 8215));

        --Висновок.
        AddParam ('v1', GetScPIB (c.at_sc));    --Отримувач соціальної послуги
        AddParam (
            'v2',
            NVL (
                Api$Act_Rpt.v_ddn (
                    'uss_ndi.V_DDN_SS_LEVEL_HAS_SKL',
                    Api$Act_Rpt.Get_Ftr (p_at_id, p_nda => 7919)),
                '______'));                                         --на рівні
        AddParam (
            'v3',
            NVL (
                TO_CHAR (
                    Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 900).ate_indicator_value1),
                '______'));                                     --усього балів
        AddParam (
            'v4',
            NVL (
                TO_CHAR (
                    Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 900).ate_indicator_value2),
                '______'));                           --відвідувань на тиждень

        --Особи, які брали участь в оцінюванні
        l_str := q'[
    select p.pib                  as c1,
           p.Relation_Tp          as c2,
           null                   as c3
      from table(uss_esr.Api$Act_Rpt.At_Person_for_act(:p_at_id)) p
     where 1=1
       and p.atp_app_tp not in ('OS', 'AP')
    ]';
        l_str :=
            REGEXP_REPLACE (l_str,
                            ':p_at_id',
                            p_at_id,
                            1,
                            0,
                            'i');
        l_str :=
            REGEXP_REPLACE (
                l_str,
                'null',
                CHR (39) || TO_CHAR (c.at_dt, 'dd.mm.yyyy') || CHR (39),
                1,
                0,
                'i');
        rdm$rtfl_univ.AddDataset ('ds.v', l_str);

        AddParam ('sgn1',
                  p2.atop_ln || ' ' || p2.atop_fn || ' ' || p2.atop_mn); --Api$Act_Rpt.GetCuPIB(c.at_cu)); --Особа, яка провела оцінювання
        AddParam ('sgn2', TO_CHAR (c.at_dt, 'dd.mm.yyyy'));

        --Таблиця 6 Анкета для визначення рейтингу соціальних потреб отримувача соціальної послуги догляду вдома
        AddParam ('a1', p1.pib);                                   --отримувач
        AddParam ('a2', p1.birth_dt_str);
        AddParam ('a3', p1.live_address);
        AddParam ('a4', p2.atop_ln || ' ' || p2.atop_fn || ' ' || p2.atop_mn); --ПІБ фахівця
        AddParam ('a5', TO_CHAR (c.at_dt, 'dd.mm.yyyy'));    --Дата опитування
        --

        AddFtrAnk ('a.1.1', p1.atp_id, 7823);
        AddFtrAnk2 ('a.1.2', p2.atop_id, 7823);
        AddFtrAnk ('a.1.3', p3.atp_id, 7823);                --ЖИТЛО/ДОКУМЕНТИ
        AddFtrAnk ('a.2.1', p1.atp_id, 7824);
        AddFtrAnk2 ('a.2.2', p2.atop_id, 7824);
        AddFtrAnk ('a.2.3', p3.atp_id, 7824);
        AddFtrAnk ('a.3.1', p1.atp_id, 7825);
        AddFtrAnk2 ('a.3.2', p2.atop_id, 7825);
        AddFtrAnk ('a.3.3', p3.atp_id, 7825);
        AddFtrAnk ('a.4.1', p1.atp_id, 7826);
        AddFtrAnk2 ('a.4.2', p2.atop_id, 7826);
        AddFtrAnk ('a.4.3', p3.atp_id, 7826);
        AddFtrAnk ('a.5.1', p1.atp_id, 7827);
        AddFtrAnk2 ('a.5.2', p2.atop_id, 7827);
        AddFtrAnk ('a.5.3', p3.atp_id, 7827);
        AddFtrAnk ('a.6.1', p1.atp_id, 7828);
        AddFtrAnk2 ('a.6.2', p2.atop_id, 7828);
        AddFtrAnk ('a.6.3', p3.atp_id, 7828);
        AddFtrAnk ('a.7.1', p1.atp_id, 7829);
        AddFtrAnk2 ('a.7.2', p2.atop_id, 7829);
        AddFtrAnk ('a.7.3', p3.atp_id, 7829); --НАВИЧКИ САМОСТІЙНОГО ПРОЖИВАННЯ
        AddFtrAnk ('a.8.1', p1.atp_id, 7830);
        AddFtrAnk2 ('a.8.2', p2.atop_id, 7830);
        AddFtrAnk ('a.8.3', p3.atp_id, 7830);
        AddFtrAnk ('a.9.1', p1.atp_id, 7831);
        AddFtrAnk2 ('a.9.2', p2.atop_id, 7831);
        AddFtrAnk ('a.9.3', p3.atp_id, 7831);
        AddFtrAnk ('a.10.1', p1.atp_id, 7832);
        AddFtrAnk2 ('a.10.2', p2.atop_id, 7832);
        AddFtrAnk ('a.10.3', p3.atp_id, 7832);
        AddFtrAnk ('a.11.1', p1.atp_id, 7833);
        AddFtrAnk2 ('a.11.2', p2.atop_id, 7833);
        AddFtrAnk ('a.11.3', p3.atp_id, 7833);
        AddFtrAnk ('a.12.1', p1.atp_id, 7834);
        AddFtrAnk2 ('a.12.2', p2.atop_id, 7834);
        AddFtrAnk ('a.12.3', p3.atp_id, 7834);
        AddFtrAnk ('a.13.1', p1.atp_id, 7835);
        AddFtrAnk2 ('a.13.2', p2.atop_id, 7835);
        AddFtrAnk ('a.13.3', p3.atp_id, 7835);                --СФЕРА ЗДОРОВ’Я
        AddFtrAnk ('a.14.1', p1.atp_id, 7836);
        AddFtrAnk2 ('a.14.2', p2.atop_id, 7836);
        AddFtrAnk ('a.14.3', p3.atp_id, 7836);
        AddFtrAnk ('a.15.1', p1.atp_id, 7837);
        AddFtrAnk2 ('a.15.2', p2.atop_id, 7837);
        AddFtrAnk ('a.15.3', p3.atp_id, 7837);
        AddFtrAnk ('a.16.1', p1.atp_id, 7838);
        AddFtrAnk2 ('a.16.2', p2.atop_id, 7838);
        AddFtrAnk ('a.16.3', p3.atp_id, 7838);
        AddFtrAnk ('a.17.1', p1.atp_id, 7839);
        AddFtrAnk2 ('a.17.2', p2.atop_id, 7839);
        AddFtrAnk ('a.17.3', p3.atp_id, 7839);
        AddFtrAnk ('a.18.1', p1.atp_id, 7840);
        AddFtrAnk2 ('a.18.2', p2.atop_id, 7840);
        AddFtrAnk ('a.18.3', p3.atp_id, 7840);
        AddFtrAnk ('a.19.1', p1.atp_id, 7841);
        AddFtrAnk2 ('a.19.2', p2.atop_id, 7841);
        AddFtrAnk ('a.19.3', p3.atp_id, 7841);               --СОЦІАЛЬНА СФЕРА
        AddFtrAnk ('a.20.1', p1.atp_id, 7842);
        AddFtrAnk2 ('a.20.2', p2.atop_id, 7842);
        AddFtrAnk ('a.20.3', p3.atp_id, 7842);
        AddFtrAnk ('a.21.1', p1.atp_id, 7843);
        AddFtrAnk2 ('a.21.2', p2.atop_id, 7843);
        AddFtrAnk ('a.21.3', p3.atp_id, 7843);
        AddFtrAnk ('a.22.1', p1.atp_id, 7844);
        AddFtrAnk2 ('a.22.2', p2.atop_id, 7844);
        AddFtrAnk ('a.22.3', p3.atp_id, 7844);
        AddFtrAnk ('a.23.1', p1.atp_id, 7845);
        AddFtrAnk2 ('a.23.2', p2.atop_id, 7845);
        AddFtrAnk ('a.23.3', p3.atp_id, 7845);
        AddFtrAnk ('a.24.1', p1.atp_id, 7846);
        AddFtrAnk2 ('a.24.2', p2.atop_id, 7846);
        AddFtrAnk ('a.24.3', p3.atp_id, 7846);
        --Загальна сума балів за сферами
        AddParam (
            'itg1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 890).ate_indicator_value1); --Житло/документи
        AddParam (
            'itg2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 891).ate_indicator_value1); --Навички самостійного проживання
        AddParam (
            'itg3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 892).ate_indicator_value1); --Здоров’я
        AddParam (
            'itg4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 893).ate_indicator_value1); --Соціальна сфера

        AddParam ('itg1', Get_Ftr_Nt (p_at_id, p_nda => 8533));
        AddParam ('itg2', Get_Ftr_Nt (p_at_id, p_nda => 8536));
        AddParam ('itg3', Get_Ftr_Nt (p_at_id, p_nda => 8535));
        AddParam ('itg4', Get_Ftr_Nt (p_at_id, p_nda => 8534));

        --Таблиця 7 ОЦІНЮВАННЯ індивідуальних потреб отримувача
        AddParam ('t7-1', TO_CHAR (SYSDATE                         /*c.at_dt*/
                                          , 'dd.mm.yyyy'));  --Дата опитування
        AddParam ('t7-2', p1.pib);                                 --отримувач

        AddChkT7 ('t7.1.1.1,t7.1.2.1,t7.1.3.1,t7.1.4.1,t7.1.5.1', 7847);
        AddChkT7 ('t7.1.1.2,t7.1.2.2,t7.1.3.2,t7.1.4.2,t7.1.5.2', 7848);
        AddChkT7 ('t7.1.1.3,t7.1.2.3,t7.1.3.3,t7.1.4.3,t7.1.5.3', 7849);
        AddChkT7 ('t7.1.1.4,t7.1.2.4,t7.1.3.4,t7.1.4.4,t7.1.5.4', 7850);
        AddChkT7 ('t7.1.1.5,t7.1.2.5,t7.1.3.5,t7.1.4.5,t7.1.5.5', 7851);
        AddChkT7 ('t7.1.1.6,t7.1.2.6,t7.1.3.6,t7.1.4.6,t7.1.5.6', 7852);
        AddChkT7 ('t7.1.1.7,t7.1.2.7,t7.1.3.7,t7.1.4.7,t7.1.5.7', 7853);
        AddChkT7 ('t7.1.1.8,t7.1.2.8,t7.1.3.8,t7.1.4.8,t7.1.5.8', 7854);
        AddChkT7 ('t7.1.1.9,t7.1.2.9,t7.1.3.9,t7.1.4.9,t7.1.5.9', 7855);
        AddChkT7 ('t7.1.1.10,t7.1.2.10,t7.1.3.10,t7.1.4.10,t7.1.5.10', 7856);
        AddChkT7 ('t7.1.1.11,t7.1.2.11,t7.1.3.11,t7.1.4.11,t7.1.5.11', 7857);
        AddChkT7 ('t7.2.1.1,t7.2.2.1,t7.2.3.1,t7.2.4.1,t7.2.5.1', 7858);    --
        AddChkT7 ('t7.2.1.2,t7.2.2.2,t7.2.3.2,t7.2.4.2,t7.2.5.2', 7859);
        AddChkT7 ('t7.2.1.3,t7.2.2.3,t7.2.3.3,t7.2.4.3,t7.2.5.3', 7860);
        AddChkT7 ('t7.2.1.4,t7.2.2.4,t7.2.3.4,t7.2.4.4,t7.2.5.4', 7861);
        AddChkT7 ('t7.2.1.5,t7.2.2.5,t7.2.3.5,t7.2.4.5,t7.2.5.5', 7862);
        AddChkT7 ('t7.2.1.6,t7.2.2.6,t7.2.3.6,t7.2.4.6,t7.2.5.6', 7863);
        AddChkT7 ('t7.2.1.7,t7.2.2.7,t7.2.3.7,t7.2.4.7,t7.2.5.7', 7864);
        AddChkT7 ('t7.2.1.8,t7.2.2.8,t7.2.3.8,t7.2.4.8,t7.2.5.8', 7865);
        AddChkT7 ('t7.2.1.9,t7.2.2.9,t7.2.3.9,t7.2.4.9,t7.2.5.9', 7866);
        AddChkT7 ('t7.2.1.10,t7.2.2.10,t7.2.3.10,t7.2.4.10,t7.2.5.10', 7867);
        AddChkT7 ('t7.2.1.11,t7.2.2.11,t7.2.3.11,t7.2.4.11,t7.2.5.11', 7868);
        AddChkT7 ('t7.3.1.1,t7.3.2.1,t7.3.3.1,t7.3.4.1,t7.3.5.1', 7869);    --
        AddChkT7 ('t7.3.1.2,t7.3.2.2,t7.3.3.2,t7.3.4.2,t7.3.5.2', 7870);
        AddChkT7 ('t7.3.1.3,t7.3.2.3,t7.3.3.3,t7.3.4.3,t7.3.5.3', 7871);
        AddChkT7 ('t7.3.1.4,t7.3.2.4,t7.3.3.4,t7.3.4.4,t7.3.5.4', 7872);
        AddChkT7 ('t7.3.1.5,t7.3.2.5,t7.3.3.5,t7.3.4.5,t7.3.5.5', 7873);
        AddChkT7 ('t7.3.1.6,t7.3.2.6,t7.3.3.6,t7.3.4.6,t7.3.5.6', 7874);
        AddChkT7 ('t7.3.1.7,t7.3.2.7,t7.3.3.7,t7.3.4.7,t7.3.5.7', 7875);
        AddChkT7 ('t7.3.1.8,t7.3.2.8,t7.3.3.8,t7.3.4.8,t7.3.5.8', 7876);
        AddChkT7 ('t7.3.1.9,t7.3.2.9,t7.3.3.9,t7.3.4.9,t7.3.5.9', 7877);
        AddChkT7 ('t7.3.1.10,t7.3.2.10,t7.3.3.10,t7.3.4.10,t7.3.5.10', 7878);
        AddChkT7 ('t7.3.1.11,t7.3.2.11,t7.3.3.11,t7.3.4.11,t7.3.5.11', 7879);
        AddChkT7 ('t7.4.1.1,t7.4.2.1,t7.4.3.1,t7.4.4.1,t7.4.5.1', 7880);    --
        AddChkT7 ('t7.4.1.2,t7.4.2.2,t7.4.3.2,t7.4.4.2,t7.4.5.2', 7881);
        AddChkT7 ('t7.4.1.3,t7.4.2.3,t7.4.3.3,t7.4.4.3,t7.4.5.3', 7882);
        AddChkT7 ('t7.4.1.4,t7.4.2.4,t7.4.3.4,t7.4.4.4,t7.4.5.4', 7883);
        AddChkT7 ('t7.4.1.5,t7.4.2.5,t7.4.3.5,t7.4.4.5,t7.4.5.5', 7884);
        AddChkT7 ('t7.4.1.6,t7.4.2.6,t7.4.3.6,t7.4.4.6,t7.4.5.6', 7885);
        AddChkT7 ('t7.4.1.7,t7.4.2.7,t7.4.3.7,t7.4.4.7,t7.4.5.7', 7886);
        AddChkT7 ('t7.4.1.8,t7.4.2.8,t7.4.3.8,t7.4.4.8,t7.4.5.8', 7887);
        AddChkT7 ('t7.4.1.9,t7.4.2.9,t7.4.3.9,t7.4.4.9,t7.4.5.9', 7888);
        AddChkT7 ('t7.4.1.10,t7.4.2.10,t7.4.3.10,t7.4.4.10,t7.4.5.10', 7889);
        AddChkT7 ('t7.4.1.11,t7.4.2.11,t7.4.3.11,t7.4.4.11,t7.4.5.11', 7890);
        AddChkT7 ('t7.5.1.1,t7.5.2.1,t7.5.3.1,t7.5.4.1,t7.5.5.1', 7891);    --
        AddChkT7 ('t7.5.1.2,t7.5.2.2,t7.5.3.2,t7.5.4.2,t7.5.5.2', 7892);
        AddChkT7 ('t7.5.1.3,t7.5.2.3,t7.5.3.3,t7.5.4.3,t7.5.5.3', 7893);
        AddChkT7 ('t7.5.1.4,t7.5.2.4,t7.5.3.4,t7.5.4.4,t7.5.5.4', 7894);
        AddChkT7 ('t7.5.1.5,t7.5.2.5,t7.5.3.5,t7.5.4.5,t7.5.5.5', 7895);
        AddChkT7 ('t7.5.1.6,t7.5.2.6,t7.5.3.6,t7.5.4.6,t7.5.5.6', 7896);
        AddChkT7 ('t7.5.1.7,t7.5.2.7,t7.5.3.7,t7.5.4.7,t7.5.5.7', 7897);
        AddChkT7 ('t7.5.1.8,t7.5.2.8,t7.5.3.8,t7.5.4.8,t7.5.5.8', 7898);
        AddChkT7 ('t7.5.1.9,t7.5.2.9,t7.5.3.9,t7.5.4.9,t7.5.5.9', 7899);
        AddChkT7 ('t7.5.1.10,t7.5.2.10,t7.5.3.10,t7.5.4.10,t7.5.5.10', 7900);
        AddChkT7 ('t7.5.1.11,t7.5.2.11,t7.5.3.11,t7.5.4.11,t7.5.5.11', 7901);

        --РАЗОМ ПО ГРУПІ...
        AddParam (
            't7.1',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 895).ate_indicator_value1);
        AddParam (
            't7.2',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 896).ate_indicator_value1);
        AddParam (
            't7.3',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 897).ate_indicator_value1);
        AddParam (
            't7.4',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 898).ate_indicator_value1);
        AddParam (
            't7.5',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 899).ate_indicator_value1);
        --ВСЬОГО #t7# балів
        AddParam (
            't7',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 899).ate_indicator_value2);

        --Висновок
        AddParam ('t7-v1', p1.pib);                                --отримувач

        AddParam (
            'tv-1-1',
            NVL (
                AddCnkWithNumber (
                    Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 947).ate_indicator_value1,
                    0,
                    11),
                AddCnkWithNumber (
                    Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 947).ate_indicator_value1,
                    169,
                    10000)));

        AddParam (
            'tv-2-1',
            AddCnkWithNumber (
                Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 947).ate_indicator_value1,
                12,
                50));
        AddParam (
            'tv-2-2',
            AddCnkWithNumber (
                Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 947).ate_indicator_value1,
                51,
                100));
        AddParam (
            'tv-2-3',
            AddCnkWithNumber (
                Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 947).ate_indicator_value1,
                101,
                168));

        AddParam (
            'tv-4-1',
            AddCnkWithNumber (
                Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 947).ate_indicator_value1,
                12,
                50,
                'ID',
                p_at_id));
        AddParam (
            'tv-4-2',
            AddCnkWithNumber (
                Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 947).ate_indicator_value1,
                51,
                100,
                'ID',
                p_at_id));
        AddParam (
            'tv-4-3',
            AddCnkWithNumber (
                Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 947).ate_indicator_value1,
                101,
                168,
                'ID',
                p_at_id));

        AddParam (
            'tv-5-1',
            AddCnkWithNumber (
                Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 947).ate_indicator_value1,
                12,
                50,
                'PD',
                p_at_id));
        AddParam (
            'tv-5-2',
            AddCnkWithNumber (
                Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 947).ate_indicator_value1,
                51,
                100,
                'PD',
                p_at_id));
        AddParam (
            'tv-5-3',
            AddCnkWithNumber (
                Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 947).ate_indicator_value1,
                101,
                168,
                'PD',
                p_at_id));

        AddParam (
            'tv-6-1',
            AddCnkWithNumber (
                Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 947).ate_indicator_value1,
                12,
                50,
                'PRD',
                p_at_id));
        AddParam (
            'tv-6-2',
            AddCnkWithNumber (
                Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 947).ate_indicator_value1,
                51,
                100,
                'PRD',
                p_at_id));
        AddParam (
            'tv-6-3',
            AddCnkWithNumber (
                Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 947).ate_indicator_value1,
                101,
                168,
                'PRD',
                p_at_id));

        AddParam (
            't7',
            Api$Act_Rpt.GetAtSection (p_at_id, p_nng => 947).ate_indicator_value1);

        --Підпис
        AddParam ('t7-sign1', c.cu_pib /*p2.atop_ln||' '||p2.atop_fn||' '||p2.atop_mn*/
                                      );                         --ПІБ фахівця
        AddParam ('t7-sign3', p3.pib);                  --Законний представник
        AddParam (
            'sgn_1',
            api$act_rpt.get_sign_mark (p_at_id, p3.Atp_Id, '____________'));

        ------------------------------------
        rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                         p_rpt_blob   => l_result);
        replace_ekr (l_result);

        RETURN l_result;
    END ACT_DOC_1013_R1;
BEGIN
    NULL;
END Api$Act_RptAdd;
/