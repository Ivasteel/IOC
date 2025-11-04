/* Formatted on 8/12/2025 5:48:28 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.DNET$RPT_NEED
IS
    -- Author  : IO
    -- Created : 29.10.2021 16:13:41
    -- Purpose : Звіти для "Cоціальне казначейство"

    PROCEDURE RegisterReport (p_rt_id      IN     NUMBER,
                              p_start_dt   IN     DATE,
                              p_stop_dt    IN     DATE,
                              p_org_id     IN     NUMBER,
                              p_val_1      IN     VARCHAR2,
                              p_jbr_id        OUT DECIMAL);
END;
/


GRANT EXECUTE ON USS_ESR.DNET$RPT_NEED TO DNET_PROXY
/

GRANT EXECUTE ON USS_ESR.DNET$RPT_NEED TO II01RC_USS_ESR_WEB
/


/* Formatted on 8/12/2025 5:49:55 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.DNET$RPT_NEED
IS
    -- info:   Отримання ідентифікатора шаблону по коду
    -- params: p_rt_code - код шаблону
    -- note:
    FUNCTION get_rt_by_code (p_rt_code IN rpt_templates.rt_code%TYPE)
        RETURN NUMBER
    IS
        v_rt_id   rpt_templates.rt_id%TYPE;
    BEGIN
        SELECT rt_id
          INTO v_rt_id
          FROM v_rpt_templates
         WHERE rt_code = p_rt_code;

        RETURN v_rt_id;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    -- info:   Отримання назви місяця по даті
    -- params: p_date - дата по якій необхідно отримати назву місяця
    -- note:
    FUNCTION get_month_name (p_date IN DATE)
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN (CASE TO_NUMBER (TO_CHAR (p_date, 'MM'))
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
                    ELSE ''
                END);
    END;



    -- Потреба
    FUNCTION PAY_NEED_R1 (p_rt_id    IN NUMBER,
                          p_dt       IN DATE,
                          p_fr_tp    IN VARCHAR2,
                          p_org_id   IN NUMBER)
        RETURN NUMBER
    IS
        --l_sum  number(18,2);
        --l_cnt  number(14,0);
        l_rows_cnt   NUMBER (14, 0);
        --l_adds_str  varchar2(32000) := '';
        l_sql_01     VARCHAR2 (32000) := '';
        l_sql_02     VARCHAR2 (32000) := '';
        l_sql_03     VARCHAR2 (32000) := '';
        l_sql_04     VARCHAR2 (32000) := '';
        l_jbr_id     NUMBER;
        l_dt         DATE := TRUNC (p_dt, 'MM');
        l_own_tp     VARCHAR2 (10);
        l_fr_st      VARCHAR2 (10);
        l_user_org   NUMBER;
    BEGIN
        l_jbr_id := RDM$RTFL.InitReport (p_rt_id);

        --  raise_application_error(-20000, p_dt || ';' || p_org_id || '; u_org=' || USS_ESR_CONTEXT.GetContext(USS_ESR_CONTEXT.gORG));
        IF p_org_id IN (0, 50000)
        THEN
            l_own_tp := 'CONS';
            l_fr_st := 'R';
        ELSE
            SELECT CASE WHEN org_to = 32 THEN 'OWN' ELSE 'CONS' END,
                   CASE WHEN org_to = 32 THEN 'Z' ELSE 'R' END
              INTO l_own_tp, l_fr_st
              FROM v_opfu t
             WHERE org_id = p_org_id;
        END IF;

        l_user_org := USS_ESR_CONTEXT.GetContext (USS_ESR_CONTEXT.gORG);

        l_sql_01 :=
               q'[select
o.x_num as t01_rn,
o.org_id as t01_code,
--o.org_name as t01_name, --uss_esr.tools.GetOpfuParam('KAOT_NAME',o.org_id)
nvl(kaot_name, org_name) as t01_name,
dd.*
from(
select
row_number()over(order by decode(org_id, 53000, 'яяя', uss_esr.tools.GetOpfuParam('KAOT_NAME',o.org_id))) as x_num,
uss_esr.tools.GetOpfuParam('KAOT_NAME',o.org_id) as kaot_name,
o.* from v_opfu o where 1=1
]'
            || CASE
                   WHEN p_org_id IN (0, 50000)
                   THEN
                       ' and o.org_org = 50000 and org_id not in (54300, 54000)'
                   ELSE
                       ' and org_id = ' || p_org_id
               END
            || q'[
) o

left join (
-- KEKV   npc_nkv
-- 23 -- 2730 Інші виплати населенню
-- 43 -- 2240 Оплата послуг (крім комунальних)
  select
    ]'
            || CASE
                   WHEN    p_org_id IN (0, 50000)
                        OR l_user_org = 50000 AND p_org_id NOT IN (0, 50000) -- центр по регіону
                   THEN
                       ' fr_org '
                   ELSE
                       ' com_org '
               END
            || q'[ as com_org,
  -- допомога особі, яка проживає разом з особою з інвалідністю I чи II групи внаслідок психічного розладу, яка за висновком лікарської комісії медичного закладу потребує постійного стороннього догляду, на догляд за нею
    sum(case when frs_nst = 274 and frs_value_tp = 'QNT' then frs_value else null end)as t01s01_cnt,  -- к-ть справ?
    sum(case when frs_nst = 274 and frs_value_tp != 'QNT' then frs_value else 0 end) as t01s01_sum,
    sum(case when frs_nst = 274 and frs_value_tp != 'QNT'and frs_nkv = 23 then frs_value else 0 end) as t01s01k01_all,
    sum(case when frs_nst = 274 and frs_value_tp = 'BSA' and frs_nkv = 23 and frs_pay_tp = 'PB' then frs_value else 0 end) as t01s01k01_bank,
    sum(case when frs_nst = 274 and frs_value_tp = 'PSA' and frs_nkv = 23 and frs_pay_tp = 'PP' then frs_value else 0 end) as t01s01k01_post,
    sum(case when frs_nst = 274 and frs_value_tp != 'QNT'and frs_nkv = 43 then frs_value else 0 end) as t01s01k02_all,
  -- виплати державної допомоги сім'ям з дітьми
  -- -- допомога у зв'язку з вагітністю та пологами  -- 251 1.1
    sum(case when frs_nst = 251 and frs_value_tp = 'QNT' then frs_value else null end)as t01s02_cnt,  -- к-ть справ?
    sum(case when frs_nst = 251 and frs_value_tp != 'QNT' then frs_value else 0 end) as t01s02_sum,
    sum(case when frs_nst = 251 and frs_value_tp != 'QNT'and frs_nkv = 23 then frs_value else 0 end) as t01s02k01_all,
    sum(case when frs_nst = 251 and frs_value_tp = 'BSA' and frs_nkv = 23 and frs_pay_tp = 'PB' then frs_value else 0 end) as t01s02k01_bank,
    sum(case when frs_nst = 251 and frs_value_tp = 'PSA' and frs_nkv = 23 and frs_pay_tp = 'PP' then frs_value else 0 end) as t01s02k01_post,
    sum(case when frs_nst = 251 and frs_value_tp != 'QNT'and frs_nkv = 43 then frs_value else 0 end) as t01s02k02_all,
  -- -- допомога при усиновленні дитини   -- 269 1.3
    sum(case when frs_nst = 269 and frs_value_tp = 'QNT' then frs_value else null end)as t01s03_cnt,  -- к-ть справ?
    sum(case when frs_nst = 269 and frs_value_tp != 'QNT' then frs_value else 0 end) as t01s03_sum,
    sum(case when frs_nst = 269 and frs_value_tp != 'QNT'and frs_nkv = 23 then frs_value else 0 end) as t01s03k01_all,
    sum(case when frs_nst = 269 and frs_value_tp = 'BSA' and frs_nkv = 23 and frs_pay_tp = 'PB' then frs_value else 0 end) as t01s03k01_bank,
    sum(case when frs_nst = 269 and frs_value_tp = 'PSA' and frs_nkv = 23 and frs_pay_tp = 'PP' then frs_value else 0 end) as t01s03k01_post,
    sum(case when frs_nst = 269 and frs_value_tp != 'QNT'and frs_nkv = 43 then frs_value else 0 end) as t01s03k02_all,
  -- -- допомога при народженні дитини    -- 250 1.2
    sum(case when frs_nst = 250 and frs_value_tp = 'QNT' then frs_value else null end)as t01s04_cnt,  -- к-ть справ?
    sum(case when frs_nst = 250 and frs_value_tp != 'QNT' then frs_value else 0 end) as t01s04_sum,
    sum(case when frs_nst = 250 and frs_value_tp != 'QNT'and frs_nkv = 23 then frs_value else 0 end) as t01s04k01_all,
    sum(case when frs_nst = 250 and frs_value_tp = 'BSA' and frs_nkv = 23 and frs_pay_tp = 'PB' then frs_value else 0 end) as t01s04k01_bank,
    sum(case when frs_nst = 250 and frs_value_tp = 'PSA' and frs_nkv = 23 and frs_pay_tp = 'PP' then frs_value else 0 end) as t01s04k01_post,
    sum(case when frs_nst = 250 and frs_value_tp != 'QNT'and frs_nkv = 43 then frs_value else 0 end) as t01s04k02_all,
  -- -- допомога на дітей, над якими встановлено опіку чи піклування  -- 268 1.4
    sum(case when frs_nst = 268 and frs_value_tp = 'QNT' then frs_value else null end)as t01s05_cnt,  -- к-ть справ?
    sum(case when frs_nst = 268 and frs_value_tp != 'QNT' then frs_value else 0 end) as t01s05_sum,
    sum(case when frs_nst = 268 and frs_value_tp != 'QNT'and frs_nkv = 23 then frs_value else 0 end) as t01s05k01_all,
    sum(case when frs_nst = 268 and frs_value_tp = 'BSA' and frs_nkv = 23 and frs_pay_tp = 'PB' then frs_value else 0 end) as t01s05k01_bank,
    sum(case when frs_nst = 268 and frs_value_tp = 'PSA' and frs_nkv = 23 and frs_pay_tp = 'PP' then frs_value else 0 end) as t01s05k01_post,
    sum(case when frs_nst = 268 and frs_value_tp != 'QNT'and frs_nkv = 43 then frs_value else 0 end) as t01s05k02_all,
  -- -- допомога на дітей одиноким матерям   -- 267 1.5
    sum(case when frs_nst = 267 and frs_value_tp = 'QNT' then frs_value else null end)as t01s06_cnt,  -- к-ть справ?
    sum(case when frs_nst = 267 and frs_value_tp != 'QNT' then frs_value else 0 end) as t01s06_sum,
    sum(case when frs_nst = 267 and frs_value_tp != 'QNT'and frs_nkv = 23 then frs_value else 0 end) as t01s06k01_all,
    sum(case when frs_nst = 267 and frs_value_tp = 'BSA' and frs_nkv = 23 and frs_pay_tp = 'PB' then frs_value else 0 end) as t01s06k01_bank,
    sum(case when frs_nst = 267 and frs_value_tp = 'PSA' and frs_nkv = 23 and frs_pay_tp = 'PP' then frs_value else 0 end) as t01s06k01_post,
    sum(case when frs_nst = 267 and frs_value_tp != 'QNT'and frs_nkv = 43 then frs_value else 0 end) as t01s06k02_all,
  -- -- допомога особі, яка доглядає за хворою дитиною    -- 265 1.6
    sum(case when frs_nst = 265 and frs_value_tp = 'QNT' then frs_value else null end)as t01s07_cnt,  -- к-ть справ?
    sum(case when frs_nst = 265 and frs_value_tp != 'QNT' then frs_value else 0 end) as t01s07_sum,
    sum(case when frs_nst = 265 and frs_value_tp != 'QNT'and frs_nkv = 23 then frs_value else 0 end) as t01s07k01_all,
    sum(case when frs_nst = 265 and frs_value_tp = 'BSA' and frs_nkv = 23 and frs_pay_tp = 'PB' then frs_value else 0 end) as t01s07k01_bank,
    sum(case when frs_nst = 265 and frs_value_tp = 'PSA' and frs_nkv = 23 and frs_pay_tp = 'PP' then frs_value else 0 end) as t01s07k01_post,
    sum(case when frs_nst = 265 and frs_value_tp != 'QNT'and frs_nkv = 43 then frs_value else 0 end) as t01s07k02_all,
  -- виплата державної соціальної допомоги малозабезпеченим сім'ям
    sum(case when frs_nst = 249 and frs_value_tp = 'QNT' then frs_value else null end)as t01s08_cnt,  -- к-ть справ?
    sum(case when frs_nst = 249 and frs_value_tp != 'QNT' then frs_value else 0 end) as t01s08_sum,
    sum(case when frs_nst = 249 and frs_value_tp != 'QNT'and frs_nkv = 23 then frs_value else 0 end) as t01s08k01_all,
    sum(case when frs_nst = 249 and frs_value_tp = 'BSA' and frs_nkv = 23 and frs_pay_tp = 'PB' then frs_value else 0 end) as t01s08k01_bank,
    sum(case when frs_nst = 249 and frs_value_tp = 'PSA' and frs_nkv = 23 and frs_pay_tp = 'PP' then frs_value else 0 end) as t01s08k01_post,
    sum(case when frs_nst = 249 and frs_value_tp != 'QNT'and frs_nkv = 43 then frs_value else 0 end) as t01s08k02_all,
  -- ?????????? виплата тимчасової державної  допомоги  дітям,  батьки  яких  ухиляються  від  сплати аліментів,  не  мають  можливості  утримувати  дитину  або   місце проживання їх невідоме
    sum(case when frs_nst = 9999 and frs_value_tp = 'QNT' then frs_value else null end)as t01s09_cnt,  -- к-ть справ?
    sum(case when frs_nst = 9999 and frs_value_tp != 'QNT' then frs_value else 0 end) as t01s09_sum,
    sum(case when frs_nst = 9999 and frs_value_tp != 'QNT'and frs_nkv = 23 then frs_value else 0 end) as t01s09k01_all,
    sum(case when frs_nst = 9999 and frs_value_tp = 'BSA' and frs_nkv = 23 and frs_pay_tp = 'PB' then frs_value else 0 end) as t01s09k01_bank,
    sum(case when frs_nst = 9999 and frs_value_tp = 'PSA' and frs_nkv = 23 and frs_pay_tp = 'PP' then frs_value else 0 end) as t01s09k01_post,
    sum(case when frs_nst = 9999 and frs_value_tp != 'QNT'and frs_nkv = 43 then frs_value else 0 end) as t01s09k02_all,
  -- виплата державної соціальної допомоги особам з інвалідністю з дитинства та дітям з інвалідністю
    sum(case when frs_nst = 248 and frs_value_tp = 'QNT' then frs_value else null end)as t01s10_cnt,  -- к-ть справ?
    sum(case when frs_nst = 248 and frs_value_tp != 'QNT' then frs_value else 0 end) as t01s10_sum,
    sum(case when frs_nst = 248 and frs_value_tp != 'QNT'and frs_nkv = 23 then frs_value else 0 end) as t01s10k01_all,
    sum(case when frs_nst = 248 and frs_value_tp = 'BSA' and frs_nkv = 23 and frs_pay_tp = 'PB' then frs_value else 0 end) as t01s10k01_bank,
    sum(case when frs_nst = 248 and frs_value_tp = 'PSA' and frs_nkv = 23 and frs_pay_tp = 'PP' then frs_value else 0 end) as t01s10k01_post,
    sum(case when frs_nst = 248 and frs_value_tp != 'QNT'and frs_nkv = 43 then frs_value else 0 end) as t01s10k02_all
  from uss_esr.v_funding_request  fr
  join uss_esr.v_fr_detail_service frs on frs.frs_fr = fr.fr_id
  --join v_opfu on org_id = fr.com_org
  where 1=1
    and fr.fr_nbg = 1 -- Бюджетна програма КПК 2501030
    and fr.fr_month = to_date(']'
            || TO_CHAR (l_dt, 'dd.mm.yyyy')
            || q'[', 'dd.mm.yyyy')
    and fr.fr_st = ']'
            || l_fr_st
            || q'[' ---- 'R'--- 4test 'Z' -- Затверджено
    and fr.fr_own_tp = ']'
            || l_own_tp
            || q'[' ----'CONS'
    and frs_nst in (248, 268, 249, 265, 267, 250, 269, 251, 274)]'
            || CASE
                   WHEN p_fr_tp = 'ALL' THEN ''
                   ELSE ' and fr_tp = ''' || p_fr_tp || ''''
               END
            || q'[
  group by     ]'
            || CASE
                   WHEN    p_org_id IN (0, 50000)
                        OR l_user_org = 50000 AND p_org_id NOT IN (0, 50000) -- центр по регіону
                   THEN
                       ' fr_org '
                   ELSE
                       ' com_org '
               END
            || q'[
) dd
on dd.com_org = o.org_id
order by o.x_num]';


        l_sql_02 :=
               q'[select
o.x_num as t02_rn,
o.org_id as t02_code,
nvl(kaot_name, org_name) as t02_name,
dd.*
from(
select
row_number()over(order by decode(org_id, 53000, 'яяя', uss_esr.tools.GetOpfuParam('KAOT_NAME',o.org_id))) as x_num,
uss_esr.tools.GetOpfuParam('KAOT_NAME',o.org_id) as kaot_name,
o.* from v_opfu o where 1=1
]'
            || CASE
                   WHEN p_org_id IN (0, 50000)
                   THEN
                       ' and o.org_org = 50000 and org_id not in (54300, 54000)'
                   ELSE
                       ' and org_id = ' || p_org_id
               END
            || q'[
) o

left join (
  select  ]'
            || CASE
                   WHEN p_org_id IN (0, 50000) THEN ' fr_org '
                   ELSE ' com_org '
               END
            || q'[ as  com_org,
-- допомога на дітей, які виховуються у багатодітних сім'ях
    sum(case when frs_nst = 9999 and frs_value_tp = 'QNT' then frs_value else null end)as t02s01_cnt,  -- к-ть справ?
    sum(case when frs_nst = 9999 and frs_value_tp != 'QNT' then frs_value else 0 end) as t02s01_sum,
    sum(case when frs_nst = 9999 and frs_value_tp != 'QNT'and frs_nkv = 23 then frs_value else 0 end) as t02s01k01_all,
    sum(case when frs_nst = 9999 and frs_value_tp = 'BSA' and frs_nkv = 23 and frs_pay_tp = 'PB' then frs_value else 0 end) as t02s01k01_bank,
    sum(case when frs_nst = 9999 and frs_value_tp = 'PSA' and frs_nkv = 23 and frs_pay_tp = 'PP' then frs_value else 0 end) as t02s01k01_post,
    sum(case when frs_nst = 9999 and frs_value_tp != 'QNT'and frs_nkv = 43 then frs_value else 0 end) as t02s01k02_all,
-- державна соціальна допомога на дітей-сиріт та дітей, позбавлених батьківського піклування та грошового забезпечення батькам-вихователям і прийомним батькам за надання соціальних послуг у дитячих будинках сімейного типу та прийомних сім’ях, здійснення видатків на сплату за них єдиного внеску на загальнообов’язкове державне соціальне страхування
    sum(case when frs_nst = 9999 and frs_value_tp = 'QNT' then frs_value else null end)as t02s02_cnt,  -- к-ть справ?
    sum(case when frs_nst = 9999 and frs_value_tp != 'QNT' then frs_value else 0 end) as t02s02_sum,
    sum(case when frs_nst = 9999 and frs_value_tp != 'QNT'and frs_nkv = 23 then frs_value else 0 end) as t02s02k01_all,
    sum(case when frs_nst = 9999 and frs_value_tp = 'BSA' and frs_nkv = 23 and frs_pay_tp = 'PB' then frs_value else 0 end) as t02s02k01_bank,
    sum(case when frs_nst = 9999 and frs_value_tp = 'PSA' and frs_nkv = 23 and frs_pay_tp = 'PP' then frs_value else 0 end) as t02s02k01_post,
    sum(case when frs_nst = 9999 and frs_value_tp != 'QNT'and frs_nkv = 43 then frs_value else 0 end) as t02s02k02_all,
-- -- державна соціальна допомога на дітей-сиріт та дітей, позбавлених батьківського піклування та грошового забезпечення батькам-вихователям і прийомним батькам за надання соціальних послуг у дитячих будинках сімейного типу, здійснення видатків на сплату за них єдиного внеску на загальнообов’язкове державне соціальне страхування
    sum(case when frs_nst = 9999 and frs_value_tp = 'QNT' then frs_value else null end)as t02s03_cnt,  -- к-ть справ?
    sum(case when frs_nst = 9999 and frs_value_tp != 'QNT' then frs_value else 0 end) as t02s03_sum,
    sum(case when frs_nst = 9999 and frs_value_tp != 'QNT'and frs_nkv = 23 then frs_value else 0 end) as t02s03k01_all,
    sum(case when frs_nst = 9999 and frs_value_tp = 'BSA' and frs_nkv = 23 and frs_pay_tp = 'PB' then frs_value else 0 end) as t02s03k01_bank,
    sum(case when frs_nst = 9999 and frs_value_tp = 'PSA' and frs_nkv = 23 and frs_pay_tp = 'PP' then frs_value else 0 end) as t02s03k01_post,
    sum(case when frs_nst = 9999 and frs_value_tp != 'QNT'and frs_nkv = 43 then frs_value else 0 end) as t02s03k02_all,
-- -- державна соціальна допомога на дітей-сиріт та дітей, позбавлених батьківського піклування та грошового забезпечення батькам-вихователям і прийомним батькам за надання соціальних послуг у прийомних сім’ях, здійснення видатків на сплату за них єдиного внеску на загальнообов’язкове державне соціальне страхування
    sum(case when frs_nst = 9999 and frs_value_tp = 'QNT' then frs_value else null end)as t02s04_cnt,  -- к-ть справ?
    sum(case when frs_nst = 9999 and frs_value_tp != 'QNT' then frs_value else 0 end) as t02s04_sum,
    sum(case when frs_nst = 9999 and frs_value_tp != 'QNT'and frs_nkv = 23 then frs_value else 0 end) as t02s04k01_all,
    sum(case when frs_nst = 9999 and frs_value_tp = 'BSA' and frs_nkv = 23 and frs_pay_tp = 'PB' then frs_value else 0 end) as t02s04k01_bank,
    sum(case when frs_nst = 9999 and frs_value_tp = 'PSA' and frs_nkv = 23 and frs_pay_tp = 'PP' then frs_value else 0 end) as t02s04k01_post,
    sum(case when frs_nst = 9999 and frs_value_tp != 'QNT'and frs_nkv = 43 then frs_value else 0 end) as t02s04k02_all,
-- оплата послуг патронатного вихователя, виплата соціальної допомоги на утримання дитини в сім’ї патронатного вихователя та здійснення видатків на сплату за патронатного вихователя єдиного внеску на загальнообов’язкове державне соціальне страхування
    sum(case when frs_nst = 9999 and frs_value_tp = 'QNT' then frs_value else null end)as t02s05_cnt,  -- к-ть справ?
    sum(case when frs_nst = 9999 and frs_value_tp != 'QNT' then frs_value else 0 end) as t02s05_sum,
    sum(case when frs_nst = 9999 and frs_value_tp != 'QNT'and frs_nkv = 23 then frs_value else 0 end) as t02s05k01_all,
    sum(case when frs_nst = 9999 and frs_value_tp = 'BSA' and frs_nkv = 23 and frs_pay_tp = 'PB' then frs_value else 0 end) as t02s05k01_bank,
    sum(case when frs_nst = 9999 and frs_value_tp = 'PSA' and frs_nkv = 23 and frs_pay_tp = 'PP' then frs_value else 0 end) as t02s05k01_post,
    sum(case when frs_nst = 9999 and frs_value_tp != 'QNT'and frs_nkv = 43 then frs_value else 0 end) as t02s05k02_all,
-- підтримка  малих групових будинків
    sum(case when frs_nst = 9999 and frs_value_tp = 'QNT' then frs_value else null end)as t02s06_cnt,  -- к-ть справ?
    sum(case when frs_nst = 9999 and frs_value_tp != 'QNT' then frs_value else 0 end) as t02s06_sum,
    sum(case when frs_nst = 9999 and frs_value_tp != 'QNT'and frs_nkv = 23 then frs_value else 0 end) as t02s06k01_all,
    sum(case when frs_nst = 9999 and frs_value_tp = 'BSA' and frs_nkv = 23 and frs_pay_tp = 'PB' then frs_value else 0 end) as t02s06k01_bank,
    sum(case when frs_nst = 9999 and frs_value_tp = 'PSA' and frs_nkv = 23 and frs_pay_tp = 'PP' then frs_value else 0 end) as t02s06k01_post,
    sum(case when frs_nst = 9999 and frs_value_tp != 'QNT'and frs_nkv = 43 then frs_value else 0 end) as t02s06k02_all
  from uss_esr.v_funding_request  fr
  join uss_esr.v_fr_detail_service frs on frs.frs_fr = fr.fr_id
  --join v_opfu on org_id = fr.com_org
  where 1=1
    and fr.fr_nbg = 1 -- Бюджетна програма КПК 2501030
    and fr.fr_month = to_date(']'
            || TO_CHAR (l_dt, 'dd.mm.yyyy')
            || q'[', 'dd.mm.yyyy')
    and fr.fr_st = ']'
            || l_fr_st
            || q'[' ----'R'--- 4test 'Z' -- Затверджено
    and fr.fr_own_tp =  ']'
            || l_own_tp
            || q'[' ---- 'CONS'
    and frs_nst in (-9999)]'
            || CASE
                   WHEN p_fr_tp = 'ALL' THEN ''
                   ELSE ' and fr_tp = ''' || p_fr_tp || ''''
               END
            || q'[
  group by  ]'
            || CASE
                   WHEN p_org_id IN (0, 50000) THEN ' fr_org '
                   ELSE ' com_org '
               END
            || q'[
) dd
on dd.com_org = o.org_id
order by o.x_num]';


        l_sql_03 :=
               q'[select
o.x_num as t03_rn,
o.org_id as t03_code,
nvl(kaot_name, org_name) as t03_name,
dd.*
from(
select
row_number()over(order by decode(org_id, 53000, 'яяя', uss_esr.tools.GetOpfuParam('KAOT_NAME',o.org_id))) as x_num,
uss_esr.tools.GetOpfuParam('KAOT_NAME',o.org_id) as kaot_name,
o.* from v_opfu o where  1=1
]'
            || CASE
                   WHEN p_org_id IN (0, 50000)
                   THEN
                       ' and o.org_org = 50000 and org_id not in (54300, 54000)'
                   ELSE
                       ' and org_id = ' || p_org_id
               END
            || q'[
) o
left join (
  select
     ]'
            || CASE
                   WHEN p_org_id IN (0, 50000) THEN ' fr_org '
                   ELSE ' com_org '
               END
            || q'[ as com_org,
-- 288  4  виплата державної соціальної допомоги особам, які не мають права на пенсію, та особам з інвалідністю
    sum(case when frs_nst = 288 and frs_value_tp = 'QNT' then frs_value else null end)as t03s01_cnt,  -- к-ть справ?
    sum(case when frs_nst = 288 and frs_value_tp != 'QNT' then frs_value else 0 end) as t03s01_sum,
    sum(case when frs_nst = 288 and frs_value_tp != 'QNT'and frs_nkv = 23 then frs_value else 0 end) as t03s01k01_all,
    sum(case when frs_nst = 288 and frs_value_tp = 'BSA' and frs_nkv = 23 and frs_pay_tp = 'PB' then frs_value else 0 end) as t03s01k01_bank,
    sum(case when frs_nst = 288 and frs_value_tp = 'PSA' and frs_nkv = 23 and frs_pay_tp = 'PP' then frs_value else 0 end) as t03s01k01_post,
    sum(case when frs_nst = 288 and frs_value_tp != 'QNT'and frs_nkv = 43 then frs_value else 0 end) as t03s01k02_all,
-- виплата державної соціальної допомоги на догляд
    sum(case when frs_nst = 9999 and frs_value_tp = 'QNT' then frs_value else null end)as t03s02_cnt,  -- к-ть справ?
    sum(case when frs_nst = 9999 and frs_value_tp != 'QNT' then frs_value else 0 end) as t03s02_sum,
    sum(case when frs_nst = 9999 and frs_value_tp != 'QNT'and frs_nkv = 23 then frs_value else 0 end) as t03s02k01_all,
    sum(case when frs_nst = 9999 and frs_value_tp = 'BSA' and frs_nkv = 23 and frs_pay_tp = 'PB' then frs_value else 0 end) as t03s02k01_bank,
    sum(case when frs_nst = 9999 and frs_value_tp = 'PSA' and frs_nkv = 23 and frs_pay_tp = 'PP' then frs_value else 0 end) as t03s02k01_post,
    sum(case when frs_nst = 9999 and frs_value_tp != 'QNT'and frs_nkv = 43 then frs_value else 0 end) as t03s02k02_all,
-- виплата тимчасової державної соціальної допомоги непрацюючій особі, яка досягла загального пенсійного віку, але не набула права на пенсійну виплату
    sum(case when frs_nst = 9999 and frs_value_tp = 'QNT' then frs_value else null end)as t03s03_cnt,  -- к-ть справ?
    sum(case when frs_nst = 9999 and frs_value_tp != 'QNT' then frs_value else 0 end) as t03s03_sum,
    sum(case when frs_nst = 9999 and frs_value_tp != 'QNT'and frs_nkv = 23 then frs_value else 0 end) as t03s03k01_all,
    sum(case when frs_nst = 9999 and frs_value_tp = 'BSA' and frs_nkv = 23 and frs_pay_tp = 'PB' then frs_value else 0 end) as t03s03k01_bank,
    sum(case when frs_nst = 9999 and frs_value_tp = 'PSA' and frs_nkv = 23 and frs_pay_tp = 'PP' then frs_value else 0 end) as t03s03k01_post,
    sum(case when frs_nst = 9999 and frs_value_tp != 'QNT'and frs_nkv = 43 then frs_value else 0 end) as t03s03k02_all,
-- 256  10 виплата щомісячної компенсаційної виплати непрацюючій працездатній особі, яка доглядає за особою з інвалідністю I групи, а також за особою, яка досягла 80-річного віку
    sum(case when frs_nst = 256 and frs_value_tp = 'QNT' then frs_value else null end)as t03s04_cnt,  -- к-ть справ?
    sum(case when frs_nst = 256 and frs_value_tp != 'QNT' then frs_value else 0 end) as t03s04_sum,
    sum(case when frs_nst = 256 and frs_value_tp != 'QNT'and frs_nkv = 23 then frs_value else 0 end) as t03s04k01_all,
    sum(case when frs_nst = 256 and frs_value_tp = 'BSA' and frs_nkv = 23 and frs_pay_tp = 'PB' then frs_value else 0 end) as t03s04k01_bank,
    sum(case when frs_nst = 256 and frs_value_tp = 'PSA' and frs_nkv = 23 and frs_pay_tp = 'PP' then frs_value else 0 end) as t03s04k01_post,
    sum(case when frs_nst = 256 and frs_value_tp != 'QNT'and frs_nkv = 43 then frs_value else 0 end) as t03s04k02_all,
-- відшкодування вартості послуги з догляду за дитиною до трьох років „муніципальна няня”
    sum(case when frs_nst = 9999 and frs_value_tp = 'QNT' then frs_value else null end)as t03s05_cnt,  -- к-ть справ?
    sum(case when frs_nst = 9999 and frs_value_tp != 'QNT' then frs_value else 0 end) as t03s05_sum,
    sum(case when frs_nst = 9999 and frs_value_tp != 'QNT'and frs_nkv = 23 then frs_value else 0 end) as t03s05k01_all,
    sum(case when frs_nst = 9999 and frs_value_tp = 'BSA' and frs_nkv = 23 and frs_pay_tp = 'PB' then frs_value else 0 end) as t03s05k01_bank,
    sum(case when frs_nst = 9999 and frs_value_tp = 'PSA' and frs_nkv = 23 and frs_pay_tp = 'PP' then frs_value else 0 end) as t03s05k01_post,
    sum(case when frs_nst = 9999 and frs_value_tp != 'QNT'and frs_nkv = 43 then frs_value else 0 end) as t03s05k02_all
  from uss_esr.v_funding_request  fr
  join uss_esr.v_fr_detail_service frs on frs.frs_fr = fr.fr_id
  join v_opfu on org_id = fr.com_org
  where 1=1
    and fr.fr_nbg = 1 -- Бюджетна програма КПК 2501030
    and fr.fr_month = to_date(']'
            || TO_CHAR (l_dt, 'dd.mm.yyyy')
            || q'[', 'dd.mm.yyyy')
    and fr.fr_st = ']'
            || l_fr_st
            || q'[' ----'R'--- 4test 'Z' -- Затверджено
    and fr.fr_own_tp =  ']'
            || l_own_tp
            || q'[' ---- 'CONS'
    and frs_nst in (-9999)]'
            || CASE
                   WHEN p_fr_tp = 'ALL' THEN ''
                   ELSE ' and fr_tp = ''' || p_fr_tp || ''''
               END
            || q'[
  group by  ]'
            || CASE
                   WHEN p_org_id IN (0, 50000) THEN ' fr_org '
                   ELSE ' com_org '
               END
            || q'[
) dd
on dd.com_org = o.org_id
order by o.x_num]';


        l_sql_04 :=
               q'[select
o.x_num as t04_rn,
o.org_id as t04_code,
nvl(kaot_name, o.org_name) as t04_name
from(
select
row_number()over(order by decode(org_id, 53000, 'яяя', uss_esr.tools.GetOpfuParam('KAOT_NAME',o.org_id))) as x_num,
uss_esr.tools.GetOpfuParam('KAOT_NAME',o.org_id) as kaot_name,
o.* from v_opfu o where  1=1
]'
            || CASE
                   WHEN p_org_id IN (0, 50000)
                   THEN
                       ' and o.org_org = 50000 and org_id not in (54300, 54000)'
                   ELSE
                       ' and org_id = ' || p_org_id
               END
            || q'[
) o
order by o.x_num]';

        --dbms_output.put_line(l_sql_01) ;

        EXECUTE IMMEDIATE 'select count(1) from(' || l_sql_04 || ')'
            INTO l_rows_cnt;

        RDM$RTFL.AddParam (l_jbr_id, 'p_rows_cnt', l_rows_cnt);
        RDM$RTFL.AddParam (l_jbr_id,
                           'rpt_month',
                           TO_CHAR (l_dt, 'month yyyy'));

        --dbms_output.put_line(l_sql_01) ;
        RDM$RTFL.AddDataSet (l_jbr_id, 'ds_t01', l_sql_01);
        RDM$RTFL.AddDataSet (l_jbr_id, 'ds_t02', l_sql_02);
        RDM$RTFL.AddDataSet (l_jbr_id, 'ds_t03', l_sql_03);
        RDM$RTFL.AddDataSet (l_jbr_id, 'ds_t04', l_sql_04);

        RDM$RTFL.PutReportToWorkingQueue (l_jbr_id);
        RETURN l_jbr_id;
    END;

    FUNCTION PAY_NEED_R1_000 (p_rt_id    IN NUMBER,
                              p_dt       IN DATE,
                              p_fr_tp    IN VARCHAR2,
                              p_org_id   IN NUMBER)
        RETURN NUMBER
    IS
        --l_sum  number(18,2);
        --l_cnt  number(14,0);
        l_rows_cnt   NUMBER (14, 0);
        --l_adds_str  varchar2(32000) := '';
        l_sql_01     VARCHAR2 (32000) := '';
        l_sql_02     VARCHAR2 (32000) := '';
        l_sql_03     VARCHAR2 (32000) := '';
        l_sql_04     VARCHAR2 (32000) := '';
        l_jbr_id     NUMBER;
        l_dt         DATE := TRUNC (p_dt, 'MM');
    BEGIN
        l_jbr_id := RDM$RTFL.InitReport (p_rt_id);
        --raise_application_error(-20000, p_dt || ';' || p_org_id || ';' || p_npc_id);

        l_sql_01 :=
               q'[select
o.x_num as t01_rn,
o.org_id as t01_code,
--o.org_name as t01_name, --uss_esr.tools.GetOpfuParam('KAOT_NAME',o.org_id)
nvl(kaot_name, org_name) as t01_name,
dd.*
from(
select
row_number()over(order by decode(org_id, 53000, 'яяя', uss_esr.tools.GetOpfuParam('KAOT_NAME',o.org_id))) as x_num,
uss_esr.tools.GetOpfuParam('KAOT_NAME',o.org_id) as kaot_name,
o.* from v_opfu o where 1=1
]'
            || CASE
                   WHEN p_org_id = 50000
                   THEN
                       ' and o.org_org = 50000 and org_id not in (54300, 54000)'
                   ELSE
                       ' and org_id = ' || p_org_id
               END
            || q'[
) o

left join (
-- KEKV   npc_nkv
-- 23 -- 2730 Інші виплати населенню
-- 43 -- 2240 Оплата послуг (крім комунальних)
  select
    com_org,
  -- допомога особі, яка проживає разом з особою з інвалідністю I чи II групи внаслідок психічного розладу, яка за висновком лікарської комісії медичного закладу потребує постійного стороннього догляду, на догляд за нею
    sum(case when frs_nst = 274 and frf_value_tp = 'QNT' then frf_value else null end)as t01s01_cnt,  -- к-ть справ?
    sum(case when frs_nst = 274 and frf_value_tp != 'QNT' then frf_value else 0 end) as t01s01_sum,
    sum(case when frs_nst = 274 and frf_value_tp != 'QNT'and frf_nkv = 23 then frf_value else 0 end) as t01s01k01_all,
    sum(case when frs_nst = 274 and frf_value_tp = 'BSA' and frf_nkv = 23 and frf_pay_tp = 'PB' then frf_value else 0 end) as t01s01k01_bank,
    sum(case when frs_nst = 274 and frf_value_tp = 'PSA' and frf_nkv = 23 and frf_pay_tp = 'PP' then frf_value else 0 end) as t01s01k01_post,
    sum(case when frs_nst = 274 and frf_value_tp != 'QNT'and frf_nkv = 43 then frf_value else 0 end) as t01s01k02_all,
  -- виплати державної допомоги сім'ям з дітьми
  -- -- допомога у зв'язку з вагітністю та пологами  -- 251 1.1
    sum(case when frs_nst = 251 and frf_value_tp = 'QNT' then frf_value else null end)as t01s02_cnt,  -- к-ть справ?
    sum(case when frs_nst = 251 and frf_value_tp != 'QNT' then frf_value else 0 end) as t01s02_sum,
    sum(case when frs_nst = 251 and frf_value_tp != 'QNT'and frf_nkv = 23 then frf_value else 0 end) as t01s02k01_all,
    sum(case when frs_nst = 251 and frf_value_tp = 'BSA' and frf_nkv = 23 and frf_pay_tp = 'PB' then frf_value else 0 end) as t01s02k01_bank,
    sum(case when frs_nst = 251 and frf_value_tp = 'PSA' and frf_nkv = 23 and frf_pay_tp = 'PP' then frf_value else 0 end) as t01s02k01_post,
    sum(case when frs_nst = 251 and frf_value_tp != 'QNT'and frf_nkv = 43 then frf_value else 0 end) as t01s02k02_all,
  -- -- допомога при усиновленні дитини   -- 269 1.3
    sum(case when frs_nst = 269 and frf_value_tp = 'QNT' then frf_value else null end)as t01s03_cnt,  -- к-ть справ?
    sum(case when frs_nst = 269 and frf_value_tp != 'QNT' then frf_value else 0 end) as t01s03_sum,
    sum(case when frs_nst = 269 and frf_value_tp != 'QNT'and frf_nkv = 23 then frf_value else 0 end) as t01s03k01_all,
    sum(case when frs_nst = 269 and frf_value_tp = 'BSA' and frf_nkv = 23 and frf_pay_tp = 'PB' then frf_value else 0 end) as t01s03k01_bank,
    sum(case when frs_nst = 269 and frf_value_tp = 'PSA' and frf_nkv = 23 and frf_pay_tp = 'PP' then frf_value else 0 end) as t01s03k01_post,
    sum(case when frs_nst = 269 and frf_value_tp != 'QNT'and frf_nkv = 43 then frf_value else 0 end) as t01s03k02_all,
  -- -- допомога при народженні дитини    -- 250 1.2
    sum(case when frs_nst = 250 and frf_value_tp = 'QNT' then frf_value else null end)as t01s04_cnt,  -- к-ть справ?
    sum(case when frs_nst = 250 and frf_value_tp != 'QNT' then frf_value else 0 end) as t01s04_sum,
    sum(case when frs_nst = 250 and frf_value_tp != 'QNT'and frf_nkv = 23 then frf_value else 0 end) as t01s04k01_all,
    sum(case when frs_nst = 250 and frf_value_tp = 'BSA' and frf_nkv = 23 and frf_pay_tp = 'PB' then frf_value else 0 end) as t01s04k01_bank,
    sum(case when frs_nst = 250 and frf_value_tp = 'PSA' and frf_nkv = 23 and frf_pay_tp = 'PP' then frf_value else 0 end) as t01s04k01_post,
    sum(case when frs_nst = 250 and frf_value_tp != 'QNT'and frf_nkv = 43 then frf_value else 0 end) as t01s04k02_all,
  -- -- допомога на дітей, над якими встановлено опіку чи піклування  -- 268 1.4
    sum(case when frs_nst = 268 and frf_value_tp = 'QNT' then frf_value else null end)as t01s05_cnt,  -- к-ть справ?
    sum(case when frs_nst = 268 and frf_value_tp != 'QNT' then frf_value else 0 end) as t01s05_sum,
    sum(case when frs_nst = 268 and frf_value_tp != 'QNT'and frf_nkv = 23 then frf_value else 0 end) as t01s05k01_all,
    sum(case when frs_nst = 268 and frf_value_tp = 'BSA' and frf_nkv = 23 and frf_pay_tp = 'PB' then frf_value else 0 end) as t01s05k01_bank,
    sum(case when frs_nst = 268 and frf_value_tp = 'PSA' and frf_nkv = 23 and frf_pay_tp = 'PP' then frf_value else 0 end) as t01s05k01_post,
    sum(case when frs_nst = 268 and frf_value_tp != 'QNT'and frf_nkv = 43 then frf_value else 0 end) as t01s05k02_all,
  -- -- допомога на дітей одиноким матерям   -- 267 1.5
    sum(case when frs_nst = 267 and frf_value_tp = 'QNT' then frf_value else null end)as t01s06_cnt,  -- к-ть справ?
    sum(case when frs_nst = 267 and frf_value_tp != 'QNT' then frf_value else 0 end) as t01s06_sum,
    sum(case when frs_nst = 267 and frf_value_tp != 'QNT'and frf_nkv = 23 then frf_value else 0 end) as t01s06k01_all,
    sum(case when frs_nst = 267 and frf_value_tp = 'BSA' and frf_nkv = 23 and frf_pay_tp = 'PB' then frf_value else 0 end) as t01s06k01_bank,
    sum(case when frs_nst = 267 and frf_value_tp = 'PSA' and frf_nkv = 23 and frf_pay_tp = 'PP' then frf_value else 0 end) as t01s06k01_post,
    sum(case when frs_nst = 267 and frf_value_tp != 'QNT'and frf_nkv = 43 then frf_value else 0 end) as t01s06k02_all,
  -- -- допомога особі, яка доглядає за хворою дитиною    -- 265 1.6
    sum(case when frs_nst = 265 and frf_value_tp = 'QNT' then frf_value else null end)as t01s07_cnt,  -- к-ть справ?
    sum(case when frs_nst = 265 and frf_value_tp != 'QNT' then frf_value else 0 end) as t01s07_sum,
    sum(case when frs_nst = 265 and frf_value_tp != 'QNT'and frf_nkv = 23 then frf_value else 0 end) as t01s07k01_all,
    sum(case when frs_nst = 265 and frf_value_tp = 'BSA' and frf_nkv = 23 and frf_pay_tp = 'PB' then frf_value else 0 end) as t01s07k01_bank,
    sum(case when frs_nst = 265 and frf_value_tp = 'PSA' and frf_nkv = 23 and frf_pay_tp = 'PP' then frf_value else 0 end) as t01s07k01_post,
    sum(case when frs_nst = 265 and frf_value_tp != 'QNT'and frf_nkv = 43 then frf_value else 0 end) as t01s07k02_all,
  -- виплата державної соціальної допомоги малозабезпеченим сім'ям
    sum(case when frs_nst = 249 and frf_value_tp = 'QNT' then frf_value else null end)as t01s08_cnt,  -- к-ть справ?
    sum(case when frs_nst = 249 and frf_value_tp != 'QNT' then frf_value else 0 end) as t01s08_sum,
    sum(case when frs_nst = 249 and frf_value_tp != 'QNT'and frf_nkv = 23 then frf_value else 0 end) as t01s08k01_all,
    sum(case when frs_nst = 249 and frf_value_tp = 'BSA' and frf_nkv = 23 and frf_pay_tp = 'PB' then frf_value else 0 end) as t01s08k01_bank,
    sum(case when frs_nst = 249 and frf_value_tp = 'PSA' and frf_nkv = 23 and frf_pay_tp = 'PP' then frf_value else 0 end) as t01s08k01_post,
    sum(case when frs_nst = 249 and frf_value_tp != 'QNT'and frf_nkv = 43 then frf_value else 0 end) as t01s08k02_all,
  -- ?????????? виплата тимчасової державної  допомоги  дітям,  батьки  яких  ухиляються  від  сплати аліментів,  не  мають  можливості  утримувати  дитину  або   місце проживання їх невідоме
    sum(case when frs_nst = 9999 and frf_value_tp = 'QNT' then frf_value else null end)as t01s09_cnt,  -- к-ть справ?
    sum(case when frs_nst = 9999 and frf_value_tp != 'QNT' then frf_value else 0 end) as t01s09_sum,
    sum(case when frs_nst = 9999 and frf_value_tp != 'QNT'and frf_nkv = 23 then frf_value else 0 end) as t01s09k01_all,
    sum(case when frs_nst = 9999 and frf_value_tp = 'BSA' and frf_nkv = 23 and frf_pay_tp = 'PB' then frf_value else 0 end) as t01s09k01_bank,
    sum(case when frs_nst = 9999 and frf_value_tp = 'PSA' and frf_nkv = 23 and frf_pay_tp = 'PP' then frf_value else 0 end) as t01s09k01_post,
    sum(case when frs_nst = 9999 and frf_value_tp != 'QNT'and frf_nkv = 43 then frf_value else 0 end) as t01s09k02_all,
  -- виплата державної соціальної допомоги особам з інвалідністю з дитинства та дітям з інвалідністю
    sum(case when frs_nst = 248 and frf_value_tp = 'QNT' then frf_value else null end)as t01s10_cnt,  -- к-ть справ?
    sum(case when frs_nst = 248 and frf_value_tp != 'QNT' then frf_value else 0 end) as t01s10_sum,
    sum(case when frs_nst = 248 and frf_value_tp != 'QNT'and frf_nkv = 23 then frf_value else 0 end) as t01s10k01_all,
    sum(case when frs_nst = 248 and frf_value_tp = 'BSA' and frf_nkv = 23 and frf_pay_tp = 'PB' then frf_value else 0 end) as t01s10k01_bank,
    sum(case when frs_nst = 248 and frf_value_tp = 'PSA' and frf_nkv = 23 and frf_pay_tp = 'PP' then frf_value else 0 end) as t01s10k01_post,
    sum(case when frs_nst = 248 and frf_value_tp != 'QNT'and frf_nkv = 43 then frf_value else 0 end) as t01s10k02_all
  from uss_esr.v_funding_request  fr
  join uss_esr.v_fr_detail_service frs on frs.frs_fr = fr.fr_id
  join uss_esr.v_fr_detail_full frf on frf.frf_fr = fr.fr_id and frf.frf_frs = frs.frs_id
  --join v_opfu on org_id = fr.com_org
  where 1=1
    and fr.fr_nbg = 1 -- Бюджетна програма КПК 2501030
    and fr.fr_month = to_date(']'
            || TO_CHAR (l_dt, 'dd.mm.yyyy')
            || q'[', 'dd.mm.yyyy')
    and fr.fr_st = 'R'--- 4test 'Z' -- Затверджено
    and fr.fr_own_tp = 'CONS'
    and frs_nst in (248, 268, 249, 265, 267, 250, 269, 251, 274)]'
            || CASE
                   WHEN p_fr_tp = 'ALL' THEN ''
                   ELSE ' and fr_tp = ''' || p_fr_tp || ''''
               END
            || q'[
  group by fr.com_org/*org_org*/
) dd
on dd.com_org = o.org_id
order by o.x_num]';


        l_sql_02 :=
               q'[select
