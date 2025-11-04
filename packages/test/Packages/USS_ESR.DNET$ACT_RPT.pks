/* Formatted on 8/12/2025 5:48:27 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.DNET$ACT_RPT
IS
    -- Author  : PAVLO
    -- Created : 19.07.2023 16:48:37
    -- Purpose : Підготовка друкованих форм для актів


    TYPE R_Person_for_act IS RECORD
    (
        atp_id             at_person.atp_id%TYPE,
        pip                VARCHAR2 (250),                               --ПІБ
        birth_dt           VARCHAR2 (10),                    --Дата народження
        is_disabled        VARCHAR2 (20),                       --Інвалідність
        is_capable         VARCHAR2 (20),                       --Дієздатність
        live_address       at_person.atp_live_address%TYPE, --Місце проживання
        work_place         at_person.atp_work_place%TYPE, --Місце навчання та / або місце роботи
        is_adr_matching    VARCHAR2 (20),    --Реєстрація за місцем проживання
        phone              at_person.atp_phone%TYPE, --Контактний номер телефону
        relation_tp        VARCHAR2 (20),                   --Родинний зв’язок
        App_Tp             VARCHAR2 (20)                        --Тип учасника
    );

    TYPE T_Person_for_act IS TABLE OF R_Person_for_act;

    TYPE TVarchar2 IS TABLE OF VARCHAR2 (4000);

    TYPE TInt IS TABLE OF INTEGER;

    --повертає at_section_feature.atef_notes
    FUNCTION get_AtFtrNt (p_at_id   act.at_id%TYPE,
                          p_atp     at_person.atp_id%TYPE:= NULL,
                          p_nda     NUMBER)
        RETURN VARCHAR2;

    --повертає at_section_feature.atef_feature
    FUNCTION get_AtFtr (p_at_id   act.at_id%TYPE,
                        p_atp     at_person.atp_id%TYPE:= NULL,
                        p_nda     NUMBER)
        RETURN VARCHAR2;

    FUNCTION get_AtFtrChk (p_at_id   act.at_id%TYPE,
                           p_atp     at_person.atp_id%TYPE:= NULL,
                           p_nda     NUMBER)
        RETURN VARCHAR2;

    --повертає at_section.atef_feature.ate_chield_info
    FUNCTION get_AtSctChld (p_at_id   act.at_id%TYPE,
                            p_atp     at_person.atp_id%TYPE:= NULL,
                            p_nng     at_section.ate_nng%TYPE)
        RETURN VARCHAR2;

    --повертає at_section.atef_feature.ate_parent_info
    FUNCTION get_AtSctPrnt (p_at_id   act.at_id%TYPE,
                            p_atp     at_person.atp_id%TYPE,
                            p_nng     at_section.ate_nng%TYPE)
        RETURN VARCHAR2;

    --повертає at_section.atef_feature.ate_notes
    FUNCTION get_AtSctNt (p_at_id   act.at_id%TYPE,
                          p_atp     at_person.atp_id%TYPE,
                          p_nng     at_section.ate_nng%TYPE)
        RETURN VARCHAR2;

    FUNCTION get_AtPerson (p_at NUMBER, p_atp NUMBER)
        RETURN R_Person_for_act;

    --члени родини
    FUNCTION At_Person_for_act (p_at IN NUMBER)
        RETURN T_Person_for_act
        PIPELINED;

    --АКТ оцінки потреб сім’ї/особи
    FUNCTION BUILD_ACT_NEEDS_ASSESSMENT (p_at_id IN NUMBER)
        RETURN BLOB;
END DNET$Act_Rpt;
/


GRANT EXECUTE ON USS_ESR.DNET$ACT_RPT TO DNET_PROXY
/

GRANT EXECUTE ON USS_ESR.DNET$ACT_RPT TO II01RC_USS_ESR_RPT
/

GRANT EXECUTE ON USS_ESR.DNET$ACT_RPT TO II01RC_USS_ESR_WEB
/

GRANT EXECUTE ON USS_ESR.DNET$ACT_RPT TO USS_RPT
/


/* Formatted on 8/12/2025 5:49:28 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.DNET$ACT_RPT
IS
    C_TEST    CONSTANT INTEGER := NULL; --для відладки, 1 - ф-ції будуть виводити значення nda
    c_check   CONSTANT VARCHAR2 (200)
        := '{\rtlch\fcs1 \af0 \ltrch\fcs0 \lang1033\langfe1033\langnp1033\insrsid16478594 {\field{\*\fldinst SYMBOL 80 \\f "Wingdings 2" \\s 11}{\fldrslt\f157\fs22}}}' ;

    PROCEDURE addparam (p_Script_Name VARCHAR2, p_Script_Text VARCHAR2)
    IS
    BEGIN
        rdm$rtfl_univ.addparam (p_Param_Name    => p_Script_Name,
                                p_Param_Value   => p_Script_Text);
    END;

    --повертає at_section_feature.atef_notes
    FUNCTION get_AtFtrNt (p_at_id   act.at_id%TYPE,
                          p_atp     at_person.atp_id%TYPE:= NULL,
                          p_nda     NUMBER)
        RETURN VARCHAR2
    IS
        CURSOR cur IS
            SELECT f.atef_notes
              FROM at_section s, at_section_feature f
             WHERE     s.ate_at = p_at_id
                   AND (p_atp IS NULL OR s.ate_atp = p_atp)
                   AND f.atef_ate = s.ate_id
                   AND f.atef_nda = p_nda;

        r   at_section_feature.atef_notes%TYPE;
    BEGIN
        IF C_TEST = 1
        THEN
            RETURN p_nda;
        END IF;

        OPEN cur;

        FETCH cur INTO r;

        CLOSE cur;

        RETURN r;
    END;

    --повертає at_section_feature.atef_feature
    FUNCTION get_AtFtr (p_at_id   act.at_id%TYPE,
                        p_atp     at_person.atp_id%TYPE:= NULL,
                        p_nda     NUMBER)
        RETURN VARCHAR2
    IS
        CURSOR cur IS
            SELECT f.atef_feature
              FROM at_section s, at_section_feature f
             WHERE     s.ate_at = p_at_id
                   AND (p_atp IS NULL OR s.ate_atp = p_atp)
                   AND f.atef_ate = s.ate_id
                   AND f.atef_nda = p_nda;

        r   at_section_feature.atef_feature%TYPE;
    BEGIN
        IF C_TEST = 1
        THEN
            RETURN p_nda;
        END IF;

        OPEN cur;

        FETCH cur INTO r;

        CLOSE cur;
    END;

    FUNCTION get_AtFtrChk (p_at_id   act.at_id%TYPE,
                           p_atp     at_person.atp_id%TYPE:= NULL,
                           p_nda     NUMBER)
        RETURN VARCHAR2
    IS
        CURSOR cur IS
            SELECT f.atef_feature
              FROM at_section s, at_section_feature f
             WHERE     s.ate_at = p_at_id
                   AND (p_atp IS NULL OR s.ate_atp = p_atp)
                   AND f.atef_ate = s.ate_id
                   AND f.atef_nda = p_nda;

        r   at_section_feature.atef_feature%TYPE;
    BEGIN
        IF C_TEST = 1
        THEN
            RETURN p_nda;
        END IF;

        OPEN cur;

        FETCH cur INTO r;

        CLOSE cur;

        IF r = 'T'
        THEN
            RETURN c_check;
        ELSE
            RETURN NULL;
        END IF;
    END;

    --повертає at_section.atef_feature.ate_chield_info
    FUNCTION get_AtSctChld (p_at_id   act.at_id%TYPE,
                            p_atp     at_person.atp_id%TYPE:= NULL,
                            p_nng     at_section.ate_nng%TYPE)
        RETURN VARCHAR2
    IS
        CURSOR cur IS
            SELECT s.ate_chield_info
              FROM at_section s
             WHERE     s.ate_at = p_at_id
                   AND (p_atp IS NULL OR s.ate_atp = p_atp)
                   AND s.ate_nng = p_nng;

        r   at_section.ate_chield_info%TYPE;
    BEGIN
        IF C_TEST = 1
        THEN
            RETURN p_nng;
        END IF;

        OPEN cur;

        FETCH cur INTO r;

        CLOSE cur;

        RETURN r;
    END;

    --повертає at_section.atef_feature.ate_parent_info
    FUNCTION get_AtSctPrnt (p_at_id   act.at_id%TYPE,
                            p_atp     at_person.atp_id%TYPE,
                            p_nng     at_section.ate_nng%TYPE)
        RETURN VARCHAR2
    IS
        CURSOR cur IS
            SELECT s.ate_parent_info
              FROM at_section s
             WHERE     s.ate_at = p_at_id
                   AND s.ate_atp = p_atp
                   AND s.ate_nng = p_nng;

        r   at_section.ate_parent_info%TYPE;
    BEGIN
        IF C_TEST = 1
        THEN
            RETURN p_nng;
        END IF;

        OPEN cur;

        FETCH cur INTO r;

        CLOSE cur;

        RETURN r;
    END;

    --повертає at_section.atef_feature.ate_notes
    FUNCTION get_AtSctNt (p_at_id   act.at_id%TYPE,
                          p_atp     at_person.atp_id%TYPE,
                          p_nng     at_section.ate_nng%TYPE)
        RETURN VARCHAR2
    IS
        CURSOR cur IS
            SELECT s.ate_notes
              FROM at_section s
             WHERE     s.ate_at = p_at_id
                   AND s.ate_atp = p_atp
                   AND s.ate_nng = p_nng;

        r   at_section.ate_notes%TYPE;
    BEGIN
        IF C_TEST = 1
        THEN
            RETURN p_nng;
        END IF;

        OPEN cur;

        FETCH cur INTO r;

        CLOSE cur;

        RETURN r;
    END;

    FUNCTION chk_val (p_chk_val VARCHAR2, p_val VARCHAR2)
        RETURN VARCHAR2
    IS
    BEGIN
        IF p_chk_val = p_val
        THEN
            RETURN c_check;
        ELSE
            RETURN NULL;
        END IF;
    END;

    FUNCTION mOthers (p_var TVarchar2, p_delmt VARCHAR2:= CHR (10))
        RETURN VARCHAR2
    IS
        l_str   VARCHAR2 (32000);
    BEGIN
        SELECT LISTAGG (COLUMN_VALUE, p_delmt) WITHIN GROUP (ORDER BY 1)
          INTO l_str
          FROM TABLE (p_var);

        RETURN l_str;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    FUNCTION get_AtDocAtrStr (p_at_id NUMBER, p_nda NUMBER)
        RETURN VARCHAR2
    IS
        CURSOR cur IS
            SELECT a.atda_val_string
              FROM at_document d, at_document_attr a
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

        OPEN cur;

        FETCH cur INTO r;

        CLOSE cur;

        RETURN r;
    END;

    FUNCTION get_AtDocAtrDt (p_at_id NUMBER, p_nda NUMBER)
        RETURN VARCHAR2
    IS
        CURSOR cur IS
            SELECT a.atda_val_dt
              FROM at_document d, at_document_attr a
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

    --повертає атрибути в одну строку
    --p_nda = '2955, 2956, 2957'
    FUNCTION get_AtDocAtrRow (p_at_id   NUMBER,
                              p_nda     VARCHAR2,
                              dlmt      VARCHAR2:= ' ')
        RETURN VARCHAR2
    IS
        l_result   uss_esr.pd_document_attr.pdoa_val_string%TYPE;
    BEGIN
        FOR c IN (SELECT TO_NUMBER (COLUMN_VALUE) nda FROM XMLTABLE (p_nda))
        LOOP
            IF C_TEST = 1
            THEN
                l_result := l_result || dlmt || c.nda;
            ELSE
                l_result :=
                    l_result || dlmt || get_AtDocAtrStr (p_at_id, c.nda);
            END IF;
        END LOOP;

        RETURN TRIM (l_result);
    END;

    FUNCTION get_pip (p_sc IN NUMBER)
        RETURN uss_person.v_sc_identity%ROWTYPE
    IS
        l_sci   uss_person.v_sc_identity%ROWTYPE;
    BEGIN
        SELECT i.*
          INTO l_sci
          FROM uss_person.v_sc_change c, uss_person.v_sc_identity i
         WHERE c.scc_sc = p_sc AND i.sci_id = c.scc_sci
         FETCH FIRST ROW ONLY;

        RETURN l_sci;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN l_sci;
    END;

    --адреса проживання особи (анкета док.605)
    FUNCTION Get_adr_fact_605 (p_ap_id NUMBER, p_sc_id NUMBER)
        RETURN VARCHAR2
    IS
        CURSOR c_adr IS
            SELECT t.*,
                      NVL2 (t.ind, t.ind || ' ', NULL)
                   || NVL2 (t.katot, t.katot || ', ', NULL)
                   || NVL2 (t.strit, t.strit || ' ', NULL)
                   || NVL2 (t.bild, t.bild || ' ', NULL)
                   || NVL2 (t.korp, 'корп.' || t.korp || ' ', NULL)
                   || NVL2 (t.kv, 'кв.' || t.kv, NULL)    adr
              FROM (SELECT MAX (DECODE (a.apda_nda, 1625, a.apda_val_string))
                               ind,                                   --Індекс
                           MAX (DECODE (a.apda_nda, 1618, a.apda_val_string))
                               katot,                                --КАТОТТГ
                           MAX (
                               NVL (
                                   DECODE (a.apda_nda,
                                           1632, a.apda_val_string),
                                   DECODE (a.apda_nda,
                                           1640, a.apda_val_string)))
                               strit, --Вулиця (вибір із довідника)/Вулиця текст
                           MAX (DECODE (a.apda_nda, 1648, a.apda_val_string))
                               bild,                                 --Будинок
                           MAX (DECODE (a.apda_nda, 1654, a.apda_val_string))
                               korp,                                  --Корпус
                           MAX (DECODE (a.apda_nda, 1659, a.apda_val_string))
                               kv                                   --Квартира
                      FROM ap_person p, ap_document d, ap_document_attr a
                     WHERE     p.app_ap = p_ap_id
                           AND p.app_sc = p_sc_id
                           AND p.history_status = 'A'
                           AND d.apd_ndt = 605
                           AND d.history_status = 'A'
                           AND d.apd_app = p.app_id
                           AND a.apda_apd = d.apd_id
                           AND a.history_status = 'A'
                           AND apda_nda IN (1618,
                                            1625,
                                            1632,
                                            1640,
                                            1648,
                                            1654,
                                            1659)) t;

        r   c_adr%ROWTYPE;
    BEGIN
        OPEN c_adr;

        FETCH c_adr INTO r;

        CLOSE c_adr;

        RETURN r.adr;
    END;

    --адреса проживання особи (Акт оцінки потреб сім’ї/особи док.804)
    FUNCTION Get_adr_fact_804 (p_ap_id NUMBER, p_sc_id NUMBER)
        RETURN VARCHAR2
    IS
        CURSOR c_adr IS
            SELECT t.*,
                      NVL2 (t.ind, t.ind || ' ', NULL)
                   || NVL2 (t.katot, t.katot || ', ', NULL)
                   || NVL2 (t.strit, t.strit || ' ', NULL)
                   || NVL2 (t.bild, t.bild || ' ', NULL)
                   || NVL2 (t.korp, 'корп.' || t.korp || ' ', NULL)
                   || NVL2 (t.kv, 'кв.' || t.kv, NULL)    adr
              FROM (SELECT MAX (DECODE (a.apda_nda, 3134, a.apda_val_string))
                               ind,                                   --Індекс
                           MAX (DECODE (a.apda_nda, 3133, a.apda_val_string))
                               katot,                                --КАТОТТГ
                           MAX (
                               NVL (
                                   DECODE (a.apda_nda,
                                           3135, a.apda_val_string),
                                   DECODE (a.apda_nda,
                                           3613, a.apda_val_string)))
                               strit, --Вулиця (вибір із довідника)/Вулиця текст
                           MAX (DECODE (a.apda_nda, 3136, a.apda_val_string))
                               bild,                                 --Будинок
                           MAX (DECODE (a.apda_nda, 3137, a.apda_val_string))
                               korp,                                  --Корпус
                           MAX (DECODE (a.apda_nda, 3138, a.apda_val_string))
                               kv                                   --Квартира
                      FROM ap_person p, ap_document d, ap_document_attr a
                     WHERE     p.app_ap = p_ap_id
                           AND p.app_sc = p_sc_id
                           AND p.history_status = 'A'
                           AND d.apd_ndt = 605
                           AND d.history_status = 'A'
                           AND d.apd_app = p.app_id
                           AND a.apda_apd = d.apd_id
                           AND a.history_status = 'A'
                           AND apda_nda IN (3133,
                                            3134,
                                            3135,
                                            3613,
                                            3136,
                                            3137,
                                            3138)) t;

        r   c_adr%ROWTYPE;
    BEGIN
        OPEN c_adr;

        FETCH c_adr INTO r;

        CLOSE c_adr;

        RETURN r.adr;
    END;

    FUNCTION get_AtPerson (p_at NUMBER, p_atp NUMBER)
        RETURN R_Person_for_act
    IS
        CURSOR cur IS
            SELECT p.atp_id,
                   p.atp_ln || ' ' || p.atp_fn || ' ' || p.atp_mn
                       pip,
                   TO_CHAR (atp_birth_dt, 'dd.mm.yyyy'),     --Дата народження
                   atp_is_disabled,                             --Інвалідність
                   atp_is_capable,                              --Дієздатність
                   atp_live_address,                        --Місце проживання
                   atp_work_place,      --Місце навчання та / або місце роботи
                   atp_is_adr_matching,      --Реєстрація за місцем проживання
                   atp_phone,                      --Контактний номер телефону
                   Rt.Dic_Name
                       AS Atp_Relation_Tp_Name,
                   Appt.Dic_Name
                       AS Atp_App_Tp_Name
              FROM uss_esr.at_person          p,
                   Uss_Ndi.v_Ddn_Relation_Tp  Rt,
                   Uss_Ndi.v_Ddn_App_Tp       Appt
             WHERE     p.atp_at = p_at
                   AND p.atp_id = p_atp
                   AND Rt.Dic_Name(+) = p.Atp_Relation_Tp
                   AND Appt.Dic_Value(+) = p.Atp_App_Tp;

        r   R_Person_for_act;
    BEGIN
        OPEN cur;

        FETCH cur INTO r;

        CLOSE cur;

        RETURN r;
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
                   WHERE p.atp_at = p_at)
        LOOP
            r := get_AtPerson (p_at => p_at, p_atp => c.atp_id);
            PIPE ROW (r);
        END LOOP;
    END;

    FUNCTION ds_child (p_at_id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_sql   VARCHAR2 (32000);
    BEGIN
        l_sql :=
            q'[
with
function atr(p_atp number, p_nda number)return varchar2 is
begin
 return uss_esr.DNET$Act_Rpt.get_AtFtr(#p_at_id#,p_atp,p_nda);
end;
function atrNt(p_atp number, p_nda number)return varchar2 is
begin
 return uss_esr.DNET$Act_Rpt.get_AtFtrNt(#p_at_id#,p_atp,p_nda);
end;
function atrChk(p_atp number, p_nda number)return varchar2 is
begin
 return uss_esr.DNET$Act_Rpt.get_AtFtrChk(#p_at_id#,p_atp,p_nda);
end;

function v return varchar2 is
begin
return '{\rtlch\fcs1 \af0 \ltrch\fcs0 \lang1033\langfe1033\langnp1033\insrsid16478594 {\field{\*\fldinst SYMBOL 80 \\f "Wingdings 2" \\s 11}{\fldrslt\f157\fs22}}}';
end;

select p.atp_ln||' '||p.atp_fn||' '||p.atp_mn F18,
       decode(f19.dic_value, 'N', v) F19_1,
       decode(f19.dic_value, 'AVL', v) F19_2,
       decode(f19.dic_value, 'F', v) F19_3,
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
       f36.ate_chield_info F36,
       f36.ate_parent_info F37,
       f36.ate_notes    F38,
       --2) харчування
       decode(f39.dic_value, 'N', v) F39_1,
       decode(f39.dic_value, 'AVL', v) F39_2,
       decode(f39.dic_value, 'F', v) F39_3,
       atrChk(atp_id,3163) F40,
       atrChk(atp_id,3164) F41,
       atrChk(atp_id,3165) F42,
       atrChk(atp_id,3166) F43,
       f44.ate_chield_info F44,
       f44.ate_parent_info F45,
       f44.ate_notes    F46,
       --3) навчання та досягнення
       decode(f47.dic_value, 'N', v) F47_1,
       decode(f47.dic_value, 'AVL', v) F47_2,
       decode(f47.dic_value, 'F', v) F47_3,
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
       f65.ate_chield_info F65,
       f65.ate_parent_info F66,
       f65.ate_notes    F67,
       --4) емоційний стан
       decode(f68.dic_value, 'N', v) F68_1,
       decode(f68.dic_value, 'AVL', v) F68_2,
       decode(f68.dic_value, 'F', v) F68_3,
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
       f79.ate_chield_info F79,
       f79.ate_parent_info F80,
       f79.ate_notes    F81,
       --5) шкідливі звички
       decode(f82.dic_value, 'N', v) F82_1,
       decode(f82.dic_value, 'AVL', v) F82_2,
       decode(f82.dic_value, 'F', v) F82_3,
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
       atrNt(atp_id,3221) F98,
       f99.ate_chield_info F99,
       f99.ate_parent_info F100,
       f99.ate_notes    F101,
       --6) сімейні та соціальні стосунки
       decode(f102.dic_value, 'N', v) F102_1,
       decode(f102.dic_value, 'AVL', v) F102_2,
       decode(f102.dic_value, 'F', v) F102_3,
       atrChk(atp_id,3238) F103,
       atrChk(atp_id,3239) F104,
       atrChk(atp_id,3240) F105,
       atrChk(atp_id,3241) F106,
       atrChk(atp_id,3242) F107,
       atrChk(atp_id,3243) F108,
       atrChk(atp_id,3244) F109,
       atrChk(atp_id,3245) F110,
       f111.ate_chield_info F111,
       f111.ate_parent_info F112,
       f111.ate_notes    F113,
       --7) самообслуговування
       decode(f114.dic_value, 'N', v) F114_1,
       decode(f114.dic_value, 'AVL', v) F114_2,
       decode(f114.dic_value, 'F', v) F114_3,
       atrChk(atp_id,3250) F115,
       atrChk(atp_id,3251) F116,
       atrChk(atp_id,3252) F117,
       atrChk(atp_id,3253) F118,
       atrChk(atp_id,3254) F119,
       atrChk(atp_id,3255) F120,
       f121.ate_chield_info F121,
       f121.ate_parent_info F122,
       f121.ate_notes    F123,
       atrNt(atp_id,3258) F124

from uss_esr.v_At_Person p,
     uss_ndi.v_ddn_ss_avl f19,
     uss_esr.v_at_section f36,
     uss_ndi.v_ddn_ss_avl f39,
     uss_esr.v_at_section f44,
     uss_ndi.v_ddn_ss_avl f47,
     uss_esr.v_at_section f65,
     uss_ndi.v_ddn_ss_avl f68,
     uss_esr.v_at_section f79,
     uss_ndi.v_ddn_ss_avl f82,
     uss_esr.v_at_section f99,
     uss_ndi.v_ddn_ss_avl f102,
     uss_esr.v_at_section f111,
     uss_ndi.v_ddn_ss_avl f114,
     uss_esr.v_at_section f121
where p.atp_at = #p_at_id# --862
--and months_between(sysdate, p.birth_dt)/12 < 18; --ознака дитини
and f19.dic_value(+)= atr(atp_id,3142)
and f36.ate_at(+)= p.atp_at and f36.ate_atp(+)= p.atp_id and f36.ate_nng(+)= 119
and f39.dic_value(+)= atr(atp_id,3162)
and f44.ate_at(+)= p.atp_at and f44.ate_atp(+)= p.atp_id and f44.ate_nng(+)= 120
and f47.dic_value(+)= atr(atp_id,3170)
and f65.ate_at(+)= p.atp_at and f65.ate_atp(+)= p.atp_id and f65.ate_nng(+)= 121
and f68.dic_value(+)= atr(atp_id,3191)
and f79.ate_at(+)= p.atp_at and f79.ate_atp(+)= p.atp_id and f79.ate_nng(+)= 122
and f82.dic_value(+)= atr(atp_id,3205)
and f99.ate_at(+)= p.atp_at and f99.ate_atp(+)= p.atp_id and f99.ate_nng(+)= 123
and f102.dic_value(+)= atr(atp_id,3237)
and f111.ate_at(+)= p.atp_at and f111.ate_atp(+)= p.atp_id and f111.ate_nng(+)= 125
and f114.dic_value(+)= atr(atp_id,3249)
and f121.ate_at(+)= p.atp_at and f121.ate_atp(+)= p.atp_id and f121.ate_nng(+)= 126
  ]';
        RETURN REPLACE (l_sql, '#p_at_id#', p_at_id);
    END;


    --АКТ оцінки потреб сім’ї/особи
    FUNCTION BUILD_ACT_NEEDS_ASSESSMENT (p_at_id IN NUMBER)
        RETURN BLOB
    IS
        l_jbr_id   NUMBER;
        l_result   BLOB;
        aInt       TInt;

        CURSOR c_at IS
            SELECT a.at_ap,
                   a.at_pc,
                   a.at_org,
                   a.at_action_start_dt,
                   a.at_action_stop_dt,
                   a.at_family_info,
                   a.at_live_address,
                   a.at_case_class,
                   sc.sc_unique,
                   p.atp_id,
                   pc.pc_sc,
                   p.atp_tp
              FROM act                      a,
                   personalcase             pc,
                   At_Person                p,
                   uss_person.v_socialcard  sc
             WHERE     a.at_id = p_at_id
                   AND pc.pc_id = a.at_pc
                   AND p.atp_at = a.at_id
                   AND p.atp_sc = pc.pc_sc
                   AND sc.sc_id = a.at_sc;

        l_at       c_at%ROWTYPE;

        --l_Sci Uss_Person.v_Sc_Identity%ROWTYPE;
        --l_atp R_Person_for_act;
        l_FAtp     NUMBER;                                            --батько
        l_MAtp     NUMBER;                                              --мати
        l_str      VARCHAR2 (32000);
    BEGIN
        OPEN c_at;

        FETCH c_at INTO l_at;

        CLOSE c_at;

        --ПІБ особи, до якої прив’язане рішення
        --l_Sci:= get_pip(p_sc => l_at.pc_sc);
        --l_atp:= get_AtPerson(p_at => p_at_id, p_sc => l_at.pc_sc);

        rdm$rtfl_univ.initreport (p_code     => 'ACT_NEEDS_ASSESSMENT',
                                  p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);

        --1. Загальна інформація про членів сім’ї
        addparam ('f1', get_AtDocAtrStr (p_at_id, 1900));     --№ повідомлення
        addparam ('f2', get_AtDocAtrDt (p_at_id, 1901));
        addparam ('f3', get_AtDocAtrStr (p_at_id, 1902));        --Організація
        addparam ('f4', get_AtDocAtrRow (p_at_id, '1903,1904,1905')); --Фахівець, відповідальний за проведення
        addparam ('f5', l_at.at_action_start_dt);                    --Початок
        addparam ('f6', l_at.at_action_stop_dt);

        addparam ('f7', l_at.at_family_info); --Загальна інформація про членів сім’ї
        addparam ('f8', l_at.at_live_address);              --Місце проживання

        --члени родини
        rdm$rtfl_univ.AddDataset (
            'ds_fam',
               q'[select
             rownum "F09",
             pip "F9",
             birth_dt "F10",
             Relation_Tp "F11",
             is_disabled "F12",
             is_capable "F13",
             work_place "F14",
             case when is_adr_matching = 'T' then 'Так' end "F15",
             case when is_adr_matching = 'F' then 'Ні'  end "F16",
             phone "F17"
       from table(uss_esr.DNET$Act_Rpt.At_Person_for_act(]'
            || p_at_id
            || ')) t');

        --2. Стан та потреби дитини, ets
        rdm$rtfl_univ.AddDataset ('ds_child', ds_child (p_at_id));

        --3. Стан дорослих членів сім’ї
        l_FAtp := l_at.atp_id;   --батько           виключно для тестування!!!
        l_MAtp := l_at.atp_id;                                          --мати

        addparam ('F125', get_AtPerson (p_at_id, l_FAtp).pip);
        addparam ('F125-2', get_AtPerson (p_at_id, l_MAtp).pip);
        addparam ('F126', get_AtFtrChk (p_at_id, l_FAtp, 3269));
        addparam ('F126-2', get_AtFtrChk (p_at_id, l_MAtp, 3269));

        -- Має інвалідність: блок підкреслення
        BEGIN
            l_str :=
                   '3270з порушенням опорно-рухового апарату та центральної і периферичної нервової системи3270, 3271органів слуху3271, '
                || '3272органів зору3272, 3273внутрішніх органів3273, 3274з психічними захворюваннями та розумовою відсталістю3274, '
                || '3275з онкологічними захворюваннями3275';
            aInt :=
                TInt (3270,
                      3271,
                      3272,
                      3273,
                      3274,
                      3275);

            FOR i IN 1 .. aInt.COUNT
            LOOP
                IF    get_AtFtr (p_at_id, l_FAtp, aInt (i)) = 'T'
                   OR get_AtFtr (p_at_id, l_MAtp, aInt (i)) = 'T'
                THEN
                    l_str :=
                        REGEXP_REPLACE (l_str,
                                        aInt (i),
                                        '\ul',
                                        1,
                                        1);
                    l_str :=
                        REGEXP_REPLACE (l_str,
                                        aInt (i),
                                        '\ul0',
                                        1,
                                        1);
                ELSE
                    l_str := REPLACE (l_str, aInt (i));
                END IF;
            END LOOP;

            addparam ('F127', l_str);
            l_str := NULL;
        END;


        IF COALESCE (get_AtFtr (p_at_id, l_FAtp, 3270),
                     get_AtFtr (p_at_id, l_FAtp, 3271),
                     get_AtFtr (p_at_id, l_FAtp, 3272),
                     get_AtFtr (p_at_id, l_FAtp, 3273),
                     get_AtFtr (p_at_id, l_FAtp, 3274),
                     get_AtFtr (p_at_id, l_FAtp, 3274),
                     get_AtFtr (p_at_id, l_FAtp, 3275))
               IS NOT NULL
        THEN
            addparam ('F133', c_check);
        ELSE
            addparam ('F133', NULL);
        END IF;

        IF COALESCE (get_AtFtrChk (p_at_id, l_MAtp, 3270),
                     get_AtFtrChk (p_at_id, l_MAtp, 3271),
                     get_AtFtrChk (p_at_id, l_MAtp, 3272),
                     get_AtFtrChk (p_at_id, l_MAtp, 3273),
                     get_AtFtrChk (p_at_id, l_MAtp, 3274),
                     get_AtFtrChk (p_at_id, l_MAtp, 3274))
               IS NOT NULL
        THEN
            addparam ('F133-2', c_check);
        ELSE
            addparam ('F133-2', NULL);
        END IF;

        addparam ('F134', get_AtFtrChk (p_at_id, l_FAtp, 3276));
        addparam ('F134-2', get_AtFtrChk (p_at_id, l_MAtp, 3276));
        addparam ('F135', get_AtFtrChk (p_at_id, l_FAtp, 3277));
        addparam ('F135-2', get_AtFtrChk (p_at_id, l_MAtp, 3277));
        --інше
        addparam (
            'F136',
            mOthers (
                TVarchar2 (get_AtFtrNt (p_at_id, l_FAtp, 3277),
                           get_AtFtrNt (p_at_id, l_MAtp, 3277))));

        --Висновок щодо стану здоров’я
        --довідник: задовільний[STS]; незадовільний[N]; невідомо[F] select * from uss_ndi.v_ddn_ss_sts t
        addparam ('F137-1',
                  chk_val ('STS', get_AtFtr (p_at_id, l_FAtp, 3289)));
        addparam ('F137-2', chk_val ('N', get_AtFtr (p_at_id, l_FAtp, 3289)));
        addparam ('F137-3', chk_val ('F', get_AtFtr (p_at_id, l_FAtp, 3289)));
        addparam ('F137-21',
                  chk_val ('STS', get_AtFtr (p_at_id, l_MAtp, 3289)));
        addparam ('F137-22',
                  chk_val ('N', get_AtFtr (p_at_id, l_MAtp, 3289)));
        addparam ('F137-23',
                  chk_val ('F', get_AtFtr (p_at_id, l_MAtp, 3289)));
        --Коментарі
        addparam (
            'F138',
            mOthers (
                TVarchar2 (get_AtFtrNt (p_at_id, l_FAtp, 3288),
                           get_AtFtrNt (p_at_id, l_MAtp, 3288))));

        --2) емоційний стан
        addparam ('F139', get_AtFtrChk (p_at_id, l_FAtp, 3290));
        addparam ('F139-2', get_AtFtrChk (p_at_id, l_MAtp, 3290));
        addparam ('F140', get_AtFtrChk (p_at_id, l_FAtp, 3291));
        addparam ('F140-2', get_AtFtrChk (p_at_id, l_MAtp, 3291));
        addparam ('F141', get_AtFtrChk (p_at_id, l_FAtp, 3292));
        addparam ('F141-2', get_AtFtrChk (p_at_id, l_MAtp, 3292));
        addparam ('F142', get_AtFtrChk (p_at_id, l_FAtp, 3293));
        addparam ('F142-2', get_AtFtrChk (p_at_id, l_MAtp, 3293));
        addparam ('F143', get_AtFtrChk (p_at_id, l_FAtp, 3294));
        addparam ('F143-2', get_AtFtrChk (p_at_id, l_MAtp, 3294));
        addparam ('F144', get_AtFtrChk (p_at_id, l_FAtp, 3295));
        addparam ('F144-2', get_AtFtrChk (p_at_id, l_MAtp, 3295));
        addparam ('F145', get_AtFtrChk (p_at_id, l_FAtp, 3296));
        addparam ('F145-2', get_AtFtrChk (p_at_id, l_MAtp, 3296));
        addparam ('F146', get_AtFtrChk (p_at_id, l_FAtp, 3297));
        addparam ('F146-2', get_AtFtrChk (p_at_id, l_MAtp, 3297));
        addparam ('F147', get_AtFtrChk (p_at_id, l_FAtp, 3298));
        addparam ('F147-2', get_AtFtrChk (p_at_id, l_MAtp, 3298));
        addparam ('F148', get_AtFtrChk (p_at_id, l_FAtp, 3299));
        addparam ('F148-2', get_AtFtrChk (p_at_id, l_MAtp, 3299));
        --інше
        addparam (
            'F149',
            mOthers (
                TVarchar2 (get_AtFtrNt (p_at_id, l_FAtp, 3299),
                           get_AtFtrNt (p_at_id, l_MAtp, 3299))));
        --Висновок щодо емоційного стану
        addparam ('F150-1',
                  chk_val ('STS', get_AtFtr (p_at_id, l_FAtp, 3302)));
        addparam ('F150-2', chk_val ('N', get_AtFtr (p_at_id, l_FAtp, 3302)));
        addparam ('F150-3', chk_val ('F', get_AtFtr (p_at_id, l_FAtp, 3302)));
        addparam ('F150-21',
                  chk_val ('STS', get_AtFtr (p_at_id, l_MAtp, 3302)));
        addparam ('F150-22',
                  chk_val ('N', get_AtFtr (p_at_id, l_MAtp, 3302)));
        addparam ('F150-23',
                  chk_val ('F', get_AtFtr (p_at_id, l_MAtp, 3302)));
        --Коментарі
        addparam (
            'F151',
            mOthers (
                TVarchar2 (get_AtFtrNt (p_at_id, l_FAtp, 3301),
                           get_AtFtrNt (p_at_id, l_MAtp, 3301))));

        --3) шкідливі звички
        addparam ('F152', get_AtFtrChk (p_at_id, l_FAtp, 3303));
        addparam ('F152-2', get_AtFtrChk (p_at_id, l_MAtp, 3303));
        addparam ('F153', get_AtFtrChk (p_at_id, l_FAtp, 3304));
        addparam ('F153-2', get_AtFtrChk (p_at_id, l_MAtp, 3304));
        addparam ('F154', get_AtFtrChk (p_at_id, l_FAtp, 3305));
        addparam ('F154-2', get_AtFtrChk (p_at_id, l_MAtp, 3305));
        addparam ('F155', get_AtFtrChk (p_at_id, l_FAtp, 3306));
        addparam ('F155-2', get_AtFtrChk (p_at_id, l_MAtp, 3306));
        addparam ('F156', get_AtFtrChk (p_at_id, l_FAtp, 3307));
        addparam ('F156-2', get_AtFtrChk (p_at_id, l_MAtp, 3307));
        addparam ('F157', get_AtFtrChk (p_at_id, l_FAtp, 3308));
        addparam ('F157-2', get_AtFtrChk (p_at_id, l_MAtp, 3308));
        addparam ('F158', get_AtFtrChk (p_at_id, l_FAtp, 3309));
        addparam ('F158-2', get_AtFtrChk (p_at_id, l_MAtp, 3309));
        addparam ('F159', get_AtFtrChk (p_at_id, l_FAtp, 3310));
        addparam ('F159-2', get_AtFtrChk (p_at_id, l_MAtp, 3310));
        addparam ('F160', get_AtFtrChk (p_at_id, l_FAtp, 3311));
        addparam ('F160-2', get_AtFtrChk (p_at_id, l_MAtp, 3311));
        --інше
        addparam (
            'F161',
            mOthers (
                TVarchar2 (get_AtFtrNt (p_at_id, l_FAtp, 3311),
                           get_AtFtrNt (p_at_id, l_MAtp, 3311))));
        --Висновок щодо наявності ознак девіантної поведінки
        addparam ('F162-1',
                  chk_val ('STS', get_AtFtr (p_at_id, l_FAtp, 3315)));
        addparam ('F162-2', chk_val ('N', get_AtFtr (p_at_id, l_FAtp, 3315)));
        addparam ('F162-3', chk_val ('F', get_AtFtr (p_at_id, l_FAtp, 3315)));
        addparam ('F162-21',
                  chk_val ('STS', get_AtFtr (p_at_id, l_MAtp, 3315)));
        addparam ('F162-22',
                  chk_val ('N', get_AtFtr (p_at_id, l_MAtp, 3315)));
        addparam ('F162-23',
                  chk_val ('F', get_AtFtr (p_at_id, l_MAtp, 3315)));
        --Коментарі
        addparam (
            'F162',
            mOthers (
                TVarchar2 (get_AtFtrNt (p_at_id, l_FAtp, 3314),
                           get_AtFtrNt (p_at_id, l_MAtp, 3314))));

        --4) соціальні контакти
        addparam ('F164', get_AtFtrChk (p_at_id, l_FAtp, 3316));
        addparam ('F164-2', get_AtFtrChk (p_at_id, l_MAtp, 3316));
        addparam ('F165', get_AtFtrChk (p_at_id, l_FAtp, 3317));
        addparam ('F165-2', get_AtFtrChk (p_at_id, l_MAtp, 3317));
        addparam ('F166', get_AtFtrChk (p_at_id, l_FAtp, 3318));
        addparam ('F166-2', get_AtFtrChk (p_at_id, l_MAtp, 3318));
        addparam ('F167', get_AtFtrChk (p_at_id, l_FAtp, 3319));
        addparam ('F167-2', get_AtFtrChk (p_at_id, l_MAtp, 3319));
        addparam ('F168', get_AtFtrChk (p_at_id, l_FAtp, 3320));
        addparam ('F168-2', get_AtFtrChk (p_at_id, l_MAtp, 3320));
        addparam ('F169', get_AtFtrChk (p_at_id, l_FAtp, 3321));
        addparam ('F169-2', get_AtFtrChk (p_at_id, l_MAtp, 3321));
        addparam ('F170', get_AtFtrChk (p_at_id, l_FAtp, 3322));
        addparam ('F170-2', get_AtFtrChk (p_at_id, l_MAtp, 3322));
        addparam ('F171', get_AtFtrChk (p_at_id, l_FAtp, 3323));
        addparam ('F171-2', get_AtFtrChk (p_at_id, l_MAtp, 3323));
        addparam ('F172', get_AtFtrChk (p_at_id, l_FAtp, 3324));
        addparam ('F172-2', get_AtFtrChk (p_at_id, l_MAtp, 3324));
        addparam ('F173', get_AtFtrChk (p_at_id, l_FAtp, 3325));
        addparam ('F173-2', get_AtFtrChk (p_at_id, l_MAtp, 3325));
        addparam ('F174', get_AtFtrChk (p_at_id, l_FAtp, 3326));
        addparam ('F174-2', get_AtFtrChk (p_at_id, l_MAtp, 3326));
        addparam ('F175', get_AtFtrChk (p_at_id, l_FAtp, 3327));
        addparam ('F175-2', get_AtFtrChk (p_at_id, l_MAtp, 3327));
        addparam ('F176', get_AtFtrChk (p_at_id, l_FAtp, 3328));
        addparam ('F176-2', get_AtFtrChk (p_at_id, l_MAtp, 3328));
        --інше
        addparam (
            'F177',
            mOthers (
                TVarchar2 (get_AtFtrNt (p_at_id, l_FAtp, 3328),
                           get_AtFtrNt (p_at_id, l_MAtp, 3328))));
        addparam ('F178', get_AtFtrChk (p_at_id, l_FAtp, 3330));
        addparam ('F178-2', get_AtFtrChk (p_at_id, l_MAtp, 3330));
        addparam ('F179', get_AtFtrChk (p_at_id, l_FAtp, 3331));
        addparam ('F179-2', get_AtFtrChk (p_at_id, l_MAtp, 3331));
        --Висновок щодо впливу соціальної історії
        addparam ('F180-1',
                  chk_val ('STS', get_AtFtr (p_at_id, l_FAtp, 3333)));
        addparam ('F180-2', chk_val ('N', get_AtFtr (p_at_id, l_FAtp, 3333)));
        addparam ('F180-3', chk_val ('F', get_AtFtr (p_at_id, l_FAtp, 3333)));
        addparam ('F180-21',
                  chk_val ('STS', get_AtFtr (p_at_id, l_MAtp, 3333)));
        addparam ('F180-22',
                  chk_val ('N', get_AtFtr (p_at_id, l_MAtp, 3333)));
        addparam ('F180-23',
                  chk_val ('F', get_AtFtr (p_at_id, l_MAtp, 3333)));
        --Коментарі
        addparam (
            'F181',
            mOthers (
                TVarchar2 (get_AtFtrNt (p_at_id, l_FAtp, 3332),
                           get_AtFtrNt (p_at_id, l_MAtp, 3332))));

        --6) зайнятість
        addparam ('F182', get_AtFtrChk (p_at_id, l_FAtp, 3334));
        addparam ('F182-2', get_AtFtrChk (p_at_id, l_MAtp, 3334));
        addparam ('F183', get_AtFtrChk (p_at_id, l_FAtp, 3335));
        addparam ('F183-2', get_AtFtrChk (p_at_id, l_MAtp, 3335));
        addparam ('F184', get_AtFtrChk (p_at_id, l_FAtp, 3336));
        addparam ('F184-2', get_AtFtrChk (p_at_id, l_MAtp, 3336));
        addparam ('F185', get_AtFtrChk (p_at_id, l_FAtp, 3337));
        addparam ('F185-2', get_AtFtrChk (p_at_id, l_MAtp, 3337));
        addparam ('F186', get_AtFtrChk (p_at_id, l_FAtp, 3338));
        addparam ('F186-2', get_AtFtrChk (p_at_id, l_MAtp, 3338));
        addparam ('F187', get_AtFtrChk (p_at_id, l_FAtp, 3339));
        addparam ('F187-2', get_AtFtrChk (p_at_id, l_MAtp, 3339));
        addparam ('F188', get_AtFtrChk (p_at_id, l_FAtp, 3340));
        addparam ('F188-2', get_AtFtrChk (p_at_id, l_MAtp, 3340));
        addparam ('F189', get_AtFtrChk (p_at_id, l_FAtp, 3341));
        addparam ('F189-2', get_AtFtrChk (p_at_id, l_MAtp, 3341));
        addparam ('F190', get_AtFtrChk (p_at_id, l_FAtp, 3342));
        addparam ('F190-2', get_AtFtrChk (p_at_id, l_MAtp, 3342));
        addparam ('F191', get_AtFtrChk (p_at_id, l_FAtp, 3343));
        addparam ('F191-2', get_AtFtrChk (p_at_id, l_MAtp, 3343));
        addparam ('F192', get_AtFtrChk (p_at_id, l_FAtp, 3344));
        addparam ('F192-2', get_AtFtrChk (p_at_id, l_MAtp, 3344));
        --інше
        addparam (
            'F193',
            mOthers (
                TVarchar2 (get_AtFtrNt (p_at_id, l_FAtp, 3344),
                           get_AtFtrNt (p_at_id, l_MAtp, 3344))));
        --Висновок щодо впливу зайнятості
        addparam ('F194-1',
                  chk_val ('STS', get_AtFtr (p_at_id, l_FAtp, 3348)));
        addparam ('F194-2', chk_val ('N', get_AtFtr (p_at_id, l_FAtp, 3348)));
        addparam ('F194-3', chk_val ('F', get_AtFtr (p_at_id, l_FAtp, 3348)));
        addparam ('F194-21',
                  chk_val ('STS', get_AtFtr (p_at_id, l_MAtp, 3348)));
        addparam ('F194-22',
                  chk_val ('N', get_AtFtr (p_at_id, l_MAtp, 3348)));
        addparam ('F194-23',
                  chk_val ('F', get_AtFtr (p_at_id, l_MAtp, 3348)));
        --Коментарі
        addparam (
            'F195',
            mOthers (
                TVarchar2 (get_AtFtrNt (p_at_id, l_FAtp, 3346),
                           get_AtFtrNt (p_at_id, l_MAtp, 3346))));
        addparam (
            'F196',
            mOthers (
                TVarchar2 (get_AtFtrNt (p_at_id, l_FAtp, 3347),
                           get_AtFtrNt (p_at_id, l_MAtp, 3347))));

        --7) самообслуговування
        addparam ('F197', get_AtFtrChk (p_at_id, l_FAtp, 3349));
        addparam ('F197-2', get_AtFtrChk (p_at_id, l_MAtp, 3349));
        addparam ('F198', get_AtFtrChk (p_at_id, l_FAtp, 3350));
        addparam ('F198-2', get_AtFtrChk (p_at_id, l_MAtp, 3350));
        addparam ('F199', get_AtFtrChk (p_at_id, l_FAtp, 3351));
        addparam ('F199-2', get_AtFtrChk (p_at_id, l_MAtp, 3351));
        addparam ('F200', get_AtFtrChk (p_at_id, l_FAtp, 3352));
        addparam ('F200-2', get_AtFtrChk (p_at_id, l_MAtp, 3352));
        addparam ('F201', get_AtFtrChk (p_at_id, l_FAtp, 3353));
        addparam ('F201-2', get_AtFtrChk (p_at_id, l_MAtp, 3353));
        addparam ('F202', get_AtFtrChk (p_at_id, l_FAtp, 3354));
        addparam ('F202-2', get_AtFtrChk (p_at_id, l_MAtp, 3354));
        addparam ('F203', get_AtFtrChk (p_at_id, l_FAtp, 3355));
        addparam ('F203-2', get_AtFtrChk (p_at_id, l_MAtp, 3355));
        addparam ('F204', get_AtFtrChk (p_at_id, l_FAtp, 3356));
        addparam ('F204-2', get_AtFtrChk (p_at_id, l_MAtp, 3356));
        addparam ('F205', get_AtFtrChk (p_at_id, l_FAtp, 3357));
        addparam ('F205-2', get_AtFtrChk (p_at_id, l_MAtp, 3357));
        addparam ('F206', get_AtFtrChk (p_at_id, l_FAtp, 3358));
        addparam ('F206-2', get_AtFtrChk (p_at_id, l_MAtp, 3358));
        addparam ('F207', get_AtFtrChk (p_at_id, l_FAtp, 3359));
        addparam ('F207-2', get_AtFtrChk (p_at_id, l_MAtp, 3359));
        addparam ('F208', get_AtFtrChk (p_at_id, l_FAtp, 3360));
        addparam ('F208-2', get_AtFtrChk (p_at_id, l_MAtp, 3360));
        --Висновок щодо здатності до самообслуговування
        addparam ('F209-1',
                  chk_val ('STS', get_AtFtr (p_at_id, l_FAtp, 3361)));
        addparam ('F209-2', chk_val ('N', get_AtFtr (p_at_id, l_FAtp, 3361)));
        addparam ('F209-3', chk_val ('F', get_AtFtr (p_at_id, l_FAtp, 3361)));
        addparam ('F209-21',
                  chk_val ('STS', get_AtFtr (p_at_id, l_MAtp, 3361)));
        addparam ('F209-22',
                  chk_val ('N', get_AtFtr (p_at_id, l_MAtp, 3361)));
        addparam ('F209-23',
                  chk_val ('F', get_AtFtr (p_at_id, l_MAtp, 3361)));
        --Коментарі
        addparam (
            'F210',
            mOthers (
                TVarchar2 (get_AtFtrNt (p_at_id, l_FAtp, 3362),
                           get_AtFtrNt (p_at_id, l_MAtp, 3362))));

        --8) виконання батьківських обов’язків
        addparam ('F211', get_AtFtrChk (p_at_id, l_FAtp, 3363));
        addparam ('F211-2', get_AtFtrChk (p_at_id, l_MAtp, 3363));
        addparam ('F212', get_AtFtrChk (p_at_id, l_FAtp, 3364));
        addparam ('F212-2', get_AtFtrChk (p_at_id, l_MAtp, 3364));
        addparam ('F213', get_AtFtrChk (p_at_id, l_FAtp, 3365));
        addparam ('F213-2', get_AtFtrChk (p_at_id, l_MAtp, 3365));
        addparam ('F214', get_AtFtrChk (p_at_id, l_FAtp, 3366));
        addparam ('F214-2', get_AtFtrChk (p_at_id, l_MAtp, 3366));
        addparam ('F215', get_AtFtrChk (p_at_id, l_FAtp, 3367));
        addparam ('F215-2', get_AtFtrChk (p_at_id, l_MAtp, 3367));
        addparam ('F216', get_AtFtrChk (p_at_id, l_FAtp, 3368));
        addparam ('F216-2', get_AtFtrChk (p_at_id, l_MAtp, 3368));
        addparam ('F217', get_AtFtrChk (p_at_id, l_FAtp, 3369));
        addparam ('F217-2', get_AtFtrChk (p_at_id, l_MAtp, 3369));
        addparam ('F218', get_AtFtrChk (p_at_id, l_FAtp, 3370));
        addparam ('F218-2', get_AtFtrChk (p_at_id, l_MAtp, 3370));
        addparam ('F219', get_AtFtrChk (p_at_id, l_FAtp, 3371));
        addparam ('F219-2', get_AtFtrChk (p_at_id, l_MAtp, 3371));
        addparam ('F220', get_AtFtrChk (p_at_id, l_FAtp, 3372));
        addparam ('F220-2', get_AtFtrChk (p_at_id, l_MAtp, 3372));
        --Висновок щодо стану виконання батьком/ матір’ю батьківських обов’язків
        addparam ('F221-1',
                  chk_val ('STS', get_AtFtr (p_at_id, l_FAtp, 3374)));
        addparam ('F221-2', chk_val ('N', get_AtFtr (p_at_id, l_FAtp, 3374)));
        addparam ('F221-3', chk_val ('F', get_AtFtr (p_at_id, l_FAtp, 3374)));
        addparam ('F221-21',
                  chk_val ('STS', get_AtFtr (p_at_id, l_MAtp, 3374)));
        addparam ('F221-22',
                  chk_val ('N', get_AtFtr (p_at_id, l_MAtp, 3374)));
        addparam ('F221-23',
                  chk_val ('F', get_AtFtr (p_at_id, l_MAtp, 3374)));
        --Коментарі
        addparam (
            'F222',
            mOthers (
                TVarchar2 (get_AtFtrNt (p_at_id, l_FAtp, 3373),
                           get_AtFtrNt (p_at_id, l_MAtp, 3373))));

        --4. Фактори сім’ї та середовища
        --1) мережа соціального супроводу сім’ї
        addparam ('F223-1', chk_val ('N', get_AtFtr (p_at_id, p_nda => 3375)));
        addparam ('F223-2',
                  chk_val ('AVL', get_AtFtr (p_at_id, p_nda => 3375)));
        addparam ('F223-3', chk_val ('F', get_AtFtr (p_at_id, p_nda => 3375)));

        addparam ('F224', get_AtFtrChk (p_at_id, p_nda => 3376));
        addparam ('F225', get_AtFtrChk (p_at_id, p_nda => 3377));
        --Коментарі
        addparam ('F226',
                  mOthers (TVarchar2 (get_AtFtrNt (p_at_id, p_nda => 3377))));

        --2) соціальні стосунки сім’ї
        addparam ('F227-1', chk_val ('N', get_AtFtr (p_at_id, p_nda => 3379)));
        addparam ('F227-2',
                  chk_val ('AVL', get_AtFtr (p_at_id, p_nda => 3379)));
        addparam ('F227-3', chk_val ('F', get_AtFtr (p_at_id, p_nda => 3379)));

        addparam ('F228', get_AtFtrChk (p_at_id, p_nda => 3380));
        addparam ('F229', get_AtFtrChk (p_at_id, p_nda => 3381));
        addparam ('F230', get_AtFtrChk (p_at_id, p_nda => 3382));
        addparam ('F231', get_AtFtrChk (p_at_id, p_nda => 3383));
        addparam ('F232', get_AtFtrChk (p_at_id, p_nda => 3384));
        addparam ('F233', get_AtFtrChk (p_at_id, p_nda => 3385));
        addparam ('F234', get_AtFtrChk (p_at_id, p_nda => 3386));
        addparam ('F235', get_AtFtrChk (p_at_id, p_nda => 3387));
        addparam ('F236', get_AtFtrChk (p_at_id, p_nda => 3388));
        addparam ('F237', get_AtFtrChk (p_at_id, p_nda => 3389));
        addparam ('F238', get_AtFtrNt (p_at_id, p_nda => 3389));   --Коментарі

        --3) основні доходи сім’ї
        addparam ('F239-1', chk_val ('N', get_AtFtr (p_at_id, p_nda => 3391)));
        addparam ('F239-2',
                  chk_val ('AVL', get_AtFtr (p_at_id, p_nda => 3391)));
        addparam ('F239-3', chk_val ('F', get_AtFtr (p_at_id, p_nda => 3391)));

        addparam ('F240', get_AtFtrChk (p_at_id, p_nda => 3392));
        addparam ('F241', get_AtFtrChk (p_at_id, p_nda => 3393));
        addparam ('F242', get_AtFtrChk (p_at_id, p_nda => 3394));
        addparam ('F243', get_AtFtrChk (p_at_id, p_nda => 3395));
        addparam ('F244', get_AtFtrChk (p_at_id, p_nda => 3396));
        addparam ('F245', get_AtFtrChk (p_at_id, p_nda => 3397));
        addparam ('F246', get_AtFtrChk (p_at_id, p_nda => 3398));
        addparam ('F247', get_AtFtrChk (p_at_id, p_nda => 3399));
        addparam ('F248', get_AtFtrChk (p_at_id, p_nda => 3400));
        addparam ('F249', get_AtFtrChk (p_at_id, p_nda => 3401));
        addparam ('F250', get_AtFtrChk (p_at_id, p_nda => 3402));
        addparam ('F251', get_AtFtrNt (p_at_id, p_nda => 3402));   --Коментарі

        --4) борги
        addparam ('F252-1', chk_val ('N', get_AtFtr (p_at_id, p_nda => 3404)));
        addparam ('F252-2',
                  chk_val ('AVL', get_AtFtr (p_at_id, p_nda => 3404)));
        addparam ('F252-3', chk_val ('F', get_AtFtr (p_at_id, p_nda => 3404)));
        addparam ('F253', get_AtFtrChk (p_at_id, p_nda => 3405));
        addparam ('F254', get_AtFtrChk (p_at_id, p_nda => 3406));
        addparam ('F255', get_AtFtrChk (p_at_id, p_nda => 3407));
        addparam ('F256', get_AtFtrChk (p_at_id, p_nda => 3408));
        addparam ('F257', get_AtFtrNt (p_at_id, p_nda => 3408));   --Коментарі

        --5) члени сім’ї, інші особи, які проживають разом
        addparam ('F258-1', chk_val ('N', get_AtFtr (p_at_id, p_nda => 3410)));
        addparam ('F258-2',
                  chk_val ('AVL', get_AtFtr (p_at_id, p_nda => 3410)));
        addparam ('F258-3', chk_val ('F', get_AtFtr (p_at_id, p_nda => 3410)));
        addparam ('F259', get_AtFtrChk (p_at_id, p_nda => 3411));
        addparam ('F260', get_AtFtrChk (p_at_id, p_nda => 3412));
        addparam ('F261', get_AtFtrChk (p_at_id, p_nda => 3413));
        addparam ('F262', get_AtFtrChk (p_at_id, p_nda => 3414));
        addparam ('F263', get_AtFtrChk (p_at_id, p_nda => 3415));
        addparam ('F264', get_AtFtrNt (p_at_id, p_nda => 3415));   --Коментарі

        --6) помешкання та його стан
        addparam ('F265-1', chk_val ('N', get_AtFtr (p_at_id, p_nda => 3417)));
        addparam ('F265-2',
                  chk_val ('AVL', get_AtFtr (p_at_id, p_nda => 3417)));
        addparam ('F265-3', chk_val ('F', get_AtFtr (p_at_id, p_nda => 3417)));
        addparam ('F266', get_AtFtrChk (p_at_id, p_nda => 3418));
        addparam ('F267', get_AtFtrChk (p_at_id, p_nda => 3419));
        addparam ('F268', get_AtFtrChk (p_at_id, p_nda => 3420));
        addparam ('F269', get_AtFtrChk (p_at_id, p_nda => 3421));
        addparam ('F270', get_AtFtrChk (p_at_id, p_nda => 3422));
        addparam ('F271', get_AtFtrChk (p_at_id, p_nda => 3423));
        addparam ('F272', get_AtFtrChk (p_at_id, p_nda => 3424));
        addparam ('F273', get_AtFtrChk (p_at_id, p_nda => 3425));
        addparam ('F274', get_AtFtrChk (p_at_id, p_nda => 3426));
        addparam ('F275', get_AtFtrChk (p_at_id, p_nda => 3427));
        addparam ('F276', get_AtFtrChk (p_at_id, p_nda => 3428));
        addparam ('F277', get_AtFtrChk (p_at_id, p_nda => 3429));
        addparam ('F278', get_AtFtrChk (p_at_id, p_nda => 3430));
        addparam ('F279', get_AtFtrChk (p_at_id, p_nda => 3431));
        addparam ('F280', get_AtFtrChk (p_at_id, p_nda => 3432));
        addparam ('F281', get_AtFtrChk (p_at_id, p_nda => 3433));
        addparam ('F282', get_AtFtrNt (p_at_id, p_nda => 3433));   --Коментарі

        --5. Класифікація випадку
        addparam ('F283-1', (l_at.at_case_class));               --довідник???
        addparam ('F283-2', (l_at.at_case_class));
        addparam ('F283-3', (l_at.at_case_class));

        ----------------------------------------------------
        -- ВИСНОВОК
        ----------------------------------------------------
        addparam ('a1', l_at.sc_unique);
        addparam ('a2', l_at.at_live_address);
        --2.0 Наявність СЖО
        addparam ('a3-1', get_AtFtrChk (p_at_id, p_nda => 2040));
        addparam ('a3-2', get_AtFtrChk (p_at_id, p_nda => 2040));
        addparam ('a4', get_AtFtrNt (p_at_id, p_nda => 2041));
        --Наявність у дитини ознак психологічної травми
        addparam ('a5-1', get_AtFtrChk (p_at_id, p_nda => 2042));
        addparam ('a5-2', get_AtFtrChk (p_at_id, p_nda => 2042));

        SELECT LISTAGG (pip, ', ') WITHIN GROUP (ORDER BY 1)
          INTO l_str
          FROM TABLE (uss_esr.DNET$Act_Rpt.At_Person_for_act (p_at_id)) t
         WHERE MONTHS_BETWEEN (SYSDATE, t.birth_dt) / 12 < 18; --ознака дитини?

        addparam ('a6', l_str);

        --2.1.1 Вплив СЖО на стан задоволення потреб дитини (дітей)   uss_ndi.V_DDN_STSFCN_SGN
        addparam ('a7-1', chk_val ('SF', get_AtFtr (p_at_id, p_nda => 2043)));
        addparam ('a7-2', chk_val ('AVG', get_AtFtr (p_at_id, p_nda => 2043)));
        addparam ('a7-3', chk_val ('NSF', get_AtFtr (p_at_id, p_nda => 2043)));
        addparam ('a8', get_AtFtrNt (p_at_id, p_nda => 2043));
        --uss_ndi.V_DDN_SS_CAPABLE_1
        addparam ('a9-1', chk_val ('CPB', get_AtFtr (p_at_id, p_nda => 2045)));
        addparam ('a9-2', chk_val ('PRT', get_AtFtr (p_at_id, p_nda => 2045)));
        addparam ('a9-3', chk_val ('NOT', get_AtFtr (p_at_id, p_nda => 2045)));
        addparam ('a10', get_AtFtrNt (p_at_id, p_nda => 2045));
        --uss_ndi.V_DDN_ABILITY_SGN
        addparam ('a11-1', chk_val ('AB', get_AtFtr (p_at_id, p_nda => 2047)));
        addparam ('a11-2',
                  chk_val ('NAB', get_AtFtr (p_at_id, p_nda => 2047)));
        addparam ('a11-3', chk_val ('NS', get_AtFtr (p_at_id, p_nda => 2047)));
        addparam ('a12', get_AtFtrNt (p_at_id, p_nda => 2047));
        --3) вплив факторів сім’ї та середовища   uss_ndi.V_DDN_PS_NG_SGN
        addparam ('a13-1', chk_val ('NG', get_AtFtr (p_at_id, p_nda => 2049)));
        addparam ('a13-2', chk_val ('NU', get_AtFtr (p_at_id, p_nda => 2049)));
        addparam ('a13-3', chk_val ('PS', get_AtFtr (p_at_id, p_nda => 2049)));
        addparam ('a14', get_AtFtrNt (p_at_id, p_nda => 2049));
        --4) тривалість існування проблем uss_ndi.V_DDN_DURAT_SGN
        addparam ('a15-1',
                  chk_val ('SVY', get_AtFtr (p_at_id, p_nda => 2051)));
        addparam ('a15-2', chk_val ('MY', get_AtFtr (p_at_id, p_nda => 2051)));
        addparam ('a15-3',
                  chk_val ('U2Y', get_AtFtr (p_at_id, p_nda => 2051)));
        addparam ('a15-4',
                  chk_val ('U2M', get_AtFtr (p_at_id, p_nda => 2051)));
        addparam ('a15-5',
                  chk_val ('U2D', get_AtFtr (p_at_id, p_nda => 2051)));
        addparam ('aa16', get_AtFtrNt (p_at_id, p_nda => 2051));

        --5) усвідомлення наявності проблем та готовність до співпраці з надавачами послуг
        addparam ('a16', get_AtFtrChk (p_at_id, p_nda => 2052));
        addparam ('a17', get_AtFtrChk (p_at_id, p_nda => 2053));
        addparam ('a18', get_AtFtrNt (p_at_id, p_nda => 2054));
        addparam ('a19', get_AtFtrChk (p_at_id, p_nda => 2055));
        addparam ('a20', get_AtFtrChk (p_at_id, p_nda => 2056));
        addparam ('a21', get_AtFtrNt (p_at_id, p_nda => 2057));
        addparam ('a22', get_AtFtrChk (p_at_id, p_nda => 2058));
        addparam ('a23', get_AtFtrChk (p_at_id, p_nda => 2059));
        addparam ('a24', get_AtFtrNt (p_at_id, p_nda => 2060));

        --Сім’я/особа потребує надання соціальних послуг
        addparam ('a25-1', get_AtFtr (p_at_id, p_nda => NULL)); --нема атрибутів
        ----
        addparam ('a25-22', get_AtFtrNt (p_at_id, p_nda => NULL));

        --2.5.5 Завершення справи
        addparam ('a26', get_AtFtrChk (p_at_id, p_nda => 2062));
        addparam ('a27', get_AtFtrChk (p_at_id, p_nda => 2063));
        addparam ('a28', 'at_results.ATE_REDIRECT_RNSPM');
        addparam ('a29', get_AtFtrChk (p_at_id, p_nda => 2064));
        addparam ('a30', get_AtFtrNt (p_at_id, p_nda => 2064));

        --підписи

        --4. Фахівець, який здійснює оцінку потреб
        /*  addparam('a35',     nvl(get_AtFtrChk(p_at_id, p_nda => ), '____________________________')); --ПІБ
          addparam('a37',     nvl(get_AtFtrChk(p_at_id, p_nda => ), '__________________')); --телефон
        */
        --Інші спеціалісти, задіяні в оцінці потреб

        rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                         p_rpt_blob   => l_result);

        RETURN l_result;
    END;
END DNET$Act_Rpt;
/