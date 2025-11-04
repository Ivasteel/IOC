/* Formatted on 8/12/2025 5:48:28 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.DNET$SC_JOURNAL_RPT
IS
    -- Author  : PAVLO
    -- Created : 27.10.2023 14:55:18
    -- Purpose : друковані форми

    --#93592 Форма друку Картки 1005 (СОЦІАЛЬНА КАРТКА СІМ’Ї/ОСОБИ)
    FUNCTION SOCIAL_CARD_1005 (p_nsj_id IN nsp_sc_journal.nsj_id%TYPE)
        RETURN BLOB;

    -- info:   Ініціалізація процесу підготовки друкованої форми
    -- params: p_rt_id - ідентифікатор шаблону
    --         p_pd_id - ідентифікатор рішення
    -- note:   #93592
    PROCEDURE REG_REPORT (p_rt_id    IN     NUMBER,
                          p_nsj_id   IN     NUMBER,
                          p_jbr_id      OUT NUMBER);
END Dnet$Sc_Journal_Rpt;
/


/* Formatted on 8/12/2025 5:49:56 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.DNET$SC_JOURNAL_RPT
IS
    c_ekr1    CONSTANT VARCHAR2 (10) := '[' || CHR (1) || ']';           --"\"
    c_ekr2    CONSTANT VARCHAR2 (10) := '[' || CHR (2) || ']';           --"{"
    c_ekr3    CONSTANT VARCHAR2 (10) := '[' || CHR (3) || ']';           --"}"

    --галочка
    c_check   CONSTANT VARCHAR2 (900)
        := '{\rtlch\fcs1 \af0 \ltrch\fcs0 \lang1033\langfe1033\langnp1033\insrsid16478594 {\field{\*\fldinst SYMBOL 80 \\f "Wingdings 2" \\s 11}{\fldrslt\f157\fs22}}}' ;
    --прямокутник з галочкой
    c_chk     CONSTANT VARCHAR2 (900)
        := '{\field{\*\fldinst SYMBOL 82 \\f "Wingdings 2" \\s 12}}' ; --шрифт "Wingdings 2"
    --q'[{\rtlch\fcs1 \af0\afs24 \ltrch\fcs0 \f50\fs24\lang1033\langfe1058\langnp1033\insrsid7754010\charrsid8275394 \u9745\'3f}]'; --шрифт "Segoe UI Symbol" 12розмір

    --прямокутник без галочки
    c_unchk   CONSTANT VARCHAR2 (900)
        := --'{\field{\*\fldinst SYMBOL 48 \\f "Wingdings 2" \\s 12}}';  --прямокутник, трохи схожй не квадрат шрифт "Wingdings 2"
           q'[{\rtlch\fcs1 \af0\afs24 \ltrch\fcs0 \f50\fs24\lang1033\langfe1058\langnp1033\insrsid7754010\charrsid8275394 \u9744\'3f}]' ; --шрифт "Segoe UI Symbol" 12розмір


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

    PROCEDURE AddParam (p_Param_Name VARCHAR2, p_Param_Value VARCHAR2)
    IS
    BEGIN
        rdm$rtfl_univ.addparam (p_Param_Name    => p_Param_Name,
                                p_Param_Value   => org2ekr (p_Param_Value));
    END;

    --заміна c_ekr1/c_ekr2/c_ekr3 на оригінальні символи
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

    --квадратик з галочкой
    FUNCTION chk_val (p_chk_val VARCHAR2, p_val VARCHAR2)
        RETURN VARCHAR2
    IS
    BEGIN
        IF p_chk_val = p_val
        THEN
            RETURN org2ekr (c_chk);
        ELSE
            RETURN org2ekr (c_unchk);
        END IF;
    END;


    -- info:   Отримання коду шаблону по ідентифікатору
    -- params: p_rt_id - ідентифікатор шаблону
    -- note:
    FUNCTION get_rpt_code (p_rt_id IN rpt_templates.rt_id%TYPE)
        RETURN VARCHAR2
    IS
        v_rt_code   rpt_templates.rt_code%TYPE;
    BEGIN
        SELECT rt_code
          INTO v_rt_code
          FROM v_rpt_templates
         WHERE rt_id = p_rt_id;

        RETURN v_rt_code;
    END;


    --#93592 Форма друку Картки 1005 (СОЦІАЛЬНА КАРТКА СІМ’Ї/ОСОБИ)
    PROCEDURE Social_Card_1005 (p_nsj_id   IN     nsp_sc_journal.nsj_id%TYPE,
                                p_Bld_Tp   IN     VARCHAR2, --тип звіту (rdm$rtfl_univ.c_Bld_Tp_Svc/rdm$rtfl_univ.c_Bld_Tp_Db)
                                p_jbr_id      OUT NUMBER,
                                p_blob        OUT BLOB)
    IS
        CURSOR cj IS
            SELECT sc.sc_unique,
                   p.njp_ln || ' ' || p.njp_fn || ' ' || p.njp_mn
                       pib,
                   j.nsj_num,
                   --j.nsj_address
                   NVL (
                       uss_person.api$sc_tools.get_full_address_text (
                           j.nsj_sc,
                           '2'),
                       uss_person.api$sc_tools.get_full_address_text (
                           j.nsj_sc,
                           '4'))
                       AS address,
                   --j.nsj_phone
                   uss_person.api$sc_tools.get_phone_mob (j.nsj_sc)
                       AS phone,
                   j.nsj_start_dt,
                   j.nsj_start_reason,
                   j.nsj_stop_dt,
                   j.nsj_stop_reason,
                   j.nsj_case_class
              FROM uss_esr.nsp_sc_journal   j,
                   uss_person.v_socialcard  sc,
                   uss_esr.nsj_persons      p
             WHERE     1 = 1
                   AND j.nsj_id = p_nsj_id
                   AND sc.sc_id = j.nsj_sc
                   AND sc.sc_id = p.njp_sc
                   AND p.njp_nsj = j.nsj_id
                   AND p.history_status = 'A';

        c       cj%ROWTYPE;

        l_str   VARCHAR2 (32000);
    BEGIN
        rdm$rtfl_univ.initreport (p_code     => 'SOCIAL_CARD_1005',
                                  p_bld_tp   => p_Bld_Tp);

        --------------------------------------------------------

        OPEN cj;

        FETCH cj INTO c;

        CLOSE cj;

        AddParam ('p01', c.nsj_num);
        AddParam ('p02', c.pib);
        AddParam ('p03', c.address);
        AddParam ('p04', c.phone);
        AddParam (
            'p05',
            NVL (uss_esr.Api$Act_Rpt.Date2Str (c.nsj_start_dt),
                 '____  _______________ 20___'));
        AddParam ('p06', c.nsj_start_reason);
        AddParam (
            'p07',
            NVL (uss_esr.Api$Act_Rpt.Date2Str (c.nsj_stop_dt),
                 '____  _______________ 20___'));
        AddParam ('p08', c.nsj_stop_reason);

        --1. Відомості про фахівців, відповідальних за організацію роботи із сім’єю/особою
        l_str := q'[
    select row_number() over (order by ex.nje_id) c1,
           to_char(ex.nje_start_dt, 'dd.mm.yyyy') c2,
           ex.nje_ln||' '||ex.nje_fn||' '||ex.nje_mn c3,
           ex.nje_phone||nvl2(ex.nje_email, ' '||ex.nje_email, null) c4,
           to_char(ex.nje_stop_dt, 'dd.mm.yyyy') c5,
           ex.nje_notes c6
      from
           uss_esr.v_nsp_sc_journal j,
           uss_esr.v_nsj_experts ex
     where 1=1
       and j.nsj_id = :p_nsj_id
       and ex.nje_nsj = j.nsj_id
       and ex.history_status = 'A'
  ]';
        l_str := REPLACE (l_str, ':p_nsj_id', p_nsj_id);
        rdm$rtfl_univ.AddDataset ('ds1', l_str);

        --2. Відомості про суб’єктів соціальної роботи, які працюють із сім’єю/особою (надають соціальні послуги)
        l_str :=
            q'[
    select row_number() over (order by s.njs_id) c1,
           to_char(s.njs_dt, 'dd.mm.yyyy') c2,
           s.njs_name  c3,
           s.njs_spec_ln||' '||s.njs_spec_fn||' '||s.njs_spec_mn c4,
           s.njs_spec_phone ||nvl2(s.njs_spec_email, ' '||s.njs_spec_email, null) c5,
           s.njs_purpose c6,
           s.NJS_ISSUED_DOCS as c7,
           s.NJS_NOTES c8
      from
           uss_esr.v_nsp_sc_journal j,
           uss_esr.v_nsj_subjects s
     where 1=1
       and j.nsj_id = :p_nsj_id
       and s.njs_nsj = j.nsj_id
       and s.history_status = 'A'
  ]';
        l_str := REPLACE (l_str, ':p_nsj_id', p_nsj_id);
        rdm$rtfl_univ.AddDataset ('ds2', l_str);

        --3. Відомості про членів сім’ї/особу
        --умови відбору: uss_ndi.v_ddn_njp_tp = 'FM'
        l_str :=
            q'[
    select to_char(p.njp_dt, 'dd.mm.yyyy')          as c1,
           p.njp_ln||' '||p.njp_fn||' '||p.njp_mn   as c2,
           decode(p.njp_gender, 'F', 'Ж', 'M', 'Ч') as c3,
           to_char(p.njp_birth_dt, 'dd.mm.yyyy')    as c4,
           rtp.dic_name                             as c5,
           decode(p.njp_is_disabled, 'T', 'наявна', 'відсутня') as c6, --інвалід
           decode(p.njp_is_capable, 'T', 'дієздатний(а)', 'недієздатний(а)') as c7,
           p.njp_work_place   as c8,
           p.njp_phone        as c9,
           p.njp_reg_address  as c10,
           p.njp_fact_address as c11,
           to_char(p.NJP_NOTES_DT, 'dd.mm.yyyy') as c12,
           p.njp_notes        as c13

      from
           uss_esr.v_nsp_sc_journal j,
           uss_esr.v_nsj_persons p,
           uss_ndi.v_ddn_relation_tp rtp,
           uss_esr.v_histsession hs
     where 1=1
       and j.nsj_id = :p_nsj_id
       and p.njp_nsj = j.nsj_id
       and p.history_status = 'A'
       and p.njp_tp = 'FM'
       --AND p.njp_relation_tp IN ('Z','HW','P','B','ACH','SU','BC','SP','GUARD','CHRG','OTHER')
       and rtp.dic_value = p.njp_relation_tp
       and hs.hs_id(+)= p.njp_hs_upd
     order by p.njp_id
  ]';
        l_str := REPLACE (l_str, ':p_nsj_id', p_nsj_id);
        rdm$rtfl_univ.AddDataset ('ds3', l_str);

        --4. Відомості про інших осіб, які проживають разом із сім’єю
        --умови відбору: uss_ndi.v_ddn_njp_tp = 'I'
        l_str :=
            q'[
    select to_char(p.njp_dt, 'dd.mm.yyyy')          as c1,
           p.njp_ln||' '||p.njp_fn||' '||p.njp_mn   as c2,
           round(months_between(sysdate, p.njp_birth_dt)/12) as c3,
           rtp.dic_name                             as c4,
           decode(p.njp_is_disabled, 'T', 'наявна', 'відсутня') as c5, --інвалід
           decode(p.njp_is_capable, 'T', 'дієздатний(а)', 'недієздатний(а)') as c6,
           p.njp_work_place   as c7,
           p.njp_phone        as c8,
           p.njp_reg_address  as c9,
           p.njp_fact_address as c10,
           to_char(p.NJP_NOTES_DT, 'dd.mm.yyyy') as c11,
           p.njp_notes        as c12
      from
           uss_esr.v_nsp_sc_journal j,
           uss_esr.v_nsj_persons p,
           uss_ndi.v_ddn_relation_tp rtp,
           uss_esr.v_histsession hs
     where 1=1
       and j.nsj_id = :p_nsj_id
       and p.njp_nsj = j.nsj_id
       and p.history_status = 'A'
       and p.njp_tp = 'I'
       --AND p.njp_relation_tp NOT IN ('Z','HW','P','B','ACH','SU','BC','SP','GUARD','CHRG','OTHER')
       and rtp.dic_value = p.njp_relation_tp
       and hs.hs_id(+)= p.njp_hs_upd
     order by p.njp_id
  ]';
        l_str := REPLACE (l_str, ':p_nsj_id', p_nsj_id);
        rdm$rtfl_univ.AddDataset ('ds4', l_str);

        --5. Основні ознаки та чинники функціонування сім’ї/особи
        l_str :=
            q'[
    select to_char(f.njf_dt, 'dd.mm.yyyy')  as c1,
           listagg(decode(nff.nff_tp, 'OO', nff.nff_name), ', ') within group(order by nff.nff_name) as c2,
           listagg(decode(nff.nff_tp, 'DD', nff.nff_name), ', ') within group(order by nff.nff_name) as c3,
           listagg(decode(nff.nff_tp, 'GU', nff.nff_name), ', ') within group(order by nff.nff_name) as c4,
           listagg(decode(nff.nff_tp, 'NZ', nff.nff_name), ', ') within group(order by nff.nff_name) as c5
      from
           uss_esr.v_nsp_sc_journal j,
           uss_esr.v_nsj_features f,
           uss_esr.v_nsj_feature_data fd,
           uss_ndi.v_ndi_family_features nff
           --uss_ndi.v_ddn_nff_tp nff_tp

     where 1=1
       and j.nsj_id = :p_nsj_id
       and f.njf_nsj = j.nsj_id and f.history_status = 'A'
       and fd.njfd_njf = f.njf_id and fd.history_status = 'A'

       and nff.nff_id = fd.njfd_nff
       --and nff_tp.dic_value = nff.nff_tp
     group by f.njf_dt
     order by f.njf_dt
  ]';
        l_str := REPLACE (l_str, ':p_nsj_id', p_nsj_id);
        rdm$rtfl_univ.AddDataset ('ds5', l_str);

        --6. Класифікація випадку Uss_Ndi.v_Ddn_Case_Class
        addparam ('p6-1', chk_val ('SM', c.nsj_case_class));
        addparam ('p6-2', chk_val ('MD', c.nsj_case_class));
        addparam ('p6-3', chk_val ('DF', c.nsj_case_class));
        addparam ('p6-4', chk_val ('EM', c.nsj_case_class));

        --8. Облік надання послуг
        l_str := q'[
    select row_number() over (order by a.nja_id)      as c1,
           a.nja_stage as c2,
           to_char(a.nja_start_dt, 'dd.mm.yyyy') as c3,
           to_char(a.nja_stop_dt,  'dd.mm.yyyy') as c4,
           a.nja_fact  as c5,
           a.nja_involved_persons as c6,
           ex.nje_ln||' '||ex.nje_fn||' '||ex.nje_mn   as c7,
           a.nja_results          as c8,
           a.nja_notes            as c9

      from uss_esr.v_nsp_sc_journal j,
           uss_esr.v_nsj_accounting a,
           uss_esr.v_nsj_experts ex
     where 1 = 1
       and j.nsj_id = :p_nsj_id
       and a.nja_nsj = j.nsj_id
       and a.history_status = 'A'
       and ex.nje_id(+)= a.nja_nje
       and ex.history_status(+)= 'A'
  ]';
        l_str := REPLACE (l_str, ':p_nsj_id', p_nsj_id);
        rdm$rtfl_univ.AddDataset ('ds8', l_str);

        --9. Облік іншої інформації, що стосується сім’ї/особи
        l_str :=
            q'[
    select row_number() OVER (ORDER BY i.njo_id) as c1,
           to_char(i.njo_dt, 'dd.mm.yyyy') as c2,
           i.njo_info  as c3,
           nvl(Api$Act_Rpt.GetCuPIB(hs.hs_cu), Tools.Getuserpib(hs.hs_wu)) as c4,
           i.njo_notes as c5
      from uss_esr.v_nsp_sc_journal j,
           uss_esr.v_nsj_other_info i,
           uss_esr.v_histsession hs
     where 1 = 1
       and j.nsj_id = :p_nsj_id
       and i.njo_nsj = j.nsj_id
       and i.history_status = 'A'
       and hs.hs_id(+)= i.njo_hs_upd
  ]';
        l_str := REPLACE (l_str, ':p_nsj_id', p_nsj_id);
        rdm$rtfl_univ.AddDataset ('ds9', l_str);

        -----------------------------------------
        rdm$rtfl_univ.get_report_result (p_jbr_id     => p_jbr_id,
                                         p_rpt_blob   => p_blob);
        replace_ekr (p_blob);
    END;

    --#93592 Форма друку Картки 1005 (Соціальна картка сім’ї/особи)
    FUNCTION SOCIAL_CARD_1005 (p_nsj_id IN nsp_sc_journal.nsj_id%TYPE)
        RETURN BLOB
    IS
        l_jbr_id   NUMBER;
        l_blob     BLOB;
    BEGIN
        Social_Card_1005 (p_nsj_id,
                          rdm$rtfl_univ.c_Bld_Tp_Db,
                          l_jbr_id,
                          l_blob);
        RETURN l_blob;
    END;



    -- info:   Ініціалізація процесу підготовки друкованої форми
    -- params: p_rt_id - ідентифікатор шаблону
    --         p_pd_id - ідентифікатор рішення
    -- note:   #93592
    PROCEDURE REG_REPORT (p_rt_id    IN     NUMBER,
                          p_nsj_id   IN     NUMBER,
                          p_jbr_id      OUT NUMBER)
    IS
        c_Bld_Tp   CONSTANT VARCHAR2 (100) := rdm$rtfl_univ.c_Bld_Tp_Svc; --тип звіту (rdm$rtfl_univ.c_Bld_Tp_Svc/rdm$rtfl_univ.c_Bld_Tp_Db)

        l_blob              BLOB;

        l_rt_code           rpt_templates.rt_code%TYPE
                                := get_rpt_code (p_rt_id);
    BEGIN
        tools.WriteMsg ('DNET$SC_JOURNAL_RPT.' || $$PLSQL_UNIT);

        --ідентифікація процесу
        DBMS_APPLICATION_INFO.set_module (
            module_name   => $$PLSQL_UNIT,
            action_name   =>
                   'p_rt_id='
                || TO_CHAR (p_rt_id)
                || '; p_nsj_id='
                || TO_CHAR (p_nsj_id));

        CASE
            WHEN l_rt_code = 'SOCIAL_CARD_1005'
            THEN
                social_card_1005 (p_nsj_id,
                                  c_Bld_Tp,
                                  p_jbr_id,
                                  l_blob);
            ELSE
                NULL;
        END CASE;
    END;
END Dnet$Sc_Journal_Rpt;
/