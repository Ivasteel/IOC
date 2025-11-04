/* Formatted on 8/12/2025 5:56:53 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_PERSON.API$AP_SEND_MESSAGE_PERS
IS
    -- Author  : SERHII
    -- Created : 25.07.2023 11:17:41
    -- Purpose : #89850 Функції відправки інформаційних повідомленнь для ВПО

    -- Public type declarations
    -- type <TypeName> is <Datatype>;

    -- Public constant declarations
    -- <ConstantName> constant <Datatype> := <Value>;

    -- Public variable declarations
    -- <VariableName> <Datatype>;

    -- Public function and procedure declarations
    -- function <FunctionName>(<Parameter> <Datatype>) return <Datatype>;
    --
    FUNCTION Set_Values_Params_Arr (p_ent_Id     IN NUMBER,
                                    p_ent_Type   IN VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION Get_Templ_By_Reason (p_Rnp_Code IN VARCHAR2)
        RETURN INTEGER;

    -- Purpose : Ставить повідомлення у чергу
    PROCEDURE Put_Notification2Queue (
        p_Ent_Type       IN     VARCHAR2 DEFAULT 'PC_DECISION',
        p_Ent_Id         IN     PLS_INTEGER,
        p_Templ_Grp_Id   IN     PLS_INTEGER,
        p_Result            OUT VARCHAR2);
END API$AP_SEND_MESSAGE_Pers;
/


/* Formatted on 8/12/2025 5:56:56 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_PERSON.API$AP_SEND_MESSAGE_PERS
IS
    -- Private type declarations
    TYPE t_Params_Arr IS TABLE OF VARCHAR2 (1000)
        INDEX BY VARCHAR2 (100);

    /*
    type t_rec_templ is record(
      tt_title  uss_ndi.v_NDI_NT_TEMPLATE.ntt_title%TYPE,
      tt_text   uss_ndi.v_NDI_NT_TEMPLATE.ntt_text%TYPE );
  */

    g_Params_Arr   t_Params_Arr; --пари: #параметр# = 'Значення' '#sc='Sc_Unique'


    -- uss_ndi
    FUNCTION GetTmplText (
        p_Tmpl_Grp_Id   IN uss_ndi.v_NDI_NT_TEMPLATE_GROUP.ntg_id%TYPE,
        p_Tmpl_Type     IN uss_ndi.v_NDI_NT_TEMPLATE.ntt_info_tp%TYPE DEFAULT 'EMAIL')
        RETURN uss_ndi.v_NDI_NT_TEMPLATE.ntt_text%TYPE
    IS
        l_Res   uss_ndi.v_NDI_NT_TEMPLATE.ntt_text%TYPE;
    BEGIN
        SELECT t.ntt_text
          INTO l_Res
          FROM uss_ndi.v_NDI_NT_TEMPLATE_GROUP  g
               JOIN uss_ndi.v_NDI_NT_TEMPLATE t ON g.ntg_id = t.ntt_ntg
         WHERE     g.ntg_id = p_Tmpl_Grp_Id
               AND t.ntt_info_tp = p_Tmpl_Type
               AND g.ntg_is_blocked = 'N';

        RETURN (l_Res);
    END GetTmplText;

    --Наповнюємо масив ключами з імен тегів (змінних) темплейта
    PROCEDURE Init_Params_Arr (p_Tmpl_Text IN VARCHAR2)
    IS
        l_StartIndex   INTEGER := 1;
        l_EndIndex     INTEGER;
        l_Tag          VARCHAR2 (100);
    BEGIN
        g_Params_Arr.DELETE;
        g_Params_Arr ('sc') := '';

        LOOP
            l_StartIndex := INSTR (p_Tmpl_Text, '#', l_StartIndex);
            EXIT WHEN l_StartIndex = 0;
            l_EndIndex := INSTR (p_Tmpl_Text, '#', l_StartIndex + 1);
            -- Виділяємо тег між початковим і кінцевим індексами
            l_Tag :=
                SUBSTR (p_Tmpl_Text,
                        l_StartIndex + 1,
                        l_EndIndex - l_StartIndex - 1);
            g_Params_Arr (l_Tag) := '';
            -- Переміщуємо вказівник початку пошуку після кінцевого індексу
            l_StartIndex := l_EndIndex + 1;
        END LOOP;
    END Init_Params_Arr;

    /*
    1 функция принимает :
      1. тип сущности.
      2. ид сущности.
      по этим параметрам наполняется переменная с ассоциативным массивом. Например.
    2 функция (или несколько вариантов этой фукнции - с отсылкой (ака формированием задачи на отсылку) сразу или "потом") принимает ид группы шаблонов и SC. ФОрмирует по шаблону (извлекая из него имана) - данные. И пишет куда надо.
    */

    FUNCTION Set_Values_Params_Arr (p_ent_Id     IN NUMBER,
                                    p_ent_Type   IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Res   VARCHAR2 (500) := 'Success';
        l_Tag   VARCHAR2 (100);
        --l_Ent_Values t_Params_Arr;
        l_sc    USS_PERSON.v_SOCIALCARD.SC_UNIQUE%TYPE;
        l_fn    USS_PERSON.v_SC_IDENTITY.sci_fn%TYPE;
        l_mn    USS_PERSON.v_SC_IDENTITY.sci_fn%TYPE;
        l_ln    USS_PERSON.v_SC_IDENTITY.sci_fn%TYPE;
    /*
       sc Номер соц. Карти
       pib ПІБ
       ib Ім'я По-батькові
       sd Дата початку виплати ВПО
       pm За який місяць виплата
       ed Дата припинення виплати
       rd Дата поновлення виплати ВПО
       ml Електронна пошта
    */
    BEGIN
        /*
          IF p_ent_Type = 'Appeal' THEN
            SELECT qp_num, ap_reg_dt
            INTO l_ap_num, l_ap_reg_dt
            FROM appeal
            WHERE ap_id = p_enr_id;

            l_Params_Arr('an') := l_ap_num;
            l_Params_Arr('ard') := l_ap_reg_dt;
          END IF;
        */

        IF p_ent_Type = 'SC_CHANGE'
        THEN
            SELECT SC_UNIQUE,
                   sci_fn,
                   sci_mn,
                   sci_ln
              INTO l_sc,
                   l_fn,
                   l_mn,
                   l_ln
              FROM USS_PERSON.v_SC_CHANGE
                   LEFT JOIN USS_PERSON.v_SC_IDENTITY ON scc_sci = sci_id
                   LEFT JOIN USS_PERSON.v_SOCIALCARD ON scc_sc = sc_id
             WHERE scc_id = p_ent_Id;
        ELSIF p_ent_Type = 'xxxx'
        THEN
            NULL;
        ELSE
            --  l_Res := 'Невірний тип сутності: '||p_ent_Type ;
            raise_application_error (
                -20000,
                'Невідомий тип сутності: ' || p_ent_Type);
        END IF;

        l_Tag := g_Params_Arr.FIRST;

        WHILE l_Tag IS NOT NULL
        LOOP
            IF l_Tag = 'sc'
            THEN
                g_Params_Arr (l_Tag) := l_sc;
            ELSIF l_Tag = 'ib'
            THEN
                g_Params_Arr (l_Tag) := l_fn || ' ' || l_mn;
            ELSIF l_Tag = 'pib'
            THEN
                g_Params_Arr (l_Tag) := l_ln || ' ' || l_fn || ' ' || l_mn;
            END IF;

            l_Tag := g_Params_Arr.NEXT (l_Tag);   -- Get next element of array
        END LOOP;

        RETURN (l_Res);
    END Set_Values_Params_Arr;

    -- Author  : SERHII
    -- Created : 31.07.2023 1:00:14
    -- Purpose :
    FUNCTION GetParamsSerialazed
        RETURN VARCHAR2
    IS
        l_Res   VARCHAR2 (4000) := '';
        l_Tag   VARCHAR2 (100);
    BEGIN
        l_Tag := g_Params_Arr.FIRST;

        WHILE l_Tag IS NOT NULL
        LOOP
            l_Res :=
                   l_Res
                || '#'
                || l_Tag
                || '='
                || TO_CHAR (g_Params_Arr (l_Tag));
            l_Tag := g_Params_Arr.NEXT (l_Tag);
        END LOOP;

        RETURN (l_Res);
    END GetParamsSerialazed;


    -- Purpose : Ставить повідомлення у чергу
    PROCEDURE Put_Notification2Queue (
        p_Ent_Type       IN     VARCHAR2 DEFAULT 'PC_DECISION',
        p_Ent_Id         IN     PLS_INTEGER,
        p_Templ_Grp_Id   IN     PLS_INTEGER,
        p_Result            OUT VARCHAR2)
    IS
        c_Src_Vst   CONSTANT VARCHAR2 (10) := '35';

        l_TemplTxt           uss_ndi.v_NDI_NT_TEMPLATE.ntt_text%TYPE;
        l_Sc_Id              NUMBER;                            --ІД соцкартки
        l_Ntm_Id             NUMBER;
        l_Error              VARCHAR2 (4000);
        -- l_Ap_St     VARCHAR2(100);
        -- l_Sc_Unique VARCHAR2(100);
        l_Title              VARCHAR2 (1000);
        l_Text               VARCHAR2 (4000);
    BEGIN
        l_TemplTxt := GetTmplText (p_Templ_Grp_Id, 'EMAIL'); -- получили текст шаблона

        Init_Params_Arr (l_TemplTxt);      -- пустой массив параметров шаблона

        p_Result := Set_Values_Params_Arr (p_ent_Type, p_ent_Id); -- нашли значения для параметров

        IF p_Result = 'Success'
        THEN
            l_Title := CHR (38) || TO_CHAR (p_Templ_Grp_Id);
            l_Text :=
                   CHR (38)
                || TO_CHAR (p_Templ_Grp_Id)
                || GetParamsSerialazed (); --собирает строку #ib='Имя'#sc='23452345'
            uss_person.API$NT_API.SendOneByNumident (
                p_Numident   => NULL,
                p_Sc         => l_Sc_Id,
                p_Source     => c_Src_Vst,
                p_Type       => 'COM',
                p_Title      => l_Title,
                p_Text       => l_Text,
                p_Id         => l_Ntm_Id,
                p_Error      => l_Error);

            IF l_Ntm_Id IS NOT NULL
            THEN
                NULL; -- уточнить как можно помечать строки в очереди на отрправку: сохранять где-то l_Ntm_Id или признак в самой строке?
            ELSE
                p_Result := l_Error;
            END IF;
        END IF;
    END Put_Notification2Queue;

    FUNCTION Get_Templ_By_Reason (p_Rnp_Code IN VARCHAR2)
        RETURN INTEGER
    IS
        l_Templ_Grp_Id   INTEGER;
    BEGIN
        IF p_Rnp_Code = 'XXX_MF_OVER30'
        THEN
            l_Templ_Grp_Id := 180;
        ELSIF p_Rnp_Code = 'MF_OVER30'
        THEN
            l_Templ_Grp_Id := 310;
        ELSIF p_Rnp_Code = 'XXXX'
        THEN
            l_Templ_Grp_Id := 21;
        ELSE
            l_Templ_Grp_Id := NULL;
        END IF;

        RETURN (l_Templ_Grp_Id);
    END Get_Templ_By_Reason;
BEGIN
    NULL;
/*
  cursor blocks is
    select *
    from pc_block b
      JOIN pc_decision d ON pd_id = pcb_pd
      JOIN uss_ndi.v_ndi_reason_not_pay ON b_rnp = rnp_id;
    where 1=1
      and  uss_ndi.v_ndi_reason_not_pay.rnp_is_need_inform = 'T'
--      and ....
    ;

  open blocks;
  loop
    fetch blocks into bl;
    exit when blocks%notfound;

    if bl.reason_code = 123 then
      Put_Notification2Queue(bl.PCB_AP_SRC, 'Appeal', 165, l_Res);
    elsif bl.reason_code = 456 then
      Put_Notification2Queue(bl.PCB_AP_SRC, 'Appeal', 180, l_Res);
  --elsif ...
    end if;

  end loop;
  close blocks;
*/

END API$AP_SEND_MESSAGE_Pers;
/