o.x_num as t02_rn,
o.org_id as t02_code,
nvl(kaot_name, org_name) as t02_name,
dd.*
from(
select
row_number()over(order by decode(org_id, 53000, 'яяя', uss_esr.tools.GetOpfuParam('KAOT_NAME',o.org_id))) as x_num,
uss_esr.tools.GetOpfuParam('KAOT_NAME',o.org_id) as kaot_name,
o.* from v_opfu o where 1=1
]'
            || CASE
                   WHEN p_org_id = 50000
                   THEN
                       ' and o.org_org = 50000 and org_id not in (54300, 54000)'
                   ELSE
                       ' and org_id = ' || p_org_id
               END
            || q'[
) o

left join (
  select
    com_org,
-- допомога на дітей, які виховуються у багатодітних сім'ях
    sum(case when frs_nst = 9999 and frf_value_tp = 'QNT' then frf_value else null end)as t02s01_cnt,  -- к-ть справ?
    sum(case when frs_nst = 9999 and frf_value_tp != 'QNT' then frf_value else 0 end) as t02s01_sum,
    sum(case when frs_nst = 9999 and frf_value_tp != 'QNT'and frf_nkv = 23 then frf_value else 0 end) as t02s01k01_all,
    sum(case when frs_nst = 9999 and frf_value_tp = 'BSA' and frf_nkv = 23 and frf_pay_tp = 'PB' then frf_value else 0 end) as t02s01k01_bank,
    sum(case when frs_nst = 9999 and frf_value_tp = 'PSA' and frf_nkv = 23 and frf_pay_tp = 'PP' then frf_value else 0 end) as t02s01k01_post,
    sum(case when frs_nst = 9999 and frf_value_tp != 'QNT'and frf_nkv = 43 then frf_value else 0 end) as t02s01k02_all,
-- державна соціальна допомога на дітей-сиріт та дітей, позбавлених батьківського піклування та грошового забезпечення батькам-вихователям і прийомним батькам за надання соціальних послуг у дитячих будинках сімейного типу та прийомних сім’ях, здійснення видатків на сплату за них єдиного внеску на загальнообов’язкове державне соціальне страхування
    sum(case when frs_nst = 9999 and frf_value_tp = 'QNT' then frf_value else null end)as t02s02_cnt,  -- к-ть справ?
    sum(case when frs_nst = 9999 and frf_value_tp != 'QNT' then frf_value else 0 end) as t02s02_sum,
    sum(case when frs_nst = 9999 and frf_value_tp != 'QNT'and frf_nkv = 23 then frf_value else 0 end) as t02s02k01_all,
    sum(case when frs_nst = 9999 and frf_value_tp = 'BSA' and frf_nkv = 23 and frf_pay_tp = 'PB' then frf_value else 0 end) as t02s02k01_bank,
    sum(case when frs_nst = 9999 and frf_value_tp = 'PSA' and frf_nkv = 23 and frf_pay_tp = 'PP' then frf_value else 0 end) as t02s02k01_post,
    sum(case when frs_nst = 9999 and frf_value_tp != 'QNT'and frf_nkv = 43 then frf_value else 0 end) as t02s02k02_all,
-- -- державна соціальна допомога на дітей-сиріт та дітей, позбавлених батьківського піклування та грошового забезпечення батькам-вихователям і прийомним батькам за надання соціальних послуг у дитячих будинках сімейного типу, здійснення видатків на сплату за них єдиного внеску на загальнообов’язкове державне соціальне страхування
    sum(case when frs_nst = 9999 and frf_value_tp = 'QNT' then frf_value else null end)as t02s03_cnt,  -- к-ть справ?
    sum(case when frs_nst = 9999 and frf_value_tp != 'QNT' then frf_value else 0 end) as t02s03_sum,
    sum(case when frs_nst = 9999 and frf_value_tp != 'QNT'and frf_nkv = 23 then frf_value else 0 end) as t02s03k01_all,
    sum(case when frs_nst = 9999 and frf_value_tp = 'BSA' and frf_nkv = 23 and frf_pay_tp = 'PB' then frf_value else 0 end) as t02s03k01_bank,
    sum(case when frs_nst = 9999 and frf_value_tp = 'PSA' and frf_nkv = 23 and frf_pay_tp = 'PP' then frf_value else 0 end) as t02s03k01_post,
    sum(case when frs_nst = 9999 and frf_value_tp != 'QNT'and frf_nkv = 43 then frf_value else 0 end) as t02s03k02_all,
-- -- державна соціальна допомога на дітей-сиріт та дітей, позбавлених батьківського піклування та грошового забезпечення батькам-вихователям і прийомним батькам за надання соціальних послуг у прийомних сім’ях, здійснення видатків на сплату за них єдиного внеску на загальнообов’язкове державне соціальне страхування
    sum(case when frs_nst = 9999 and frf_value_tp = 'QNT' then frf_value else null end)as t02s04_cnt,  -- к-ть справ?
    sum(case when frs_nst = 9999 and frf_value_tp != 'QNT' then frf_value else 0 end) as t02s04_sum,
    sum(case when frs_nst = 9999 and frf_value_tp != 'QNT'and frf_nkv = 23 then frf_value else 0 end) as t02s04k01_all,
    sum(case when frs_nst = 9999 and frf_value_tp = 'BSA' and frf_nkv = 23 and frf_pay_tp = 'PB' then frf_value else 0 end) as t02s04k01_bank,
    sum(case when frs_nst = 9999 and frf_value_tp = 'PSA' and frf_nkv = 23 and frf_pay_tp = 'PP' then frf_value else 0 end) as t02s04k01_post,
    sum(case when frs_nst = 9999 and frf_value_tp != 'QNT'and frf_nkv = 43 then frf_value else 0 end) as t02s04k02_all,
-- оплата послуг патронатного вихователя, виплата соціальної допомоги на утримання дитини в сім’ї патронатного вихователя та здійснення видатків на сплату за патронатного вихователя єдиного внеску на загальнообов’язкове державне соціальне страхування
    sum(case when frs_nst = 9999 and frf_value_tp = 'QNT' then frf_value else null end)as t02s05_cnt,  -- к-ть справ?
    sum(case when frs_nst = 9999 and frf_value_tp != 'QNT' then frf_value else 0 end) as t02s05_sum,
    sum(case when frs_nst = 9999 and frf_value_tp != 'QNT'and frf_nkv = 23 then frf_value else 0 end) as t02s05k01_all,
    sum(case when frs_nst = 9999 and frf_value_tp = 'BSA' and frf_nkv = 23 and frf_pay_tp = 'PB' then frf_value else 0 end) as t02s05k01_bank,
    sum(case when frs_nst = 9999 and frf_value_tp = 'PSA' and frf_nkv = 23 and frf_pay_tp = 'PP' then frf_value else 0 end) as t02s05k01_post,
    sum(case when frs_nst = 9999 and frf_value_tp != 'QNT'and frf_nkv = 43 then frf_value else 0 end) as t02s05k02_all,
-- підтримка  малих групових будинків
    sum(case when frs_nst = 9999 and frf_value_tp = 'QNT' then frf_value else null end)as t02s06_cnt,  -- к-ть справ?
    sum(case when frs_nst = 9999 and frf_value_tp != 'QNT' then frf_value else 0 end) as t02s06_sum,
    sum(case when frs_nst = 9999 and frf_value_tp != 'QNT'and frf_nkv = 23 then frf_value else 0 end) as t02s06k01_all,
    sum(case when frs_nst = 9999 and frf_value_tp = 'BSA' and frf_nkv = 23 and frf_pay_tp = 'PB' then frf_value else 0 end) as t02s06k01_bank,
    sum(case when frs_nst = 9999 and frf_value_tp = 'PSA' and frf_nkv = 23 and frf_pay_tp = 'PP' then frf_value else 0 end) as t02s06k01_post,
    sum(case when frs_nst = 9999 and frf_value_tp != 'QNT'and frf_nkv = 43 then frf_value else 0 end) as t02s06k02_all
  from uss_esr.v_funding_request  fr
  join uss_esr.v_fr_detail_service frs on frs.frs_fr = fr.fr_id
  join uss_esr.v_fr_detail_full frf on frf.frf_fr = fr.fr_id and frf.frf_frs = frs.frs_id
  --join v_opfu on org_id = fr.com_org
  where 1=1
    and fr.fr_nbg = 1 -- Бюджетна програма КПК 2501030
    and fr.fr_month = to_date(']'
            || TO_CHAR (l_dt, 'dd.mm.yyyy')
            || q'[', 'dd.mm.yyyy')
    and fr.fr_st = 'R'--- 4test 'Z' -- Затверджено
    and fr.fr_own_tp = 'CONS'
    and frs_nst in (-9999)]'
            || CASE
                   WHEN p_fr_tp = 'ALL' THEN ''
                   ELSE ' and fr_tp = ''' || p_fr_tp || ''''
               END
            || q'[
  group by com_org
) dd
on dd.com_org = o.org_id
order by o.x_num]';


        l_sql_03 :=
               q'[select
o.x_num as t03_rn,
o.org_id as t03_code,
nvl(kaot_name, org_name) as t03_name,
dd.*
from(
select
row_number()over(order by decode(org_id, 53000, 'яяя', uss_esr.tools.GetOpfuParam('KAOT_NAME',o.org_id))) as x_num,
uss_esr.tools.GetOpfuParam('KAOT_NAME',o.org_id) as kaot_name,
o.* from v_opfu o where  1=1
]'
            || CASE
                   WHEN p_org_id = 50000
                   THEN
                       ' and o.org_org = 50000 and org_id not in (54300, 54000)'
                   ELSE
                       ' and org_id = ' || p_org_id
               END
            || q'[
) o
left join (
  select
    com_org,
-- 288	4  виплата державної соціальної допомоги особам, які не мають права на пенсію, та особам з інвалідністю
    sum(case when frs_nst = 288 and frf_value_tp = 'QNT' then frf_value else null end)as t03s01_cnt,  -- к-ть справ?
    sum(case when frs_nst = 288 and frf_value_tp != 'QNT' then frf_value else 0 end) as t03s01_sum,
    sum(case when frs_nst = 288 and frf_value_tp != 'QNT'and frf_nkv = 23 then frf_value else 0 end) as t03s01k01_all,
    sum(case when frs_nst = 288 and frf_value_tp = 'BSA' and frf_nkv = 23 and frf_pay_tp = 'PB' then frf_value else 0 end) as t03s01k01_bank,
    sum(case when frs_nst = 288 and frf_value_tp = 'PSA' and frf_nkv = 23 and frf_pay_tp = 'PP' then frf_value else 0 end) as t03s01k01_post,
    sum(case when frs_nst = 288 and frf_value_tp != 'QNT'and frf_nkv = 43 then frf_value else 0 end) as t03s01k02_all,
-- виплата державної соціальної допомоги на догляд
    sum(case when frs_nst = 9999 and frf_value_tp = 'QNT' then frf_value else null end)as t03s02_cnt,  -- к-ть справ?
    sum(case when frs_nst = 9999 and frf_value_tp != 'QNT' then frf_value else 0 end) as t03s02_sum,
    sum(case when frs_nst = 9999 and frf_value_tp != 'QNT'and frf_nkv = 23 then frf_value else 0 end) as t03s02k01_all,
    sum(case when frs_nst = 9999 and frf_value_tp = 'BSA' and frf_nkv = 23 and frf_pay_tp = 'PB' then frf_value else 0 end) as t03s02k01_bank,
    sum(case when frs_nst = 9999 and frf_value_tp = 'PSA' and frf_nkv = 23 and frf_pay_tp = 'PP' then frf_value else 0 end) as t03s02k01_post,
    sum(case when frs_nst = 9999 and frf_value_tp != 'QNT'and frf_nkv = 43 then frf_value else 0 end) as t03s02k02_all,
-- виплата тимчасової державної соціальної допомоги непрацюючій особі, яка досягла загального пенсійного віку, але не набула права на пенсійну виплату
    sum(case when frs_nst = 9999 and frf_value_tp = 'QNT' then frf_value else null end)as t03s03_cnt,  -- к-ть справ?
    sum(case when frs_nst = 9999 and frf_value_tp != 'QNT' then frf_value else 0 end) as t03s03_sum,
    sum(case when frs_nst = 9999 and frf_value_tp != 'QNT'and frf_nkv = 23 then frf_value else 0 end) as t03s03k01_all,
    sum(case when frs_nst = 9999 and frf_value_tp = 'BSA' and frf_nkv = 23 and frf_pay_tp = 'PB' then frf_value else 0 end) as t03s03k01_bank,
    sum(case when frs_nst = 9999 and frf_value_tp = 'PSA' and frf_nkv = 23 and frf_pay_tp = 'PP' then frf_value else 0 end) as t03s03k01_post,
    sum(case when frs_nst = 9999 and frf_value_tp != 'QNT'and frf_nkv = 43 then frf_value else 0 end) as t03s03k02_all,
-- 256	10 виплата щомісячної компенсаційної виплати непрацюючій працездатній особі, яка доглядає за особою з інвалідністю I групи, а також за особою, яка досягла 80-річного віку
    sum(case when frs_nst = 256 and frf_value_tp = 'QNT' then frf_value else null end)as t03s04_cnt,  -- к-ть справ?
    sum(case when frs_nst = 256 and frf_value_tp != 'QNT' then frf_value else 0 end) as t03s04_sum,
    sum(case when frs_nst = 256 and frf_value_tp != 'QNT'and frf_nkv = 23 then frf_value else 0 end) as t03s04k01_all,
    sum(case when frs_nst = 256 and frf_value_tp = 'BSA' and frf_nkv = 23 and frf_pay_tp = 'PB' then frf_value else 0 end) as t03s04k01_bank,
    sum(case when frs_nst = 256 and frf_value_tp = 'PSA' and frf_nkv = 23 and frf_pay_tp = 'PP' then frf_value else 0 end) as t03s04k01_post,
    sum(case when frs_nst = 256 and frf_value_tp != 'QNT'and frf_nkv = 43 then frf_value else 0 end) as t03s04k02_all,
-- відшкодування вартості послуги з догляду за дитиною до трьох років „муніципальна няня”
    sum(case when frs_nst = 9999 and frf_value_tp = 'QNT' then frf_value else null end)as t03s05_cnt,  -- к-ть справ?
    sum(case when frs_nst = 9999 and frf_value_tp != 'QNT' then frf_value else 0 end) as t03s05_sum,
    sum(case when frs_nst = 9999 and frf_value_tp != 'QNT'and frf_nkv = 23 then frf_value else 0 end) as t03s05k01_all,
    sum(case when frs_nst = 9999 and frf_value_tp = 'BSA' and frf_nkv = 23 and frf_pay_tp = 'PB' then frf_value else 0 end) as t03s05k01_bank,
    sum(case when frs_nst = 9999 and frf_value_tp = 'PSA' and frf_nkv = 23 and frf_pay_tp = 'PP' then frf_value else 0 end) as t03s05k01_post,
    sum(case when frs_nst = 9999 and frf_value_tp != 'QNT'and frf_nkv = 43 then frf_value else 0 end) as t03s05k02_all
  from uss_esr.v_funding_request  fr
  join uss_esr.v_fr_detail_service frs on frs.frs_fr = fr.fr_id
  join uss_esr.v_fr_detail_full frf on frf.frf_fr = fr.fr_id and frf.frf_frs = frs.frs_id
  join v_opfu on org_id = fr.com_org
  where 1=1
    and fr.fr_nbg = 1 -- Бюджетна програма КПК 2501030
    and fr.fr_month = to_date(']'
            || TO_CHAR (l_dt, 'dd.mm.yyyy')
            || q'[', 'dd.mm.yyyy')
    and fr.fr_st = 'R'--- 4test 'Z' -- Затверджено
    and fr.fr_own_tp = 'CONS'
    and frs_nst in (-9999)]'
            || CASE
                   WHEN p_fr_tp = 'ALL' THEN ''
                   ELSE ' and fr_tp = ''' || p_fr_tp || ''''
               END
            || q'[
  group by com_org
) dd
on dd.com_org = o.org_id
order by o.x_num]';


        l_sql_04 :=
               q'[select
o.x_num as t04_rn,
o.org_id as t04_code,
nvl(kaot_name, o.org_name) as t04_name
from(
select
row_number()over(order by decode(org_id, 53000, 'яяя', uss_esr.tools.GetOpfuParam('KAOT_NAME',o.org_id))) as x_num,
uss_esr.tools.GetOpfuParam('KAOT_NAME',o.org_id) as kaot_name,
o.* from v_opfu o where  1=1
]'
            || CASE
                   WHEN p_org_id = 50000
                   THEN
                       ' and o.org_org = 50000 and org_id not in (54300, 54000)'
                   ELSE
                       ' and org_id = ' || p_org_id
               END
            || q'[
) o
order by o.x_num]';

        --dbms_output.put_line(l_sql_01) ;

        EXECUTE IMMEDIATE 'select count(1) from(' || l_sql_04 || ')'
            INTO l_rows_cnt;

        RDM$RTFL.AddParam (l_jbr_id, 'p_rows_cnt', l_rows_cnt);

        --dbms_output.put_line(l_sql_01) ;
        RDM$RTFL.AddDataSet (l_jbr_id, 'ds_t01', l_sql_01);
        RDM$RTFL.AddDataSet (l_jbr_id, 'ds_t02', l_sql_02);
        RDM$RTFL.AddDataSet (l_jbr_id, 'ds_t03', l_sql_03);
        RDM$RTFL.AddDataSet (l_jbr_id, 'ds_t04', l_sql_04);

        RDM$RTFL.PutReportToWorkingQueue (l_jbr_id);
        RETURN l_jbr_id;
    END;

    /*FUNCTION PAY_NEED_R1(p_rt_id in number, p_dt in date) RETURN NUMBER IS
      l_sum  number(18,2);
      l_cnt  number(14,0);
      l_adds_str  varchar2(32000) := '';
      l_jbr_id NUMBER;
      l_dt DATE := trunc(p_dt, 'MM');
    BEGIN
      l_jbr_id := RDM$RTFL.InitReport(p_rt_id);
      --raise_application_error(-20000, p_dt || ';' || p_org_id || ';' || p_npc_id);

    --    RDM$RTFL.AddDataSet(l_jbr_id, 'ds',  '' );
    --    RDM$RTFL.AddDataSet(l_jbr_id, 'ds_summary', '');

    for gg in (select 'g'||lpad(row_number() over(order by nst_id), 2, '0') as g_num, s.nst_id, s.nst_code, s.nst_name
               from uss_ndi.v_ndi_service_type s where 252 in (nst_id, nst_nst_main) and s.history_status = 'A')
    loop
      for rr in --(select 'r'||lpad(row_number() over(order by org_id), 2, '0') as o_num, org_id, o.org_name from v_opfu o where o.org_org = 50000)
        ( select
          o_num, x.x_num, org_id, o.org_name
          from(
          select 'r'||lpad(level, 2, '0') as o_num , level as x_num from dual connect by level <= 25
          ) x
          left join (
          select case org_id when 51800 then 6 when 5300 then 10 else null end as x_num , o.* from v_opfu o where o.org_org = 50000
          ) o  on x.x_num = o.x_num
          order by x.x_num  )
      loop
        for tt in (
          select 't'||lpad(level, 2, '0') as  t_num from dual  connect by level <= 3
          )
        loop
          begin
            select
              nst_prs_sum, nst_prs_cnt into l_sum, l_cnt
            from (
            select --org_org,  nst.nst_id, nst.nst_code, nst.nst_name, r.pe_id, r.com_org, r.pe_row_cnt, r.pe_sum, s.prs_sum
              org_org,  nst.nst_id, sum(s.prs_sum) as nst_prs_sum, count(1) as nst_prs_cnt
            from payroll_reestr r
            join pr_sheet s  on prs_pr = r.pe_src_entity --and r.pe_ = s.prs_npt
            join uss_ndi.v_ndi_payment_type t on t.npt_id = s.prs_npt and r.pe_npc = t.npt_npc
            join uss_ndi.v_ndi_npt_config c on  c.nptc_npt = s.prs_npt
            join uss_ndi.v_ndi_service_type nst on nst.nst_id = c.nptc_nst
            join v_opfu on org_id = com_org
            where r.pe_src_entity = 48
            group by org_org,  nst.nst_id
            ) pr
            where 1=1
              and pr.org_org = rr.org_id
              and pr.nst_id = gg.nst_id;
          exception when others then
              l_sum  := 0;
              l_cnt  := 0;
          end;
          -- rdm$rtfl.addparam(v_jbr_id, 'app_name', TRIM(data_cur.app_name));
          --l_adds_str := q'[rdm$rtfl.addparam(v_jbr_id, 't01]'||gg.g_num||rr.o_num||q'[c01', to_char(]'||l_cnt||'));';
          --l_adds_str := q'[rdm$rtfl.addparam(v_jbr_id, 't01]'||gg.g_num||rr.o_num||q'[c02', to_char(]'||l_sum||'));';
          RDM$RTFL.AddParam(l_jbr_id, tt.t_num||gg.g_num||rr.o_num||'c01', to_char(l_cnt));
          RDM$RTFL.AddParam(l_jbr_id, tt.t_num||gg.g_num||rr.o_num||'c02', to_char(l_sum));
        end loop;
      end loop;
    end loop;

      RDM$RTFL.PutReportToWorkingQueue(l_jbr_id);
      RETURN l_jbr_id;
    END;*/


    FUNCTION USE_FUNDS_REG (p_rt_id    IN NUMBER,
                            p_dt       IN DATE,
                            p_org_id   IN NUMBER)
        RETURN NUMBER
    IS
        --l_sum  number(18,2);
        --l_cnt  number(14,0);
        --l_rows_cnt  number(14,0);
        --l_adds_str  varchar2(32000) := '';
        --l_sql_01    varchar2(32000) := '';
        --l_sql_02    varchar2(32000) := '';
        --l_sql_03    varchar2(32000) := '';
        --l_sql_04    varchar2(32000) := '';
        l_jbr_id      NUMBER;
        l_dt          DATE := TRUNC (p_dt, 'Q');
        l_start_dt    DATE := TRUNC (p_dt, 'YYYY');
        l_stop_dt     DATE := ADD_MONTHS (TRUNC (p_dt, 'Q'), 3); -- не включаючи ...
        --l_start_str varchar2(100) := ' to_date('''||to_char(l_start_dt, 'dd.mm.yyyy')||''', ''dd.mm.yyyy'') ';
        --l_stop_str  varchar2(100) := ' to_date('''||to_char(l_stop_dt, 'dd.mm.yyyy')||''', ''dd.mm.yyyy'') ';
        l_qq          VARCHAR2 (10) := TO_CHAR (l_dt, 'Q');
        l_org_name    VARCHAR2 (1000);
        l_org_name2   VARCHAR2 (1000);
    --l_rpt     clob;
    BEGIN
        l_jbr_id := RDM$RTFL.InitReport (p_rt_id);

        --raise_application_error(-20000, p_dt || ';' || p_org_id || ';' || p_npc_id);

        --dbms_output.put_line(l_sql_01) ;

        --execute immediate 'select count(1) from('||l_sql_04||')' into l_rows_cnt;
        IF p_org_id = 50000
        THEN
            l_org_name := 'Міністерство соціальної політики';
            l_org_name2 := 'МСП';
        ELSIF p_org_id = 53000
        THEN
            l_org_name := 'по м. Києву';
            l_org_name2 := 'Київ';
        ELSE
            SELECT uss_esr.tools.GetOpfuParam ('KAOT_NAME', o.org_id)
              INTO l_org_name
              FROM v_opfu o
             WHERE org_id = p_org_id;

            l_org_name2 := l_org_name;

            IF LENGTH (l_org_name) > 0
            THEN
                l_org_name :=
                       'по '
                    || SUBSTR (l_org_name, 1, LENGTH (l_org_name) - 1)
                    || 'ій області';
            ELSE
                l_org_name := p_org_id;
            END IF;
        END IF;

        RDM$RTFL.AddParam (l_jbr_id, 'QQ', l_qq);
        RDM$RTFL.AddParam (l_jbr_id, 'YYYY', TO_CHAR (l_dt, 'YYYY'));
        RDM$RTFL.AddParam (l_jbr_id, 'YYYY2', TO_CHAR (l_dt, 'YYYY') + 1);
        RDM$RTFL.AddParam (l_jbr_id, 'org_name', l_org_name);
        RDM$RTFL.AddParam (l_jbr_id, 'org_name2', l_org_name2);

        -- Кількість здіснених виплат з початку року + суми
        FOR rr
            IN --(select 'r'||lpad(row_number() over(order by org_id), 2, '0') as o_num, org_id, o.org_name from v_opfu o where o.org_org = 50000)
               (SELECT LPAD (x_num, 2, '0') AS row_num, p_nst_cnt, p_nst_sum
                  FROM (SELECT 1
                                   AS x_num,
                               '1'
                                   AS x_row_code,
                               q'[Відшкодування вартості послуги з догляду за дитиною до трьох років „муніципальна няня”]'
                                   AS x_pay_type,
                               2730
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               1
                                   AS x_mergedown,
                               'cell_grey'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 2
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[Витрати на поштові операції за напрямом]'
                                   AS x_pay_type,
                               2240
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_grey'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 3
                                   AS x_num,
                               '2'
                                   AS x_row_code,
                               q'[Надання при народженні дитини одноразової натуральної допомоги "пакунок малюка",виплата грошової компенсації вартості одноразової натуральної допомоги "пакунок малюка"]'
                                   AS x_pay_type,
                               NULL
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               3
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 4
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[Одноразова натуральна допомога "пакунок малюка"]'
                                   AS x_pay_type,
                               2210
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 5
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[Грошова компенсація вартості одноразової натуральної допомоги "пакунок малюка"]'
                                   AS x_pay_type,
                               2730
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 6
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[Винагорода централізованій закупівельній організації]'
                                   AS x_pay_type,
                               2240
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 7
                                   AS x_num,
                               '3'
                                   AS x_row_code,
                               q'[Допомога на дітей, які виховуються у багатодітних сім'ях]'
                                   AS x_pay_type,
                               2730
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               1
                                   AS x_mergedown,
                               'cell_grey'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 8
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[Витрати на поштові операції за напрямом]'
                                   AS x_pay_type,
                               2240
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_grey'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 9
                                   AS x_num,
                               '4'
                                   AS x_row_code,
                               q'[Виплата державної допомоги у зв’язку з вагітністю та пологами, допомоги при народженні дитини, допомоги на дітей, над якими встановлено опіку чи піклування, допомоги на дітей одиноким матерям, допомоги при усиновленні дитини, допомоги на дітей, хворих на тяжкі перинатальні ураження нервової системи, тяжкі вроджені вади розвитку, рідкісні орфанні захворювання, онкологічні, онкогематологічні захворювання, дитячий церебральний параліч, тяжкі психічні розлади, цукровий діабет I типу (інсулінозалежний), гострі або хронічні захворювання нирок IV ступеня, допомоги на дитину, яка отримала тяжку травму, потребує трансплантації органа, потребує паліативної допомоги, яким не встановлено інвалідності ]'
                                   AS x_pay_type,
                               2730
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               13
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 10
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[Витрати на поштові операції за напрямом]'
                                   AS x_pay_type,
                               2240
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 11
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[Допомога на дітей одиноким матерям ]'
                                   AS x_pay_type,
                               2730
                                   AS x_kekv,
                               267
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 12
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[Витрати на поштові операції за напрямом]'
                                   AS x_pay_type,
                               2240
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 13
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[Допомога при народженні дитини та усиновленні]'
                                   AS x_pay_type,
                               2730
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 14
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[одноразова частина допомоги при народженні та усиновленні дитини]'
                                   AS x_pay_type,
                               2730
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 15
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[щомісячна допомога на дітей при народженні та усиновлені]'
                                   AS x_pay_type,
                               2730
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 16
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[Витрати на поштові операції за напрямом]'
                                   AS x_pay_type,
                               2240
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 17
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[Допомога на дітей, над якими встановлено опіку чи піклування ]'
                                   AS x_pay_type,
                               2730
                                   AS x_kekv,
                               268
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 18
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[Витрати на поштові операції за напрямом]'
                                   AS x_pay_type,
                               2240
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 19
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[Допомога у зв'язку з вагітністю та пологами]'
                                   AS x_pay_type,
                               2730
                                   AS x_kekv,
                               251
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 20
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[Витрати на поштові операції за напрямом]'
                                   AS x_pay_type,
                               2240
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 21
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[Допомога особі, яка доглядає за хворою дитиною]'
                                   AS x_pay_type,
                               2730
                                   AS x_kekv,
                               265
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 22
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[Витрати на поштові операції за напрямом]'
                                   AS x_pay_type,
                               2240
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 23
                                   AS x_num,
                               '5'
                                   AS x_row_code,
                               q'[Виплата тимчасової державної допомоги дітям, батьки яких  ухиляються  від  сплати аліментів, не мають можливості  утримувати дитину або місце проживання їх невідоме]'
                                   AS x_pay_type,
                               2730
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               1
                                   AS x_mergedown,
                               'cell_grey'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 24
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[Витрати на поштові операції за напрямом]'
                                   AS x_pay_type,
                               2240
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_grey'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 25
                                   AS x_num,
                               '6'
                                   AS x_row_code,
                               q'[Допомога на дітей-сиріт та дітей, позбавлених батьківського піклування, та грошового забезпечення батькам-вихователям і прийомним батькам за надання соціальних послуг у дитячих будинках сімейного типу та прийомних сім’ях, здійснення видатків на сплату за них єдиного внеску на загальнообов’язкове державне соціальне страхування ]'
                                   AS x_pay_type,
                               2730
                                   AS x_kekv,
                               275
                                   AS x_nst_id,
                               1
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 26
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[Витрати на поштові операції за напрямом]'
                                   AS x_pay_type,
                               2240
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 27
                                   AS x_num,
                               '6.1'
                                   AS x_row_code,
                               q'[державна соціальна допомога на дітей, які виховуються у дитячих будинках сімейного типу]'
                                   AS x_pay_type,
                               2730
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               1
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 28
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[Витрати на поштові операції за напрямом]'
                                   AS x_pay_type,
                               2240
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 29
                                   AS x_num,
                               '6.2'
                                   AS x_row_code,
                               q'[державна соціальна допомога на дітей, які виховуються у прийомних сім’ях]'
                                   AS x_pay_type,
                               2730
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               1
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 30
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[Витрати на поштові операції за напрямом]'
                                   AS x_pay_type,
                               2240
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 31
                                   AS x_num,
                               '7'
                                   AS x_row_code,
                               q'[Оплата послуг патронатного вихователя, виплату соціальної допомоги на утримання дитини в сім’ї патронатного вихователя та здійснення видатків на сплату за патронатного вихователя єдиного внеску на загальнообов’язкове державне соціальне страхування ]'
                                   AS x_pay_type,
                               2730
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               1
                                   AS x_mergedown,
                               'cell_grey'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 32
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[Витрати на поштові операції за напрямом]'
                                   AS x_pay_type,
                               2240
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_grey'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 33
                                   AS x_num,
                               '8'
                                   AS x_row_code,
                               q'[Виплата державної соціальної допомоги особам з інвалідністю з дитинства та дітям з інвалідністю]'
                                   AS x_pay_type,
                               2730
                                   AS x_kekv,
                               248
                                   AS x_nst_id,
                               1
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 34
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[Витрати на поштові операції за напрямом]'
                                   AS x_pay_type,
                               2240
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 35
                                   AS x_num,
                               '9'
                                   AS x_row_code,
                               q'[Допомога особі, яка проживає разом з особою з інвалідністю I чи II групи внаслідок психічного розладу, яка за висновком лікарської комісії медичного закладу потребує постійного стороннього догляду, на догляд за нею]'
                                   AS x_pay_type,
                               2730
                                   AS x_kekv,
                               274
                                   AS x_nst_id,
                               1
                                   AS x_mergedown,
                               'cell_grey'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 36
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[Витрати на поштові операції за напрямом]'
                                   AS x_pay_type,
                               2240
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_grey'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 37
                                   AS x_num,
                               '10'
                                   AS x_row_code,
                               q'[Допомога особам, які не мають права на пенсію, та особам з інвалідністю]'
                                   AS x_pay_type,
                               2730
                                   AS x_kekv,
                               288
                                   AS x_nst_id,
                               1
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 38
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[Витрати на поштові операції за напрямом]'
                                   AS x_pay_type,
                               2240
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 39                          AS x_num,
                               '11'                        AS x_row_code,
                               q'[Допомога на догляд]'     AS x_pay_type,
                               2730                        AS x_kekv,
                               NULL                        AS x_nst_id,
                               1                           AS x_mergedown,
                               'cell_grey'                 AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 40
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[Витрати на поштові операції за напрямом]'
                                   AS x_pay_type,
                               2240
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_grey'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 41
                                   AS x_num,
                               '12'
                                   AS x_row_code,
                               q'[Допомога малозабезпеченим сім'ям ]'
                                   AS x_pay_type,
                               2730
                                   AS x_kekv,
                               249
                                   AS x_nst_id,
                               1
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 42
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[Витрати на поштові операції за напрямом]'
                                   AS x_pay_type,
                               2240
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 43
                                   AS x_num,
                               '13'
                                   AS x_row_code,
                               q'[Виплата  одноразової грошової допомоги на дітей з багатодітних малозабезпечених сімей для підготовки до навчального року  (постанова Кабінету Міністрів України від 04.08.2021 № 803)]'
                                   AS x_pay_type,
                               2730
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               1
                                   AS x_mergedown,
                               'cell_grey'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 44
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[Витрати на поштові операції за напрямом]'
                                   AS x_pay_type,
                               2240
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_grey'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 45
                                   AS x_num,
                               '14'
                                   AS x_row_code,
                               q'[Допомога непрацюючій особі, яка досягла загального пенсійного віку, але не набула права на пенсійну виплату]'
                                   AS x_pay_type,
                               2730
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               1
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 46
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[Витрати на поштові операції за напрямом]'
                                   AS x_pay_type,
                               2240
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 47
                                   AS x_num,
                               '15'
                                   AS x_row_code,
                               q'[Компенсаційна виплата непрацюючій працездатній особі, яка доглядає за особою з інвалідністю I групи, а також за особою, яка досягла 80-річного віку]'
                                   AS x_pay_type,
                               2730
                                   AS x_kekv,
                               256
                                   AS x_nst_id,
                               1
                                   AS x_mergedown,
                               'cell_grey'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 48
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[Витрати на поштові операції за напрямом]'
                                   AS x_pay_type,
                               2240
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_grey'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 49
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[КПКВК 2501030 "Виплата деяких видів допомог, компенсацій, грошового забезпечення та оплату послуг окремим категоріям населення"]'
                                   AS x_pay_type,
                               NULL
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               4
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL) tt
                       JOIN
                       (  /*select
                            nst_id as p_nst_id,
                            count(1)as p_nst_cnt,  -- к-ть справ?
                            sum(s.prs_sum) as p_nst_sum
                          from uss_esr.v_payroll_reestr r
                          join pay_order po on po.po_id = r.pe_po
                            join uss_esr.v_pr_sheet s  on prs_pr = r.pe_src_entity  and s.prs_nb = r.pe_nb and s.prs_pay_dt = r.pe_pay_dt
                            join uss_ndi.v_ndi_payment_type t on t.npt_id = s.prs_npt and r.pe_npc = t.npt_npc
                        --    join uss_ndi.v_ndi_payment_codes c on t.npt_npc = c.npc_id
                            join uss_ndi.v_ndi_npt_config c on  c.nptc_npt = s.prs_npt
                            join uss_ndi.v_ndi_service_type nst on nst.nst_id = c.nptc_nst
                            where r.pe_pay_dt >= l_start_dt -- trunc(l_dt, 'yyyy')
                              and r.pe_pay_dt < l_stop_dt -- add_months(trunc(l_dt, 'yyyy'), 12)
                              and r.pe_nbg = 1 -- Бюджетна програма КПК 2501030
                              and po.po_st = 'APPR'--  Проведено банком
                              and r.com_org in (select org_id from v_opfu o where p_org_id = 50000 or org_id = p_org_id or org_org = p_org_id)
                           group by nst_id*/
                          --#85222 LEV внесено зміни після переносу поля prs_npt в prsd_npt
                          SELECT nst_id                         AS p_nst_id,
                                 COUNT (DISTINCT (s.prs_id))    AS p_nst_cnt, -- к-ть справ?
                                 SUM (CASE
                                          WHEN sd.prsd_tp IN ('PWI', 'RDN')
                                          THEN
                                              sd.prsd_sum
                                          WHEN sd.prsd_tp IN ('PRUT',
                                                              'PRAL',
                                                              'PROZ',
                                                              'PROP')
                                          THEN
                                              0 - sd.prsd_sum
                                      END)                      AS p_nst_sum
                            FROM v_payroll_reestr r
                                 JOIN pay_order po ON po.po_id = r.pe_po
                                 JOIN v_pr_sheet s
                                     ON     s.prs_pr = r.pe_src_entity
                                        AND s.prs_nb = r.pe_nb
                                        AND s.prs_pay_dt = r.pe_pay_dt
                                 JOIN v_pr_sheet_detail sd
                                     ON sd.prsd_prs = s.prs_id
                                 JOIN uss_ndi.v_ndi_payment_type t
                                     ON     t.npt_id = sd.prsd_npt
                                        AND t.npt_npc = r.pe_npc
                                 JOIN uss_ndi.v_ndi_npt_config c
                                     ON c.nptc_npt = sd.prsd_npt
                                 JOIN uss_ndi.v_ndi_service_type nst
                                     ON nst.nst_id = c.nptc_nst
                           WHERE     r.pe_pay_dt >= l_start_dt -- trunc(l_dt, 'yyyy')
                                 AND r.pe_pay_dt < l_stop_dt -- add_months(trunc(l_dt, 'yyyy'), 12)
                                 AND r.pe_nbg = 1 -- Бюджетна програма КПК 2501030
                                 AND po.po_st = 'APPR'   --   Проведено банком
                                 AND r.com_org IN
                                         (SELECT org_id
                                            FROM v_opfu o
                                           WHERE    p_org_id = 50000
                                                 OR org_id = p_org_id
                                                 OR org_org = p_org_id)
                        GROUP BY nst_id) pp
                           ON pp.p_nst_id = tt.x_nst_id)
        LOOP
            --dbms_output.put_line() ;
            -- rdm$rtfl.addparam(v_jbr_id, 'app_name', TRIM(data_cur.app_name));
            --l_adds_str := q'[rdm$rtfl.addparam(v_jbr_id, 't01]'||gg.g_num||rr.o_num||q'[c01', to_char(]'||l_cnt||'));';
            --l_adds_str := q'[rdm$rtfl.addparam(v_jbr_id, 't01]'||gg.g_num||rr.o_num||q'[c02', to_char(]'||l_sum||'));';
            RDM$RTFL.AddParam (l_jbr_id,
                               'c_01_' || rr.row_num || '_0' || l_qq,
                               TO_CHAR (rr.p_nst_sum));
            RDM$RTFL.AddParam (l_jbr_id,
                               'c_01_' || rr.row_num || '_2' || l_qq,
                               TO_CHAR (rr.p_nst_sum));
        END LOOP;


        FOR rr
            IN --(select 'r'||lpad(row_number() over(order by org_id), 2, '0') as o_num, org_id, o.org_name from v_opfu o where o.org_org = 50000)
               (SELECT LPAD (x_num, 2, '0') AS row_num, nst_po_sum
                  FROM (SELECT 1
                                   AS x_num,
                               '1'
                                   AS x_row_code,
                               q'[Відшкодування вартості послуги з догляду за дитиною до трьох років „муніципальна няня”]'
                                   AS x_pay_type,
                               2730
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               1
                                   AS x_mergedown,
                               'cell_grey'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 2
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[Витрати на поштові операції за напрямом]'
                                   AS x_pay_type,
                               2240
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_grey'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 3
                                   AS x_num,
                               '2'
                                   AS x_row_code,
                               q'[Надання при народженні дитини одноразової натуральної допомоги "пакунок малюка",виплата грошової компенсації вартості одноразової натуральної допомоги "пакунок малюка"]'
                                   AS x_pay_type,
                               NULL
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               3
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 4
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[Одноразова натуральна допомога "пакунок малюка"]'
                                   AS x_pay_type,
                               2210
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 5
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[Грошова компенсація вартості одноразової натуральної допомоги "пакунок малюка"]'
                                   AS x_pay_type,
                               2730
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 6
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[Винагорода централізованій закупівельній організації]'
                                   AS x_pay_type,
                               2240
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 7
                                   AS x_num,
                               '3'
                                   AS x_row_code,
                               q'[Допомога на дітей, які виховуються у багатодітних сім'ях]'
                                   AS x_pay_type,
                               2730
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               1
                                   AS x_mergedown,
                               'cell_grey'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 8
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[Витрати на поштові операції за напрямом]'
                                   AS x_pay_type,
                               2240
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_grey'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 9
                                   AS x_num,
                               '4'
                                   AS x_row_code,
                               q'[Виплата державної допомоги у зв’язку з вагітністю та пологами, допомоги при народженні дитини, допомоги на дітей, над якими встановлено опіку чи піклування, допомоги на дітей одиноким матерям, допомоги при усиновленні дитини, допомоги на дітей, хворих на тяжкі перинатальні ураження нервової системи, тяжкі вроджені вади розвитку, рідкісні орфанні захворювання, онкологічні, онкогематологічні захворювання, дитячий церебральний параліч, тяжкі психічні розлади, цукровий діабет I типу (інсулінозалежний), гострі або хронічні захворювання нирок IV ступеня, допомоги на дитину, яка отримала тяжку травму, потребує трансплантації органа, потребує паліативної допомоги, яким не встановлено інвалідності ]'
                                   AS x_pay_type,
                               2730
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               13
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 10
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[Витрати на поштові операції за напрямом]'
                                   AS x_pay_type,
                               2240
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 11
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[Допомога на дітей одиноким матерям ]'
                                   AS x_pay_type,
                               2730
                                   AS x_kekv,
                               267
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 12
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[Витрати на поштові операції за напрямом]'
                                   AS x_pay_type,
                               2240
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 13
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[Допомога при народженні дитини та усиновленні]'
                                   AS x_pay_type,
                               2730
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 14
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[одноразова частина допомоги при народженні та усиновленні дитини]'
                                   AS x_pay_type,
                               2730
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 15
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[щомісячна допомога на дітей при народженні та усиновлені]'
                                   AS x_pay_type,
                               2730
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 16
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[Витрати на поштові операції за напрямом]'
                                   AS x_pay_type,
                               2240
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 17
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[Допомога на дітей, над якими встановлено опіку чи піклування ]'
                                   AS x_pay_type,
                               2730
                                   AS x_kekv,
                               268
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 18
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[Витрати на поштові операції за напрямом]'
                                   AS x_pay_type,
                               2240
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 19
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[Допомога у зв'язку з вагітністю та пологами]'
                                   AS x_pay_type,
                               2730
                                   AS x_kekv,
                               251
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 20
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[Витрати на поштові операції за напрямом]'
                                   AS x_pay_type,
                               2240
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 21
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[Допомога особі, яка доглядає за хворою дитиною]'
                                   AS x_pay_type,
                               2730
                                   AS x_kekv,
                               265
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 22
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[Витрати на поштові операції за напрямом]'
                                   AS x_pay_type,
                               2240
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 23
                                   AS x_num,
                               '5'
                                   AS x_row_code,
                               q'[Виплата тимчасової державної допомоги дітям, батьки яких  ухиляються  від  сплати аліментів, не мають можливості  утримувати дитину або місце проживання їх невідоме]'
                                   AS x_pay_type,
                               2730
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               1
                                   AS x_mergedown,
                               'cell_grey'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 24
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[Витрати на поштові операції за напрямом]'
                                   AS x_pay_type,
                               2240
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_grey'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 25
                                   AS x_num,
                               '6'
                                   AS x_row_code,
                               q'[Допомога на дітей-сиріт та дітей, позбавлених батьківського піклування, та грошового забезпечення батькам-вихователям і прийомним батькам за надання соціальних послуг у дитячих будинках сімейного типу та прийомних сім’ях, здійснення видатків на сплату за них єдиного внеску на загальнообов’язкове державне соціальне страхування ]'
                                   AS x_pay_type,
                               2730
                                   AS x_kekv,
                               275
                                   AS x_nst_id,
                               1
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 26
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[Витрати на поштові операції за напрямом]'
                                   AS x_pay_type,
                               2240
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 27
                                   AS x_num,
                               '6.1'
                                   AS x_row_code,
                               q'[державна соціальна допомога на дітей, які виховуються у дитячих будинках сімейного типу]'
                                   AS x_pay_type,
                               2730
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               1
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 28
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[Витрати на поштові операції за напрямом]'
                                   AS x_pay_type,
                               2240
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 29
                                   AS x_num,
                               '6.2'
                                   AS x_row_code,
                               q'[державна соціальна допомога на дітей, які виховуються у прийомних сім’ях]'
                                   AS x_pay_type,
                               2730
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               1
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 30
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[Витрати на поштові операції за напрямом]'
                                   AS x_pay_type,
                               2240
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 31
                                   AS x_num,
                               '7'
                                   AS x_row_code,
                               q'[Оплата послуг патронатного вихователя, виплату соціальної допомоги на утримання дитини в сім’ї патронатного вихователя та здійснення видатків на сплату за патронатного вихователя єдиного внеску на загальнообов’язкове державне соціальне страхування ]'
                                   AS x_pay_type,
                               2730
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               1
                                   AS x_mergedown,
                               'cell_grey'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 32
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[Витрати на поштові операції за напрямом]'
                                   AS x_pay_type,
                               2240
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_grey'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 33
                                   AS x_num,
                               '8'
                                   AS x_row_code,
                               q'[Виплата державної соціальної допомоги особам з інвалідністю з дитинства та дітям з інвалідністю]'
                                   AS x_pay_type,
                               2730
                                   AS x_kekv,
                               248
                                   AS x_nst_id,
                               1
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 34
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[Витрати на поштові операції за напрямом]'
                                   AS x_pay_type,
                               2240
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 35
                                   AS x_num,
                               '9'
                                   AS x_row_code,
                               q'[Допомога особі, яка проживає разом з особою з інвалідністю I чи II групи внаслідок психічного розладу, яка за висновком лікарської комісії медичного закладу потребує постійного стороннього догляду, на догляд за нею]'
                                   AS x_pay_type,
                               2730
                                   AS x_kekv,
                               274
                                   AS x_nst_id,
                               1
                                   AS x_mergedown,
                               'cell_grey'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 36
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[Витрати на поштові операції за напрямом]'
                                   AS x_pay_type,
                               2240
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_grey'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 37
                                   AS x_num,
                               '10'
                                   AS x_row_code,
                               q'[Допомога особам, які не мають права на пенсію, та особам з інвалідністю]'
                                   AS x_pay_type,
                               2730
                                   AS x_kekv,
                               288
                                   AS x_nst_id,
                               1
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 38
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[Витрати на поштові операції за напрямом]'
                                   AS x_pay_type,
                               2240
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 39                          AS x_num,
                               '11'                        AS x_row_code,
                               q'[Допомога на догляд]'     AS x_pay_type,
                               2730                        AS x_kekv,
                               NULL                        AS x_nst_id,
                               1                           AS x_mergedown,
                               'cell_grey'                 AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 40
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[Витрати на поштові операції за напрямом]'
                                   AS x_pay_type,
                               2240
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_grey'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 41
                                   AS x_num,
                               '12'
                                   AS x_row_code,
                               q'[Допомога малозабезпеченим сім'ям ]'
                                   AS x_pay_type,
                               2730
                                   AS x_kekv,
                               249
                                   AS x_nst_id,
                               1
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 42
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[Витрати на поштові операції за напрямом]'
                                   AS x_pay_type,
                               2240
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 43
                                   AS x_num,
                               '13'
                                   AS x_row_code,
                               q'[Виплата  одноразової грошової допомоги на дітей з багатодітних малозабезпечених сімей для підготовки до навчального року  (постанова Кабінету Міністрів України від 04.08.2021 № 803)]'
                                   AS x_pay_type,
                               2730
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               1
                                   AS x_mergedown,
                               'cell_grey'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 44
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[Витрати на поштові операції за напрямом]'
                                   AS x_pay_type,
                               2240
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_grey'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 45
                                   AS x_num,
                               '14'
                                   AS x_row_code,
                               q'[Допомога непрацюючій особі, яка досягла загального пенсійного віку, але не набула права на пенсійну виплату]'
                                   AS x_pay_type,
                               2730
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               1
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 46
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[Витрати на поштові операції за напрямом]'
                                   AS x_pay_type,
                               2240
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 47
                                   AS x_num,
                               '15'
                                   AS x_row_code,
                               q'[Компенсаційна виплата непрацюючій працездатній особі, яка доглядає за особою з інвалідністю I групи, а також за особою, яка досягла 80-річного віку]'
                                   AS x_pay_type,
                               2730
                                   AS x_kekv,
                               256
                                   AS x_nst_id,
                               1
                                   AS x_mergedown,
                               'cell_grey'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 48
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[Витрати на поштові операції за напрямом]'
                                   AS x_pay_type,
                               2240
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               NULL
                                   AS x_mergedown,
                               'cell_grey'
                                   AS x_style
                          FROM DUAL
                        UNION ALL
                        SELECT 49
                                   AS x_num,
                               ''
                                   AS x_row_code,
                               q'[КПКВК 2501030 "Виплата деяких видів допомог, компенсацій, грошового забезпечення та оплату послуг окремим категоріям населення"]'
                                   AS x_pay_type,
                               NULL
                                   AS x_kekv,
                               NULL
                                   AS x_nst_id,
                               4
                                   AS x_mergedown,
                               'cell_white'
                                   AS x_style
                          FROM DUAL) tt
                       JOIN
                       (SELECT ff.*,
                               f_nst_sum / SUM (f_nst_sum) OVER ()
                                   AS nst_coef,
                               ROUND (
                                     po_sum_total
                                   * f_nst_sum
                                   / SUM (f_nst_sum) OVER (),
                                   2)
                                   AS nst_po_sum
                          FROM (  SELECT frs_nst     AS f_nst_id,
                                         SUM (
                                             CASE
                                                 WHEN frf_value_tp = 'QNT'
                                                 THEN
                                                     frf_value
                                                 ELSE
                                                     NULL
                                             END)    AS f_nst_cnt, -- к-ть справ?
                                         SUM (
                                             CASE
                                                 WHEN frf_value_tp != 'QNT'
                                                 THEN
                                                     frf_value
                                                 ELSE
                                                     0
                                             END)    AS f_nst_sum
                                    FROM uss_esr.v_funding_request fr
                                         JOIN uss_esr.v_fr_detail_service frs
                                             ON frs.frs_fr = fr.fr_id
                                         JOIN uss_esr.v_fr_detail_full frf
                                             ON     frf.frf_fr = fr.fr_id
                                                AND frf.frf_frs = frs.frs_id
                                         JOIN v_opfu ON org_id = fr.com_org
                                   WHERE     1 = 1
                                         AND fr.fr_month >= l_start_dt -- trunc(l_dt, 'yyyy')
                                         AND fr.fr_month < l_stop_dt -- add_months(trunc(l_dt, 'yyyy'), 12)
                                         AND fr.fr_tp IN ('MAIN', 'ADD')
                                         AND fr.fr_st = 'Z'     -- Затверджено
                                         AND fr.fr_own_tp = 'CONS'
                                         --  and frs_nst in (248, 268, 249, 265, 267, 250, 269, 251, 274)
                                         AND fr.com_org = p_org_id
                                GROUP BY frs_nst) ff
                               JOIN
                               (SELECT SUM (po_sum)     AS po_sum_total
                                  FROM pay_order po
                                 WHERE     1 = 1
                                       AND po.po_circ_tp = 'PH'   -- Прихід  +
                                       AND po.po_st = 'APPR' --  Проведено банком
                                       AND po.po_pay_dt >= l_start_dt -- trunc(sysdate, 'yyyy')
                                       AND po.po_pay_dt < l_stop_dt -- add_months(trunc(sysdate, 'yyyy'), 12)
                                                                   )
                                   ON 1 = 1) ff
                           ON ff.f_nst_id = tt.x_nst_id)
        LOOP
            RDM$RTFL.AddParam (l_jbr_id,
                               'c_01_' || rr.row_num || '_1' || l_qq,
                               TO_CHAR (rr.nst_po_sum));
        END LOOP;

        RDM$RTFL.PutReportToWorkingQueue (l_jbr_id);
        RETURN l_jbr_id;
    END;

    -- #86365  io 20230418 спроба переписати, оскільки поле prs_npt (для визначення послуги) переїхало з pr_sheet в pr_sheet_detail.
    FUNCTION USE_FUNDS_MSP (p_rt_id IN NUMBER, p_dt IN DATE)
        RETURN NUMBER
    IS
        --l_sum  number(18,2);
        --l_cnt  number(14,0);
        --l_rows_cnt  number(14,0);
        l_empty_params     VARCHAR2 (32000) := '';
        l_empty_params_0   VARCHAR2 (32000) := '';
        l_empty_params_1   VARCHAR2 (32000) := '';
        l_empty_params_2   VARCHAR2 (32000) := '';
        l_sql_01           VARCHAR2 (32000) := '';
        l_jbr_id           NUMBER;
        l_dt               DATE := TRUNC (p_dt, 'Q');
        l_start_dt         DATE := TRUNC (p_dt, 'YYYY');
        l_stop_dt          DATE := ADD_MONTHS (TRUNC (p_dt, 'Q'), 3); -- не включаючи ...
        l_start_str        VARCHAR2 (100)
            :=    ' to_date('''
               || TO_CHAR (l_start_dt, 'dd.mm.yyyy')
               || ''', ''dd.mm.yyyy'') ';
        l_stop_str         VARCHAR2 (100)
            :=    ' to_date('''
               || TO_CHAR (l_stop_dt, 'dd.mm.yyyy')
               || ''', ''dd.mm.yyyy'') ';
        l_qq               VARCHAR2 (10) := TO_CHAR (l_dt, 'Q');
        l_yyyy             VARCHAR2 (10) := TO_CHAR (l_dt, 'yyyy');
    --l_org_name varchar2(1000);
    --l_org_name2 varchar2(1000);
    --l_rpt     clob;
    BEGIN
        l_jbr_id := RDM$RTFL.InitReport (p_rt_id);

        --raise_application_error(-20000, p_dt || ';' || p_org_id || ';' || p_npc_id);

        SELECT LISTAGG (
                      DECODE (x_serv, 1, CHR (10) || ' ', '')
                   || 'null as c_'
                   || LPAD (x_serv, 2, '0')
                   || '_0'
                   || x_qq,
                   ',')
               WITHIN GROUP (ORDER BY x_serv),
               LISTAGG (
                      DECODE (x_serv, 1, CHR (10) || ' ', '')
                   || 'null as c_'
                   || LPAD (x_serv, 2, '0')
                   || '_1'
                   || x_qq,
                   ',')
               WITHIN GROUP (ORDER BY x_serv),
               LISTAGG (
                      DECODE (x_serv, 1, CHR (10) || ' ', '')
                   || 'null as c_'
                   || LPAD (x_serv, 2, '0')
                   || '_2'
                   || x_qq,
                   ',')
               WITHIN GROUP (ORDER BY x_serv)
          INTO l_empty_params_0, l_empty_params_1, l_empty_params_2
          FROM (    SELECT LEVEL     AS x_qq
                      FROM DUAL
                CONNECT BY LEVEL <= 4) q,
               (    SELECT LEVEL     AS x_serv
                      FROM DUAL
                CONNECT BY LEVEL <= 49) s
         WHERE 1 = 1 AND x_qq != l_qq;

        l_empty_params :=
               'left join ('
            || CHR (10)
            || 'select '
            ||                                                     --chr(10)||
               l_empty_params_0
            || ','
            || CHR (10)
            || l_empty_params_1
            || ','
            || CHR (10)
            || l_empty_params_2
            || CHR (10)
            || 'from dual
) xx on 1=1';

        l_sql_01 :=
               q'[
select *
from (
  select
   org_num,
   qq, yyyy,yyyy2,
   org_id,
   case when org_id = 53000 then 'по м. Києву'
        else 'по '||substr(org_name, 1, length(org_name) - 1)||'ій області'
   end as org_name,
   org_num ||' '||decode(org_id, 53000, 'м. ','')||org_name as sheet_name
  from (
    select
      row_number()over(order by decode(org_id, 53000, 'яяя', uss_esr.tools.GetOpfuParam('KAOT_NAME',o.org_id))) as org_num,
      org_id,
      uss_esr.tools.GetOpfuParam('KAOT_NAME',o.org_id) as org_name,
      ]'
            || l_qq
            || q'[ as qq,
      ]'
            || l_yyyy
            || q'[ as yyyy,
      ]'
            || l_yyyy
            || q'[ + 1 as yyyy2
    from v_opfu o where org_org = 50000 and org_id not in (54300, 54000)
  ) orgs
  order by 1) rr
left join (
SELECT * FROM
(

select
  (select decode(org_org, 50000, org_id, org_org) from v_opfu o where org_id = com_org) as com_org,
  lpad(x_num, 2, '0') as row_num,
  p_nst_cnt, p_nst_sum
from (
select  1 as x_num,  '1' as x_row_code,   2730 as x_kekv, null   as x_nst_id  from dual union all
select  2 as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  3 as x_num,  '2' as x_row_code,   null as x_kekv, null   as x_nst_id  from dual union all
select  4 as x_num,  '' as x_row_code,  2210 as x_kekv, null   as x_nst_id  from dual union all
select  5 as x_num,  '' as x_row_code,  2730 as x_kekv, null   as x_nst_id  from dual union all
select  6 as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  7 as x_num,  '3' as x_row_code,   2730 as x_kekv, null   as x_nst_id  from dual union all
select  8 as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  9 as x_num,  '4' as x_row_code,   2730 as x_kekv, null   as x_nst_id  from dual union all
select  10  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  11  as x_num,  '' as x_row_code,  2730 as x_kekv, 267  as x_nst_id  from dual union all
select  12  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  13  as x_num,  '' as x_row_code,  2730 as x_kekv, null   as x_nst_id  from dual union all
select  14  as x_num,  '' as x_row_code,  2730 as x_kekv, null   as x_nst_id  from dual union all
select  15  as x_num,  '' as x_row_code,  2730 as x_kekv, null   as x_nst_id  from dual union all
select  16  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  17  as x_num,  '' as x_row_code,  2730 as x_kekv, 268  as x_nst_id  from dual union all
select  18  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  19  as x_num,  '' as x_row_code,  2730 as x_kekv, 251  as x_nst_id  from dual union all
select  20  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  21  as x_num,  '' as x_row_code,  2730 as x_kekv, 265  as x_nst_id  from dual union all
select  22  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  23  as x_num,  '5' as x_row_code,   2730 as x_kekv, null   as x_nst_id  from dual union all
select  24  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  25  as x_num,  '6' as x_row_code,   2730 as x_kekv, 275  as x_nst_id  from dual union all
select  26  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  27  as x_num,  '6.1' as x_row_code,   2730 as x_kekv, null   as x_nst_id  from dual union all
select  28  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  29  as x_num,  '6.2' as x_row_code,   2730 as x_kekv, null   as x_nst_id  from dual union all
select  30  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  31  as x_num,  '7' as x_row_code,   2730 as x_kekv, null   as x_nst_id  from dual union all
select  32  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  33  as x_num,  '8' as x_row_code,   2730 as x_kekv, 248/*, 247, 246, 245*/   as x_nst_id  from dual union all
select  34  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  35  as x_num,  '9' as x_row_code,   2730 as x_kekv, 274  as x_nst_id  from dual union all
select  36  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  37  as x_num,  '10' as x_row_code,  2730 as x_kekv, 288  as x_nst_id  from dual union all
select  38  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  39  as x_num,  '11' as x_row_code,  2730 as x_kekv, null   as x_nst_id  from dual union all
select  40  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  41  as x_num,  '12' as x_row_code,  2730 as x_kekv, 249  as x_nst_id  from dual union all
select  42  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  43  as x_num,  '13' as x_row_code,  2730 as x_kekv, null   as x_nst_id  from dual union all
select  44  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  45  as x_num,  '14' as x_row_code,  2730 as x_kekv, null   as x_nst_id  from dual union all
select  46  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  47  as x_num,  '15' as x_row_code,  2730 as x_kekv, 256  as x_nst_id  from dual union all
select  48  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  49  as x_num,  '' as x_row_code,  null as x_kekv, null   as x_nst_id  from dual
) tt
join (
  select
    r.com_org,
    nst_id as p_nst_id,
    count(1)as p_nst_cnt,  -- к-ть справ?
    sum(r.prs_sum) as p_nst_sum
  from (
    select r.com_org, prs_id, prs_pc, prs_sum, max(nst_id) as nst_id
    from uss_esr.v_payroll_reestr r
    join  uss_esr.v_pay_order po on po.po_id = r.pe_po
      join uss_esr.v_pr_sheet s  on prs_pr = r.pe_src_entity  and s.prs_nb = r.pe_nb and s.prs_pay_dt = r.pe_pay_dt  and prs_tp in ('PP','PB')
      join uss_esr.v_pr_sheet_detail d on prsd_prs = prs_id
      join uss_ndi.v_ndi_payment_type t on t.npt_id = d.prsd_npt and r.pe_npc = t.npt_npc
      join uss_ndi.v_ndi_npt_config c on  c.nptc_npt = d.prsd_npt
      join uss_ndi.v_ndi_service_type nst on nst.nst_id = c.nptc_nst
      where r.pe_pay_dt >= ]'
            || l_start_str
            || q'[
        and r.pe_pay_dt <  ]'
            || l_stop_str
            || q'[
        and r.pe_nbg = 1 -- Бюджетна програма КПК 2501030
        and po.po_st = 'APPR'--   Проведено банком
      group by r.com_org, prs_id, prs_pc, prs_sum
     ) r
   group by r.com_org, nst_id
) pp
  on pp.p_nst_id = tt.x_nst_id
)
PIVOT
(
  sum(p_nst_cnt) as "0QuarteR",
  sum(p_nst_sum) as "2QuarteR"
  FOR row_num  IN (1 as "c_01", 2 as "c_02", 3 as "c_03", 4 as "c_04", 5 as "c_05", 6 as "c_06", 7 as "c_07", 8 as "c_08", 9 as "c_09", 10 as "c_10",
                   11 as "c_11",12 as "c_12",13 as "c_13",14 as "c_14",15 as "c_15",16 as "c_16",17 as "c_17",18 as "c_18",19 as "c_19",20 as "c_20",
                   21 as "c_21",22 as "c_22",23 as "c_23",24 as "c_24",25 as "c_25",26 as "c_26",27 as "c_27",28 as "c_28",29 as "c_29",30 as "c_30",
                   31 as "c_31",32 as "c_32",33 as "c_33",34 as "c_34",35 as "c_35",36 as "c_36",37 as "c_37",38 as "c_38",39 as "c_39",40 as "c_40",
                   41 as "c_41",42 as "c_42",43 as "c_43",44 as "c_44",45 as "c_45",46 as "c_46",47 as "c_47",48 as "c_48",49 as "c_49",50 as "c_50",
                   51 as "c_51",52 as "c_52",53 as "c_53",54 as "c_54",55 as "c_55",56 as "c_56",57 as "c_57",58 as "c_58",59 as "c_59",60 as "c_60"
)
)
order by com_org
) pp
  on pp.com_org = rr.org_id
left join (
SELECT * FROM
(
select
  com_org,
  lpad(x_num, 2, '0') as row_num,
  nst_po_sum
from (

select  1 as x_num,  '1' as x_row_code,   2730 as x_kekv, null   as x_nst_id  from dual union all
select  2 as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  3 as x_num,  '2' as x_row_code,   null as x_kekv, null   as x_nst_id  from dual union all
select  4 as x_num,  '' as x_row_code,  2210 as x_kekv, null   as x_nst_id  from dual union all
select  5 as x_num,  '' as x_row_code,  2730 as x_kekv, null   as x_nst_id  from dual union all
select  6 as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  7 as x_num,  '3' as x_row_code,   2730 as x_kekv, null   as x_nst_id  from dual union all
select  8 as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  9 as x_num,  '4' as x_row_code,   2730 as x_kekv, null   as x_nst_id  from dual union all
select  10  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  11  as x_num,  '' as x_row_code,  2730 as x_kekv, 267  as x_nst_id  from dual union all
select  12  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  13  as x_num,  '' as x_row_code,  2730 as x_kekv, null   as x_nst_id  from dual union all
select  14  as x_num,  '' as x_row_code,  2730 as x_kekv, null   as x_nst_id  from dual union all
select  15  as x_num,  '' as x_row_code,  2730 as x_kekv, null   as x_nst_id  from dual union all
select  16  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  17  as x_num,  '' as x_row_code,  2730 as x_kekv, 268  as x_nst_id  from dual union all
select  18  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  19  as x_num,  '' as x_row_code,  2730 as x_kekv, 251  as x_nst_id  from dual union all
select  20  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  21  as x_num,  '' as x_row_code,  2730 as x_kekv, 265  as x_nst_id  from dual union all
select  22  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  23  as x_num,  '5' as x_row_code,   2730 as x_kekv, null   as x_nst_id  from dual union all
select  24  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  25  as x_num,  '6' as x_row_code,   2730 as x_kekv, 275  as x_nst_id  from dual union all
select  26  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  27  as x_num,  '6.1' as x_row_code,   2730 as x_kekv, null   as x_nst_id  from dual union all
select  28  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  29  as x_num,  '6.2' as x_row_code,   2730 as x_kekv, null   as x_nst_id  from dual union all
select  30  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  31  as x_num,  '7' as x_row_code,   2730 as x_kekv, null   as x_nst_id  from dual union all
select  32  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  33  as x_num,  '8' as x_row_code,   2730 as x_kekv, 248/*, 247, 246, 245*/   as x_nst_id  from dual union all
select  34  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  35  as x_num,  '9' as x_row_code,   2730 as x_kekv, 274  as x_nst_id  from dual union all
select  36  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  37  as x_num,  '10' as x_row_code,  2730 as x_kekv, 288  as x_nst_id  from dual union all
select  38  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  39  as x_num,  '11' as x_row_code,  2730 as x_kekv, null   as x_nst_id  from dual union all
select  40  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  41  as x_num,  '12' as x_row_code,  2730 as x_kekv, 249  as x_nst_id  from dual union all
select  42  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  43  as x_num,  '13' as x_row_code,  2730 as x_kekv, null   as x_nst_id  from dual union all
select  44  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  45  as x_num,  '14' as x_row_code,  2730 as x_kekv, null   as x_nst_id  from dual union all
select  46  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  47  as x_num,  '15' as x_row_code,  2730 as x_kekv, 256  as x_nst_id  from dual union all
select  48  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  49  as x_num,  '' as x_row_code,  null as x_kekv, null   as x_nst_id  from dual
) tt
join (
 select
ff.*,
f_nst_sum / sum(f_nst_sum)over() as nst_coef,
round(po_sum_total * f_nst_sum / sum(f_nst_sum)over(), 2) as nst_po_sum
from (
  select
    --fr.com_org,
    decode(org_org, 50000, org_id, org_org) as com_org,
    frs_nst as f_nst_id,
    sum(case when frf_value_tp = 'QNT' then frf_value else null end)as f_nst_cnt,  -- к-ть справ?
    sum(case when frf_value_tp != 'QNT' then frf_value else 0 end) as f_nst_sum
  from uss_esr.v_funding_request  fr
  join uss_esr.v_fr_detail_service frs on frs.frs_fr = fr.fr_id
  join uss_esr.v_fr_detail_full frf on frf.frf_fr = fr.fr_id and frf.frf_frs = frs.frs_id
  join v_opfu on org_id = fr.com_org
  where 1=1
    and fr.fr_month >=  ]'
            || l_start_str
            || q'[
    and fr.fr_month <  ]'
            || l_stop_str
            || q'[
    and fr.fr_tp in ('MAIN', 'ADD')
    and fr.fr_st = 'Z' -- Затверджено
    and fr.fr_own_tp = 'CONS'
  group by decode(org_org, 50000, org_id, org_org), frs_nst
) ff
join (
select po.com_org_src, sum(po_sum) as po_sum_total from  uss_esr.v_pay_order po
where 1=1
  and po.po_circ_tp = 'PH' -- Прихід  +
  and po.po_st = 'APPR'--   Проведено банком
  and po.po_pay_dt >=  ]'
            || l_start_str
            || q'[
  and po.po_pay_dt < ]'
            || l_stop_str
            || q'[
group by po.com_org_src
) po on po.com_org_src = ff.com_org
) ff

  on ff.f_nst_id = tt.x_nst_id
)
PIVOT
(
  sum(nst_po_sum) as "1QuarteR"
  FOR row_num  IN (1 as "c_01", 2 as "c_02", 3 as "c_03", 4 as "c_04", 5 as "c_05", 6 as "c_06", 7 as "c_07", 8 as "c_08", 9 as "c_09", 10 as "c_10",
                   11 as "c_11",12 as "c_12",13 as "c_13",14 as "c_14",15 as "c_15",16 as "c_16",17 as "c_17",18 as "c_18",19 as "c_19",20 as "c_20",
                   21 as "c_21",22 as "c_22",23 as "c_23",24 as "c_24",25 as "c_25",26 as "c_26",27 as "c_27",28 as "c_28",29 as "c_29",30 as "c_30",
                   31 as "c_31",32 as "c_32",33 as "c_33",34 as "c_34",35 as "c_35",36 as "c_36",37 as "c_37",38 as "c_38",39 as "c_39",40 as "c_40",
                   41 as "c_41",42 as "c_42",43 as "c_43",44 as "c_44",45 as "c_45",46 as "c_46",47 as "c_47",48 as "c_48",49 as "c_49",50 as "c_50",
                   51 as "c_51",52 as "c_52",53 as "c_53",54 as "c_54",55 as "c_55",56 as "c_56",57 as "c_57",58 as "c_58",59 as "c_59",60 as "c_60"
)
)
order by com_org
) ff
  on ff.com_org = rr.org_id
]'
            || l_empty_params
            || CHR (10)
            || '
order by org_num';
        l_sql_01 := REPLACE (l_sql_01, 'QuarteR', l_qq);

        -- dbms_output.put_line(l_sql_01) ;

        RDM$RTFL.AddParam (l_jbr_id, 'c_qq', l_qq);
        RDM$RTFL.AddParam (l_jbr_id, 'c_yyyy', TO_CHAR (l_dt, 'yyyy'));
        RDM$RTFL.AddParam (l_jbr_id, 'c_yyyy2', TO_CHAR (l_dt, 'yyyy') + 1);

        RDM$RTFL.AddDataSet (l_jbr_id, 'ds_reg', l_sql_01);


        RDM$RTFL.PutReportToWorkingQueue (l_jbr_id);
        RETURN l_jbr_id;
    END;

    FUNCTION USE_FUNDS_MSP_0 (p_rt_id IN NUMBER, p_dt IN DATE)
        RETURN NUMBER
    IS
        --l_sum  number(18,2);
        --l_cnt  number(14,0);
        --l_rows_cnt  number(14,0);
        l_empty_params     VARCHAR2 (32000) := '';
        l_empty_params_0   VARCHAR2 (32000) := '';
        l_empty_params_1   VARCHAR2 (32000) := '';
        l_empty_params_2   VARCHAR2 (32000) := '';
        l_sql_01           VARCHAR2 (32000) := '';
        l_jbr_id           NUMBER;
        l_dt               DATE := TRUNC (p_dt, 'Q');
        l_start_dt         DATE := TRUNC (p_dt, 'YYYY');
        l_stop_dt          DATE := ADD_MONTHS (TRUNC (p_dt, 'Q'), 3); -- не включаючи ...
        l_start_str        VARCHAR2 (100)
            :=    ' to_date('''
               || TO_CHAR (l_start_dt, 'dd.mm.yyyy')
               || ''', ''dd.mm.yyyy'') ';
        l_stop_str         VARCHAR2 (100)
            :=    ' to_date('''
               || TO_CHAR (l_stop_dt, 'dd.mm.yyyy')
               || ''', ''dd.mm.yyyy'') ';
        l_qq               VARCHAR2 (10) := TO_CHAR (l_dt, 'Q');
        l_yyyy             VARCHAR2 (10) := TO_CHAR (l_dt, 'yyyy');
    --l_org_name varchar2(1000);
    --l_org_name2 varchar2(1000);
    --l_rpt     clob;
    BEGIN
        l_jbr_id := RDM$RTFL.InitReport (p_rt_id);

        --raise_application_error(-20000, p_dt || ';' || p_org_id || ';' || p_npc_id);

        SELECT LISTAGG (
                      DECODE (x_serv, 1, CHR (10) || ' ', '')
                   || 'null as c_'
                   || LPAD (x_serv, 2, '0')
                   || '_0'
                   || x_qq,
                   ',')
               WITHIN GROUP (ORDER BY x_serv),
               LISTAGG (
                      DECODE (x_serv, 1, CHR (10) || ' ', '')
                   || 'null as c_'
                   || LPAD (x_serv, 2, '0')
                   || '_1'
                   || x_qq,
                   ',')
               WITHIN GROUP (ORDER BY x_serv),
               LISTAGG (
                      DECODE (x_serv, 1, CHR (10) || ' ', '')
                   || 'null as c_'
                   || LPAD (x_serv, 2, '0')
                   || '_2'
                   || x_qq,
                   ',')
               WITHIN GROUP (ORDER BY x_serv)
          INTO l_empty_params_0, l_empty_params_1, l_empty_params_2
          FROM (    SELECT LEVEL     AS x_qq
                      FROM DUAL
                CONNECT BY LEVEL <= 4) q,
               (    SELECT LEVEL     AS x_serv
                      FROM DUAL
                CONNECT BY LEVEL <= 49) s
         WHERE 1 = 1 AND x_qq != l_qq;

        l_empty_params :=
               'left join ('
            || CHR (10)
            || 'select '
            ||                                                     --chr(10)||
               l_empty_params_0
            || ','
            || CHR (10)
            || l_empty_params_1
            || ','
            || CHR (10)
            || l_empty_params_2
            || CHR (10)
            || 'from dual
) xx on 1=1';

        l_sql_01 :=
               q'[
select *
from (
  select
   org_num,
   qq, yyyy,yyyy2,
   org_id,
   case when org_id = 53000 then 'по м. Києву'
        else 'по '||substr(org_name, 1, length(org_name) - 1)||'ій області'
   end as org_name,
   org_num ||' '||decode(org_id, 53000, 'м. ','')||org_name as sheet_name
  from (
    select
      row_number()over(order by decode(org_id, 53000, 'яяя', uss_esr.tools.GetOpfuParam('KAOT_NAME',o.org_id))) as org_num,
      org_id,
      uss_esr.tools.GetOpfuParam('KAOT_NAME',o.org_id) as org_name,
      ]'
            || l_qq
            || q'[ as qq,
      ]'
            || l_yyyy
            || q'[ as yyyy,
      ]'
            || l_yyyy
            || q'[ + 1 as yyyy2
    from v_opfu o where org_org = 50000 and org_id not in (54300, 54000)
  ) orgs
  order by 1) rr
left join (
SELECT * FROM
(

select
  (select decode(org_org, 50000, org_id, org_org) from v_opfu o where org_id = com_org) as com_org,
  lpad(x_num, 2, '0') as row_num,
  p_nst_cnt, p_nst_sum
from (
select  1 as x_num,  '1' as x_row_code,   2730 as x_kekv, null   as x_nst_id  from dual union all
select  2 as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  3 as x_num,  '2' as x_row_code,   null as x_kekv, null   as x_nst_id  from dual union all
select  4 as x_num,  '' as x_row_code,  2210 as x_kekv, null   as x_nst_id  from dual union all
select  5 as x_num,  '' as x_row_code,  2730 as x_kekv, null   as x_nst_id  from dual union all
select  6 as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  7 as x_num,  '3' as x_row_code,   2730 as x_kekv, null   as x_nst_id  from dual union all
select  8 as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  9 as x_num,  '4' as x_row_code,   2730 as x_kekv, null   as x_nst_id  from dual union all
select  10  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  11  as x_num,  '' as x_row_code,  2730 as x_kekv, 267  as x_nst_id  from dual union all
select  12  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  13  as x_num,  '' as x_row_code,  2730 as x_kekv, null   as x_nst_id  from dual union all
select  14  as x_num,  '' as x_row_code,  2730 as x_kekv, null   as x_nst_id  from dual union all
select  15  as x_num,  '' as x_row_code,  2730 as x_kekv, null   as x_nst_id  from dual union all
select  16  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  17  as x_num,  '' as x_row_code,  2730 as x_kekv, 268  as x_nst_id  from dual union all
select  18  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  19  as x_num,  '' as x_row_code,  2730 as x_kekv, 251  as x_nst_id  from dual union all
select  20  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  21  as x_num,  '' as x_row_code,  2730 as x_kekv, 265  as x_nst_id  from dual union all
select  22  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  23  as x_num,  '5' as x_row_code,   2730 as x_kekv, null   as x_nst_id  from dual union all
select  24  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  25  as x_num,  '6' as x_row_code,   2730 as x_kekv, 275  as x_nst_id  from dual union all
select  26  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  27  as x_num,  '6.1' as x_row_code,   2730 as x_kekv, null   as x_nst_id  from dual union all
select  28  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  29  as x_num,  '6.2' as x_row_code,   2730 as x_kekv, null   as x_nst_id  from dual union all
select  30  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  31  as x_num,  '7' as x_row_code,   2730 as x_kekv, null   as x_nst_id  from dual union all
select  32  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  33  as x_num,  '8' as x_row_code,   2730 as x_kekv, 248/*, 247, 246, 245*/   as x_nst_id  from dual union all
select  34  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  35  as x_num,  '9' as x_row_code,   2730 as x_kekv, 274  as x_nst_id  from dual union all
select  36  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  37  as x_num,  '10' as x_row_code,  2730 as x_kekv, 288  as x_nst_id  from dual union all
select  38  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  39  as x_num,  '11' as x_row_code,  2730 as x_kekv, null   as x_nst_id  from dual union all
select  40  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  41  as x_num,  '12' as x_row_code,  2730 as x_kekv, 249  as x_nst_id  from dual union all
select  42  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  43  as x_num,  '13' as x_row_code,  2730 as x_kekv, null   as x_nst_id  from dual union all
select  44  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  45  as x_num,  '14' as x_row_code,  2730 as x_kekv, null   as x_nst_id  from dual union all
select  46  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  47  as x_num,  '15' as x_row_code,  2730 as x_kekv, 256  as x_nst_id  from dual union all
select  48  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  49  as x_num,  '' as x_row_code,  null as x_kekv, null   as x_nst_id  from dual
) tt
join (
  select
    r.com_org,
    nst_id as p_nst_id,
    count(1)as p_nst_cnt,  -- к-ть справ?
    sum(s.prs_sum) as p_nst_sum
  from uss_esr.v_payroll_reestr r
  join  uss_esr.v_pay_order po on po.po_id = r.pe_po
    join uss_esr.v_pr_sheet s  on prs_pr = r.pe_src_entity  and s.prs_nb = r.pe_nb and s.prs_pay_dt = r.pe_pay_dt
    join uss_ndi.v_ndi_payment_type t on t.npt_id = s.prs_npt and r.pe_npc = t.npt_npc
    join uss_ndi.v_ndi_npt_config c on  c.nptc_npt = s.prs_npt
    join uss_ndi.v_ndi_service_type nst on nst.nst_id = c.nptc_nst
    where r.pe_pay_dt >= ]'
            || l_start_str
            || q'[
      and r.pe_pay_dt <  ]'
            || l_stop_str
            || q'[
      and r.pe_nbg = 1 -- Бюджетна програма КПК 2501030
      and po.po_st = 'APPR'--   Проведено банком
   group by r.com_org, nst_id
) pp
  on pp.p_nst_id = tt.x_nst_id
)
PIVOT
(
  sum(p_nst_cnt) as "0QuarteR",
  sum(p_nst_sum) as "2QuarteR"
  FOR row_num  IN (1 as "c_01", 2 as "c_02", 3 as "c_03", 4 as "c_04", 5 as "c_05", 6 as "c_06", 7 as "c_07", 8 as "c_08", 9 as "c_09", 10 as "c_10",
                   11 as "c_11",12 as "c_12",13 as "c_13",14 as "c_14",15 as "c_15",16 as "c_16",17 as "c_17",18 as "c_18",19 as "c_19",20 as "c_20",
                   21 as "c_21",22 as "c_22",23 as "c_23",24 as "c_24",25 as "c_25",26 as "c_26",27 as "c_27",28 as "c_28",29 as "c_29",30 as "c_30",
                   31 as "c_31",32 as "c_32",33 as "c_33",34 as "c_34",35 as "c_35",36 as "c_36",37 as "c_37",38 as "c_38",39 as "c_39",40 as "c_40",
                   41 as "c_41",42 as "c_42",43 as "c_43",44 as "c_44",45 as "c_45",46 as "c_46",47 as "c_47",48 as "c_48",49 as "c_49",50 as "c_50",
                   51 as "c_51",52 as "c_52",53 as "c_53",54 as "c_54",55 as "c_55",56 as "c_56",57 as "c_57",58 as "c_58",59 as "c_59",60 as "c_60"
)
)
order by com_org
) pp
  on pp.com_org = rr.org_id
left join (
SELECT * FROM
(
select
  com_org,
  lpad(x_num, 2, '0') as row_num,
  nst_po_sum
from (

select  1 as x_num,  '1' as x_row_code,   2730 as x_kekv, null   as x_nst_id  from dual union all
select  2 as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  3 as x_num,  '2' as x_row_code,   null as x_kekv, null   as x_nst_id  from dual union all
select  4 as x_num,  '' as x_row_code,  2210 as x_kekv, null   as x_nst_id  from dual union all
select  5 as x_num,  '' as x_row_code,  2730 as x_kekv, null   as x_nst_id  from dual union all
select  6 as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  7 as x_num,  '3' as x_row_code,   2730 as x_kekv, null   as x_nst_id  from dual union all
select  8 as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  9 as x_num,  '4' as x_row_code,   2730 as x_kekv, null   as x_nst_id  from dual union all
select  10  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  11  as x_num,  '' as x_row_code,  2730 as x_kekv, 267  as x_nst_id  from dual union all
select  12  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  13  as x_num,  '' as x_row_code,  2730 as x_kekv, null   as x_nst_id  from dual union all
select  14  as x_num,  '' as x_row_code,  2730 as x_kekv, null   as x_nst_id  from dual union all
select  15  as x_num,  '' as x_row_code,  2730 as x_kekv, null   as x_nst_id  from dual union all
select  16  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  17  as x_num,  '' as x_row_code,  2730 as x_kekv, 268  as x_nst_id  from dual union all
select  18  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  19  as x_num,  '' as x_row_code,  2730 as x_kekv, 251  as x_nst_id  from dual union all
select  20  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  21  as x_num,  '' as x_row_code,  2730 as x_kekv, 265  as x_nst_id  from dual union all
select  22  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  23  as x_num,  '5' as x_row_code,   2730 as x_kekv, null   as x_nst_id  from dual union all
select  24  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  25  as x_num,  '6' as x_row_code,   2730 as x_kekv, 275  as x_nst_id  from dual union all
select  26  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  27  as x_num,  '6.1' as x_row_code,   2730 as x_kekv, null   as x_nst_id  from dual union all
select  28  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  29  as x_num,  '6.2' as x_row_code,   2730 as x_kekv, null   as x_nst_id  from dual union all
select  30  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  31  as x_num,  '7' as x_row_code,   2730 as x_kekv, null   as x_nst_id  from dual union all
select  32  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  33  as x_num,  '8' as x_row_code,   2730 as x_kekv, 248/*, 247, 246, 245*/   as x_nst_id  from dual union all
select  34  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  35  as x_num,  '9' as x_row_code,   2730 as x_kekv, 274  as x_nst_id  from dual union all
select  36  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  37  as x_num,  '10' as x_row_code,  2730 as x_kekv, 288  as x_nst_id  from dual union all
select  38  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  39  as x_num,  '11' as x_row_code,  2730 as x_kekv, null   as x_nst_id  from dual union all
select  40  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  41  as x_num,  '12' as x_row_code,  2730 as x_kekv, 249  as x_nst_id  from dual union all
select  42  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  43  as x_num,  '13' as x_row_code,  2730 as x_kekv, null   as x_nst_id  from dual union all
select  44  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  45  as x_num,  '14' as x_row_code,  2730 as x_kekv, null   as x_nst_id  from dual union all
select  46  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  47  as x_num,  '15' as x_row_code,  2730 as x_kekv, 256  as x_nst_id  from dual union all
select  48  as x_num,  '' as x_row_code,  2240 as x_kekv, null   as x_nst_id  from dual union all
select  49  as x_num,  '' as x_row_code,  null as x_kekv, null   as x_nst_id  from dual
) tt
join (
 select
ff.*,
f_nst_sum / sum(f_nst_sum)over() as nst_coef,
round(po_sum_total * f_nst_sum / sum(f_nst_sum)over(), 2) as nst_po_sum
from (
  select
    --fr.com_org,
    decode(org_org, 50000, org_id, org_org) as com_org,
    frs_nst as f_nst_id,
    sum(case when frf_value_tp = 'QNT' then frf_value else null end)as f_nst_cnt,  -- к-ть справ?
    sum(case when frf_value_tp != 'QNT' then frf_value else 0 end) as f_nst_sum
  from uss_esr.v_funding_request  fr
  join uss_esr.v_fr_detail_service frs on frs.frs_fr = fr.fr_id
  join uss_esr.v_fr_detail_full frf on frf.frf_fr = fr.fr_id and frf.frf_frs = frs.frs_id
  join v_opfu on org_id = fr.com_org
  where 1=1
    and fr.fr_month >=  ]'
            || l_start_str
            || q'[
    and fr.fr_month <  ]'
            || l_stop_str
            || q'[
    and fr.fr_tp in ('MAIN', 'ADD')
    and fr.fr_st = 'Z' -- Затверджено
    and fr.fr_own_tp = 'CONS'
  group by decode(org_org, 50000, org_id, org_org), frs_nst
) ff
join (
select po.com_org_src, sum(po_sum) as po_sum_total from  uss_esr.v_pay_order po
where 1=1
  and po.po_circ_tp = 'PH' -- Прихід  +
  and po.po_st = 'APPR'--   Проведено банком
  and po.po_pay_dt >=  ]'
            || l_start_str
            || q'[
  and po.po_pay_dt < ]'
            || l_stop_str
            || q'[
group by po.com_org_src
) po on po.com_org_src = ff.com_org
) ff

  on ff.f_nst_id = tt.x_nst_id
)
PIVOT
(
  sum(nst_po_sum) as "1QuarteR"
  FOR row_num  IN (1 as "c_01", 2 as "c_02", 3 as "c_03", 4 as "c_04", 5 as "c_05", 6 as "c_06", 7 as "c_07", 8 as "c_08", 9 as "c_09", 10 as "c_10",
                   11 as "c_11",12 as "c_12",13 as "c_13",14 as "c_14",15 as "c_15",16 as "c_16",17 as "c_17",18 as "c_18",19 as "c_19",20 as "c_20",
                   21 as "c_21",22 as "c_22",23 as "c_23",24 as "c_24",25 as "c_25",26 as "c_26",27 as "c_27",28 as "c_28",29 as "c_29",30 as "c_30",
                   31 as "c_31",32 as "c_32",33 as "c_33",34 as "c_34",35 as "c_35",36 as "c_36",37 as "c_37",38 as "c_38",39 as "c_39",40 as "c_40",
                   41 as "c_41",42 as "c_42",43 as "c_43",44 as "c_44",45 as "c_45",46 as "c_46",47 as "c_47",48 as "c_48",49 as "c_49",50 as "c_50",
                   51 as "c_51",52 as "c_52",53 as "c_53",54 as "c_54",55 as "c_55",56 as "c_56",57 as "c_57",58 as "c_58",59 as "c_59",60 as "c_60"
)
)
order by com_org
) ff
  on ff.com_org = rr.org_id
]'
            || l_empty_params
            || CHR (10)
            || '
order by org_num';
        l_sql_01 := REPLACE (l_sql_01, 'QuarteR', l_qq);

        -- dbms_output.put_line(l_sql_01) ;

        RDM$RTFL.AddParam (l_jbr_id, 'c_qq', l_qq);
        RDM$RTFL.AddParam (l_jbr_id, 'c_yyyy', TO_CHAR (l_dt, 'yyyy'));
        RDM$RTFL.AddParam (l_jbr_id, 'c_yyyy2', TO_CHAR (l_dt, 'yyyy') + 1);

        RDM$RTFL.AddDataSet (l_jbr_id, 'ds_reg', l_sql_01);


        RDM$RTFL.PutReportToWorkingQueue (l_jbr_id);
        RETURN l_jbr_id;
    END;


    FUNCTION RPT_USER_LIST (p_rt_id    IN NUMBER,
                            p_org_id   IN NUMBER,
                            p_rpt_st   IN VARCHAR2)
        RETURN NUMBER
    IS
        --l_sum  number(18,2);
        --l_cnt  number(14,0);
        --l_rows_cnt  number(14,0);
        l_sql      VARCHAR2 (32000) := '';
        l_jbr_id   NUMBER;
        --l_dt DATE := trunc(sysdate, 'dd');
        --l_qq   varchar2(10) := to_char(l_dt, 'Q');
        --l_org_name varchar2(1000);
        l_rpt_st   VARCHAR2 (100);
    --l_rpt     clob;
    BEGIN
        l_jbr_id := uss_esr.RDM$RTFL.InitReport (p_rt_id);
        --raise_application_error(-20000, p_dt || ';' || p_org_id || ';' || p_npc_id);

        l_sql :=
               'select u.WU_ORG as c_org,
        u.WU_LOGIN as c_login,
        u.WU_PIB as c_pib,
        null/*u.wu_locked*/ as c_st,
        null /*LISTAGG(ur.wr_name, '','') WITHIN GROUP (order by ur.wr_ss_code, ur.wr_name)*/ as c_roles,
        to_char(wu_cr_dt, ''dd.mm.yyyy'') as c_dt
from ikis_sysweb.v$w_users_4gic u
--join ikis_sysweb.v$user_roles ur on u.WU_ID = ur.wu_id
---join ikis_sysweb.v$w_roles r on ur.
where 1=1
'
            || CASE
                   WHEN uss_esr.tools.GetCurrOrg = p_org_id
                   THEN
                       ' and u.wu_org = ' || p_org_id
                   ELSE
                          ' and u.wu_org in (select org_id from ikis_sus.v_opfu where org_org = '
                       || p_org_id
               END
            || ' '
            || CASE
                   WHEN p_rpt_st = 'ALL' THEN ' '
                   ELSE ' and u.wu_locked = ''' || p_rpt_st || ''' '
               END
            || '
group by u.WU_ORG, u.WU_LOGIN, u.WU_PIB/*, u.wu_locked*/, to_char(wu_cr_dt, ''dd.mm.yyyy'')
';
        l_rpt_st := p_rpt_st;

        uss_esr.RDM$RTFL.AddParam (l_jbr_id, 'p_rpt_org', p_org_id);
        uss_esr.RDM$RTFL.AddParam (l_jbr_id,
                                   'p_rpt_dt',
                                   TO_CHAR (SYSDATE, 'dd.mm.yyyy'));
        uss_esr.RDM$RTFL.AddParam (l_jbr_id, 'p_rpt_st', l_rpt_st);

        uss_esr.RDM$RTFL.AddDataSet (l_jbr_id, 'ds', l_sql);

        uss_esr.RDM$RTFL.PutReportToWorkingQueue (l_jbr_id);
        RETURN l_jbr_id;
    END;

    PROCEDURE RegisterReport (p_rt_id      IN     NUMBER,
                              p_start_dt   IN     DATE,
                              p_stop_dt    IN     DATE,
                              p_org_id     IN     NUMBER,
                              p_val_1      IN     VARCHAR2,
                              p_jbr_id        OUT DECIMAL)
    IS
        l_code   VARCHAR2 (50);
    BEGIN
        TOOLS.validate_param (p_val_1);

        SELECT t.rt_code
          INTO l_code
          FROM rpt_templates t
         WHERE t.rt_id = p_rt_id;

        p_jbr_id :=
            CASE
                WHEN l_code = 'PAY_NEED_R1'
                THEN
                    PAY_NEED_R1 (p_rt_id,
                                 p_start_dt,
                                 p_val_1,
                                 p_org_id)
                WHEN l_code = 'USE_FUNDS_R'
                THEN
                    USE_FUNDS_REG (p_rt_id, p_start_dt, p_org_id)
                WHEN l_code = 'USE_FUNDS_C'
                THEN
                    USE_FUNDS_MSP (p_rt_id, p_start_dt)
                WHEN l_code = 'USER_LIST_R1'
                THEN
                    RPT_USER_LIST (p_rt_id    => p_rt_id,
                                   p_org_id   => p_org_id,
                                   p_rpt_st   => p_val_1)
                ELSE
                    NULL
            END;
    END;
END;
/