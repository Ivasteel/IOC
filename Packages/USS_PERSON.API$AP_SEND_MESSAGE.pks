/* Formatted on 8/12/2025 5:56:53 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_PERSON.API$AP_SEND_MESSAGE
IS
    -- Author  : SERHII
    -- Created : 18.08.2023
    -- Purpose : #89850 Підсистема інформування про призупинення виплат (частина для USS_PERSON)

    TYPE templ_rec_type IS RECORD
    (
        tt_title    uss_ndi.v_NDI_NT_TEMPLATE.ntt_title%TYPE,
        tt_text     uss_ndi.v_NDI_NT_TEMPLATE.ntt_text%TYPE
    );

    TYPE templ_table_type IS TABLE OF templ_rec_type
        INDEX BY PLS_INTEGER;

    FUNCTION get_templates (
        p_Tmpl_Type   IN uss_ndi.v_NDI_NT_TEMPLATE.ntt_info_tp%TYPE DEFAULT 'EMAIL')
        RETURN templ_table_type;

    PROCEDURE Batch_Notify_VPO (
        p_blck2inf   IN OUT uss_esr.api$ap_send_message.block_rec_tbl);
END API$AP_SEND_MESSAGE;
/


GRANT EXECUTE ON USS_PERSON.API$AP_SEND_MESSAGE TO II01RC_USS_PERSON_INT
/

GRANT EXECUTE ON USS_PERSON.API$AP_SEND_MESSAGE TO USS_ESR
/

GRANT EXECUTE ON USS_PERSON.API$AP_SEND_MESSAGE TO USS_RNSP
/

GRANT EXECUTE ON USS_PERSON.API$AP_SEND_MESSAGE TO USS_RPT
/

GRANT EXECUTE ON USS_PERSON.API$AP_SEND_MESSAGE TO USS_VISIT
/


/* Formatted on 8/12/2025 5:56:56 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_PERSON.API$AP_SEND_MESSAGE
IS
    TYPE tags_val_arr_type IS TABLE OF VARCHAR2 (1000)
        INDEX BY VARCHAR2 (100);

    -- всі шаблони
    c_templ_tbl   CONSTANT templ_table_type := get_templates ();
    g_debug_pipe           BOOLEAN := FALSE;                          --  true

    FUNCTION get_templates (
        p_Tmpl_Type   IN uss_ndi.v_NDI_NT_TEMPLATE.ntt_info_tp%TYPE DEFAULT 'EMAIL')
        RETURN templ_table_type
    IS
        l_tbl   templ_table_type;
    BEGIN
        FOR rec
            IN (SELECT ntt_ntg, ntt_title, ntt_text
                  FROM uss_ndi.v_NDI_NT_TEMPLATE_GROUP
                       JOIN uss_ndi.v_NDI_NT_TEMPLATE t ON ntg_id = ntt_ntg
                 WHERE ntg_is_blocked = 'N' AND ntt_info_tp = p_Tmpl_Type)
        LOOP
            l_tbl (rec.ntt_ntg).tt_title := rec.ntt_title;
            l_tbl (rec.ntt_ntg).tt_text := rec.ntt_text;
        END LOOP;

        RETURN (l_tbl);
    END get_templates;

    --Створюємо масив з ключами з імен тегів (змінних) темплейта
    FUNCTION GetTagsLst (p_Tmpl_Text IN VARCHAR2)
        RETURN tags_val_arr_type
    IS
        l_StartIndex   INTEGER := 1;
        l_EndIndex     INTEGER;
        l_Tag          VARCHAR2 (100);
        l_tags_lst     tags_val_arr_type;
    BEGIN
        l_tags_lst ('sc') := '';

        LOOP
            l_StartIndex := INSTR (p_Tmpl_Text, '#', l_StartIndex);
            EXIT WHEN l_StartIndex = 0;
            l_EndIndex := INSTR (p_Tmpl_Text, '#', l_StartIndex + 1);
            -- Виділяємо тег між початковим і кінцевим індексами
            l_Tag :=
                SUBSTR (p_Tmpl_Text,
                        l_StartIndex + 1,
                        l_EndIndex - l_StartIndex - 1);
            l_tags_lst (l_Tag) := '';
            -- Переміщуємо вказівник початку пошуку після кінцевого індексу
            l_StartIndex := l_EndIndex + 1;
        END LOOP;

        RETURN (l_tags_lst);
    END GetTagsLst;

    FUNCTION get_identity_data (p_tags_arr IN tags_val_arr_type)
        RETURN tags_val_arr_type
    IS
        l_Res   tags_val_arr_type := p_tags_arr;
        l_Tag   VARCHAR2 (100);
        l_fn    USS_PERSON.v_SC_IDENTITY.sci_fn%TYPE;
        l_mn    USS_PERSON.v_SC_IDENTITY.sci_fn%TYPE;
        l_ln    USS_PERSON.v_SC_IDENTITY.sci_fn%TYPE;
        l_gr    VARCHAR2 (50);
    BEGIN
        SELECT sci_fn,
               sci_mn,
               sci_ln,
               CASE sci_gender
                   WHEN 'M' THEN 'Шановний'
                   WHEN 'F' THEN 'Шановна'
                   ELSE 'Шановний/Шановна'
               END
          INTO l_fn,
               l_mn,
               l_ln,
               l_gr
          FROM uss_person.v_socialcard,
               uss_person.v_sc_change,
               uss_person.v_sc_contact,
               USS_PERSON.v_SC_IDENTITY
         WHERE     sc_id = p_tags_arr ('sc')
               AND scc_sc = sc_id
               AND sc_scc = scc_id
               AND scc_sct = sct_id
               AND scc_sci = SCI_id;

        l_Tag := l_Res.FIRST;

        WHILE l_Tag IS NOT NULL
        LOOP
            IF l_Tag = 'pib'
            THEN
                l_Res (l_Tag) := l_ln || ' ' || l_fn || ' ' || l_mn;
            ELSIF l_Tag = 'ib'
            THEN
                l_Res (l_Tag) := l_fn || ' ' || l_mn;
            ELSIF l_Tag = 'gr'
            THEN
                l_Res (l_Tag) := l_gr;
            END IF;

            l_Tag := l_Res.NEXT (l_Tag);
        END LOOP;

        RETURN (l_Res);
    END get_identity_data;

    FUNCTION get_serialized_tags_arr (p_tags_arr IN tags_val_arr_type)
        RETURN VARCHAR2
    IS
        l_Res   VARCHAR2 (4000) := '';
        l_Tag   VARCHAR2 (100);
    BEGIN
        l_Tag := p_tags_arr.FIRST;

        WHILE l_Tag IS NOT NULL
        LOOP
            l_Res :=
                l_Res || '#' || l_Tag || '=' || TO_CHAR (p_tags_arr (l_Tag));
            l_Tag := p_tags_arr.NEXT (l_Tag);
        END LOOP;

        RETURN (l_Res);
    END get_serialized_tags_arr;

    PROCEDURE Batch_Notify_VPO (
        p_blck2inf   IN OUT uss_esr.api$ap_send_message.block_rec_tbl)
    IS
        l_Tag                VARCHAR2 (100);
        l_Templ_Grp_Id       PLS_INTEGER;
        l_tags_arr           tags_val_arr_type;
        c_Src_Vst   CONSTANT VARCHAR2 (10) := '35'; -- ЄІССС: Єдиний соціальний процессінг
        l_Ntm_Id             NUMBER;
        l_Error              VARCHAR2 (4000);
        l_Title              VARCHAR2 (1000);
        l_Text               VARCHAR2 (4000);
    BEGIN
        FOR i IN p_blck2inf.FIRST .. p_blck2inf.LAST
        LOOP
            l_Templ_Grp_Id := p_blck2inf (i).atr_num;

            IF g_debug_pipe
            THEN
                ikis_sysweb.ikis_debug_pipe.WriteMsg (
                    'l_Templ_Grp_Id: ' || l_Templ_Grp_Id);
            END IF;

            IF l_Templ_Grp_Id IS NULL
            THEN
                p_blck2inf (i).res_txt :=
                       'Template is not found for data row: '
                    || 'Sc_Id'
                    || TO_CHAR (p_blck2inf (i).sc_id)
                    || 'atr_num'
                    || TO_CHAR (p_blck2inf (i).atr_num)
                    || 'art_str'
                    || TO_CHAR (p_blck2inf (i).art_str)
                    || 'atr_dt'
                    || TO_CHAR (p_blck2inf (i).atr_dt)
                    || 'src_prc'
                    || TO_CHAR (p_blck2inf (i).src_prc);
                CONTINUE;
            END IF;

            l_tags_arr := GetTagsLst (c_templ_tbl (l_Templ_Grp_Id).tt_text);

            IF g_debug_pipe
            THEN
                ikis_sysweb.ikis_debug_pipe.WriteMsg (
                    'l_Title: ' || c_templ_tbl (l_Templ_Grp_Id).tt_text);
            END IF;

            l_tags_arr ('sc') := p_blck2inf (i).sc_id;
            l_tags_arr := get_identity_data (l_tags_arr);
            l_Tag := l_tags_arr.FIRST;

            WHILE l_Tag IS NOT NULL
            LOOP
                IF l_Tag = 'ps'
                THEN
                    l_tags_arr (l_Tag) := p_blck2inf (i).art_str; -- p_blck2inf(i).src_cd = 'BLOCK'
                ELSIF l_Tag = 'sd'
                THEN
                    l_tags_arr (l_Tag) :=
                        TO_CHAR (p_blck2inf (i).atr_dt, 'DD.MM.YYYY');
                ELSIF l_Tag = 'pm'
                THEN
                    l_tags_arr (l_Tag) :=
                        TO_CHAR (p_blck2inf (i).atr_dt,
                                 'Month YYYY',
                                 'NLS_DATE_LANGUAGE = Ukrainian');
                ELSIF l_Tag = 'ed'
                THEN
                    l_tags_arr (l_Tag) :=
                        TO_CHAR (p_blck2inf (i).atr_dt, 'DD.MM.YYYY');
                END IF;

                l_Tag := l_tags_arr.NEXT (l_Tag);
            END LOOP;

            l_Title := CHR (38) || TO_CHAR (l_Templ_Grp_Id);
            l_Text :=
                   CHR (38)
                || TO_CHAR (l_Templ_Grp_Id)
                || get_serialized_tags_arr (l_tags_arr);

            IF g_debug_pipe
            THEN
                ikis_sysweb.ikis_debug_pipe.WriteMsg ('l_Text: ' || l_Text);
            END IF;

            uss_person.API$NT_API.SendOneByNumident (
                p_Numident   => NULL,
                p_Sc         => p_blck2inf (i).sc_id,
                p_Source     => c_Src_Vst,
                p_Type       => 'COM',               --dic_didi=2112: Звичайне
                p_Title      => l_Title,
                p_Text       => l_Text,
                p_Id         => l_Ntm_Id,
                p_Error      => l_Error);

            IF l_Ntm_Id IS NOT NULL
            THEN
                uss_person.API$NT_API.MakeSendTaskByParams (
                    p_Nip_Id     => NULL,
                    p_Start_Dt   => NULL,
                    p_Stop_Dt    => NULL,
                    p_Ntg_Id     => NULL,
                    p_Info_Tp    => 'EMAIL',
                    p_Source     => c_Src_Vst,
                    p_Tp         => 'COM',           --dic_didi=2112: Звичайне
                    p_Ntm        => l_Ntm_Id);
                p_blck2inf (i).res_txt := 'Success';
            ELSE
                p_blck2inf (i).res_txt := l_Error;
            END IF;

            IF g_debug_pipe
            THEN
                ikis_sysweb.ikis_debug_pipe.WriteMsg (
                    'p_blck2inf(i).res_txt: ' || p_blck2inf (i).res_txt);
            END IF;
        END LOOP;
    END Batch_Notify_VPO;
BEGIN
    NULL;
END API$AP_SEND_MESSAGE;
/