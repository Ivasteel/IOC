/* Formatted on 8/12/2025 5:48:24 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.API$ACT_VALIDATION
IS
    -- Author  : SHOSTAK
    -- Created : 14.06.2023 3:18:58 PM
    -- Purpose :

    TYPE r_Message IS RECORD
    (
        Msg_Tp         VARCHAR2 (10),
        Msg_Tp_Name    VARCHAR2 (20),
        Msg_Text       VARCHAR2 (4000)
    );

    TYPE t_Messages IS TABLE OF r_Message;

    g_Messages   t_Messages;

    PROCEDURE Check_Is_Signed (p_At_Id          IN NUMBER,
                               p_At_St_New      IN VARCHAR2,
                               p_Raise_Errors   IN BOOLEAN);

    FUNCTION Validate_Apop
        RETURN BOOLEAN;

    FUNCTION Validate_Avop
        RETURN BOOLEAN;

    FUNCTION Validate_Ip
        RETURN BOOLEAN;

    FUNCTION Validate_Tctr
        RETURN BOOLEAN;

    FUNCTION Validate_Pwnp
        RETURN BOOLEAN;

    FUNCTION Validate_Ipnp
        RETURN BOOLEAN;

    FUNCTION Validate_Rstopss
        RETURN BOOLEAN;

    FUNCTION Validate_Ppnp
        RETURN BOOLEAN;

    FUNCTION Validate_Shdr
        RETURN BOOLEAN;

    FUNCTION Validate_Aprv
        RETURN BOOLEAN;

    FUNCTION Validate_Isnp
        RETURN BOOLEAN;

    FUNCTION Validate_Pao
        RETURN BOOLEAN;

    FUNCTION Validate_Orbd
        RETURN BOOLEAN;

    FUNCTION Validate_Anpoe
        RETURN BOOLEAN;

    FUNCTION Validate_Oks
        RETURN BOOLEAN;

    FUNCTION Validate_Ndis
        RETURN BOOLEAN;

    FUNCTION Validate_Anpk
        RETURN BOOLEAN;

    FUNCTION Validate_Zrsp
        RETURN BOOLEAN;

    FUNCTION Validate_Nrnp
        RETURN BOOLEAN;

    FUNCTION Validate_Act (p_At_Id       IN            NUMBER,
                           p_Messages       OUT NOCOPY t_Messages,
                           p_At_St_New   IN            VARCHAR2 DEFAULT NULL)
        RETURN BOOLEAN;

    FUNCTION Validate_Act (p_At_Id       IN     NUMBER,
                           p_Messages       OUT SYS_REFCURSOR,
                           p_At_St_New   IN     VARCHAR2 DEFAULT NULL)
        RETURN BOOLEAN;

    FUNCTION Validate_Act (p_At_Id IN NUMBER, p_Messages OUT VARCHAR2)
        RETURN BOOLEAN;
END Api$act_Validation;
/


/* Formatted on 8/12/2025 5:48:49 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.API$ACT_VALIDATION
IS
    g_At   Act%ROWTYPE;

    PROCEDURE Add_Message (p_Msg_Text      IN VARCHAR2,
                           p_Msg_Tp        IN VARCHAR2,
                           p_Msg_Tp_Name   IN VARCHAR2)
    IS
        l_Msg   r_Message;
    BEGIN
        l_Msg.Msg_Text := p_Msg_Text;
        l_Msg.Msg_Tp := p_Msg_Tp;
        l_Msg.Msg_Tp_Name := p_Msg_Tp_Name;
        g_Messages.EXTEND ();
        g_Messages (g_Messages.COUNT) := l_Msg;
    END;

    PROCEDURE Add_Warning (p_Msg_Text IN VARCHAR2)
    IS
    BEGIN
        Add_Message (p_Msg_Text, 'W', 'Попередження');
    END;

    PROCEDURE Add_Error (p_Msg_Text IN VARCHAR2)
    IS
    BEGIN
        Add_Message (p_Msg_Text, 'E', 'Помилка');
    END;

    /*PROCEDURE Add_Fatal(p_Msg_Text IN VARCHAR2) IS
    BEGIN
      IF g_Raise_Fatal_Err THEN
        Raise_Application_Error(-20000, p_Msg_Text);
      END IF;

      Add_Message(p_Msg_Text, 'F', 'Помилка');
    END;*/

    PROCEDURE Init (p_At_Id IN NUMBER)
    IS
    BEGIN
        g_Messages := t_Messages ();

        SELECT *
          INTO g_At
          FROM Act a
         WHERE a.At_Id = p_At_Id;
    END;

    FUNCTION Error_Exists
        RETURN BOOLEAN
    IS
        l_Result   NUMBER;
    BEGIN
        SELECT SIGN (COUNT (*))
          INTO l_Result
          FROM TABLE (g_Messages)
         WHERE Msg_Tp IN ('F', 'E');

        RETURN l_Result = 1;
    END;

    PROCEDURE Check_Signer_Rc
    IS
        l_Signer_Exists   NUMBER;
        l_is_hand         NUMBER;
    BEGIN
        SELECT SIGN (COUNT (*))
          INTO l_is_hand
          FROM at_document z
         WHERE     z.atd_at = g_At.At_Id
               AND z.atd_attach_src IN ('HAND')
               AND z.history_status = 'A';

        SELECT SIGN (COUNT (*))
          INTO l_Signer_Exists
          FROM At_Signers s
         WHERE     s.Ati_At = g_At.At_Id
               AND (       s.Ati_Is_Signed = 'F'
                       AND EXISTS
                               (SELECT *
                                  FROM at_document z
                                 WHERE     z.atd_at = s.ati_at
                                       AND z.atd_attach_src = 'AUTO'
                                       AND z.history_status = 'A')
                    OR EXISTS
                           (SELECT *
                              FROM at_document z
                             WHERE     z.atd_at = s.ati_at
                                   AND z.atd_attach_src IN ('TABLET')
                                   AND z.history_status = 'A'))
               AND s.History_Status = 'A'
               AND s.Ati_Tp = 'RC'
               AND (   s.Ati_Sc IS NOT NULL AND g_at.at_main_link IS NOT NULL
                    OR g_at.at_main_link IS NULL AND s.ati_atp IS NOT NULL);

        IF l_Signer_Exists <> 1 AND l_is_hand <> 1
        THEN
            Add_Error (
                'Не вказано жодного підписанта-отримувача соц. послуг');
        END IF;
    END;

    PROCEDURE Check_Signer_Pr
    IS
        l_Signer_Exists   NUMBER;
    BEGIN
        SELECT SIGN (COUNT (*))
          INTO l_Signer_Exists
          FROM At_Signers s
         WHERE     s.Ati_At = g_At.At_Id
               AND s.Ati_Is_Signed = 'F'
               AND s.History_Status = 'A'
               AND s.Ati_Tp = 'PR'
               AND s.Ati_Cu IS NOT NULL;

        IF l_Signer_Exists <> 1
        THEN
            Add_Error ('Не вказано підписанта керівника НСП');
        END IF;
    END;

    PROCEDURE Check_Signer_Sb
    IS
        l_Signer_Exists   NUMBER;
    BEGIN
        SELECT SIGN (COUNT (*))
          INTO l_Signer_Exists
          FROM At_Signers s
         WHERE     s.Ati_At = g_At.At_Id
               AND s.Ati_Is_Signed = 'F'
               AND s.History_Status = 'A'
               AND s.Ati_Tp = 'SB'
               AND s.Ati_Wu IS NOT NULL;

        IF l_Signer_Exists <> 1
        THEN
            Add_Error (
                'Не вказано підписанта керівника структурного підрозділу з питань соціального захисту');
        END IF;
    END;

    FUNCTION Check_Ndt_Exists (p_At_id IN NUMBER, p_Ndt_List IN VARCHAR2)
        RETURN BOOLEAN
    IS
        l_Atd_Exists   NUMBER;
    BEGIN
        SELECT SIGN (COUNT (*))
          INTO l_Atd_Exists
          FROM At_Document d
         WHERE     d.Atd_At = p_At_id
               AND d.Atd_Ndt IN
                       (SELECT TO_NUMBER (COLUMN_VALUE)
                          FROM XMLTABLE (p_Ndt_List))
               AND d.History_Status = 'A';

        RETURN l_Atd_Exists = 1;
    END;

    PROCEDURE Check_Signer_Pr (p_Ndt_Id IN NUMBER)
    IS
        l_Signer_Exists   NUMBER;
        l_Ndt_Name        VARCHAR2 (500);
    BEGIN
        SELECT SIGN (COUNT (*))
          INTO l_Signer_Exists
          FROM At_Signers  s
               JOIN At_Document d
                   ON s.Ati_Atd = d.Atd_Id AND d.Atd_Ndt = p_Ndt_Id
         WHERE     s.Ati_At = g_At.At_Id
               AND s.Ati_Is_Signed = 'F'
               AND s.History_Status = 'A'
               AND s.Ati_Tp = 'PR'
               AND s.Ati_Cu IS NOT NULL;

        IF l_Signer_Exists <> 1
        THEN
            SELECT t.Ndt_Name
              INTO l_Ndt_Name
              FROM Uss_Ndi.v_Ndi_Document_Type t
             WHERE t.Ndt_Id = p_Ndt_Id;

            Add_Error (
                   'Не вказано підписанта-користувачя НСП для документа '
                || l_Ndt_Name);
        END IF;
    END;

    PROCEDURE Check_Is_Signed (p_At_Id IN NUMBER, p_At_St_New IN VARCHAR2)
    IS
    BEGIN
        FOR Rec
            IN (  SELECT t.Ndt_Name_Short,
                         c.Nalc_Min_Signs,
                         Tt.Dic_Name     AS Ati_Tp_Name
                    FROM At_Document d
                         JOIN Act a ON d.Atd_At = a.At_Id
                         JOIN Uss_Ndi.v_Ndi_At_Lc_Config c
                             ON     d.Atd_Ndt = c.Nalc_Ndt
                                AND a.At_Tp = c.Nalc_At_Tp
                                AND a.At_St = c.Nalc_At_From_St
                                AND c.Nalc_At_To_St = p_At_St_New
                         JOIN Uss_Ndi.v_Ndi_Document_Type t
                             ON d.Atd_Ndt = t.Ndt_Id
                         JOIN Uss_Ndi.v_Ddn_Ati_Tp Tt
                             ON c.Nalc_User_Tp = Tt.Dic_Value
                         LEFT JOIN At_Signers s
                             ON     d.Atd_Id = s.Ati_Atd
                                AND s.History_Status = 'A'
                                AND s.Ati_Tp = c.Nalc_User_Tp
                                AND s.Ati_Is_Signed = 'T'
                   WHERE d.Atd_At = p_At_Id AND d.History_Status = 'A'
                GROUP BY t.Ndt_Name_Short, c.Nalc_Min_Signs, Tt.Dic_Name
                  HAVING COUNT (s.Ati_Id) < c.Nalc_Min_Signs)
        LOOP
            Add_Error (
                   'Не вистачає '
                || Rec.Nalc_Min_Signs
                || ' підпису(ів) '
                || LOWER (Rec.Ati_Tp_Name)
                || 'а для документа '
                || Rec.Ndt_Name_Short);
        END LOOP;
    END;

    PROCEDURE Check_Is_Signed (p_At_Id          IN NUMBER,
                               p_At_St_New      IN VARCHAR2,
                               p_Raise_Errors   IN BOOLEAN)
    IS
        l_Errors   VARCHAR2 (4000);
    BEGIN
        g_Messages := t_Messages ();
        Check_Is_Signed (p_At_Id, p_At_St_New);

        IF p_Raise_Errors
        THEN
            SELECT LISTAGG (Msg_Text,
                            CHR (13) || CHR (10)
                            ON OVERFLOW TRUNCATE '...')
                   WITHIN GROUP (ORDER BY 1)
              INTO l_Errors
              FROM TABLE (g_Messages)
             WHERE Msg_Tp = 'E';

            IF l_Errors IS NOT NULL
            THEN
                Raise_Application_Error (-20000, l_Errors);
            END IF;
        END IF;
    END;

    PROCEDURE Check_Print_Form
    IS
        l_Form_Exists   NUMBER;
    BEGIN
        SELECT SIGN (COUNT (*))
          INTO l_Form_Exists
          FROM At_Document  d
               JOIN Uss_Ndi.v_Ndi_At_Print_Config c
                   ON d.Atd_Ndt = c.Napc_Ndt AND c.Napc_At_Tp = g_At.At_Tp
               JOIN Uss_Ndi.v_Ndi_Document_Type Dt ON d.Atd_Ndt = Dt.Ndt_Id
         WHERE d.Atd_At = g_At.At_Id AND d.History_Status = 'A';

        IF l_Form_Exists <> 1
        THEN
            Add_Error ('Не сформовано друковану форму');
        END IF;
    END;

    PROCEDURE Check_Print_Form_By_Svc
    IS
        l_Ndt_Name   VARCHAR2 (500);
        l_Nst_Name   VARCHAR2 (1000);
        l_Ndt_Id     NUMBER;
    BEGIN
        SELECT MAX (Dt.Ndt_Name),
               MAX (Dt.ndt_id),
               MAX ( /*CASE
                        WHEN c.Napc_Nst <> s.Ats_Nst THEN
                         St.Nst_Name
                      END*/
                    CASE WHEN c.Napc_Nst IS NOT NULL THEN St.Nst_Name END)
          INTO l_Ndt_Name, l_Ndt_Id, l_Nst_Name
          FROM At_Document  d
               JOIN Uss_Ndi.v_Ndi_At_Print_Config c
                   ON d.Atd_Ndt = c.Napc_Ndt AND c.Napc_At_Tp = g_At.At_Tp
               JOIN At_Service s ON s.Ats_At = g_At.At_Id
               JOIN Uss_Ndi.v_Ndi_Document_Type Dt ON d.Atd_Ndt = Dt.Ndt_Id
               JOIN Uss_Ndi.v_Ndi_Service_Type St ON s.Ats_Nst = St.Nst_Id
         WHERE d.Atd_At = g_At.At_Id AND d.History_Status = 'A';

        IF l_Ndt_Name IS NULL
        THEN
            Add_Error ('Не сформовано друковану форму');
        END IF;

        -- 880, 890 для багатьох послуг визначено
        -- 20240223 bogdan: контроль вже не актуальний. так як 1 документ може бути на декілька послуг. наприклад, 857
        /*IF l_Nst_Name IS NOT NULL AND l_ndt_id NOT IN (880, 890) THEN
          Add_Error('Вказано тип друкованої форми "' || l_Ndt_Name || '", що не відповідає послузі "' || l_Nst_Name || '"');
        END IF;*/
        IF l_Nst_Name IS NULL
        THEN
            Add_Error (
                   'Вказаний тип друкованої форми "'
                || l_Ndt_Name
                || '" не підходить для вказаної послуги');
        END IF;
    END;

    PROCEDURE Check_Rnsp
    IS
    BEGIN
        IF g_At.At_Rnspm IS NULL
        THEN
            Add_Error ('Не вказано надавача соціальної послуги');
        END IF;
    END;

    PROCEDURE Check_Ap
    IS
    BEGIN
        IF g_At.At_Ap IS NULL
        THEN
            Add_Error ('Не вказано звернення');
        END IF;
    END;

    PROCEDURE Check_Nst
    IS
        l_cnt   NUMBER;
    BEGIN
        SELECT COUNT (*)
          INTO l_cnt
          FROM at_service t
         WHERE t.ats_at = g_at.at_id AND t.history_status = 'A';

        IF l_cnt = 0
        THEN
            Add_Error ('Необхідно вказати послугу!');
        END IF;
    END;

    PROCEDURE Check_Nst_Ss_Term
    IS
        l_cnt   NUMBER;
    BEGIN
        SELECT COUNT (*)
          INTO l_cnt
          FROM at_service t
         WHERE     t.ats_at = g_at.at_id
               AND t.history_status = 'A'
               AND t.ats_ss_term IS NULL;

        IF l_cnt > 0
        THEN
            Add_Error (
                'Необхідно вказати строк надання послуги: "одноразово" або "постійно/тимчасово"');
        END IF;
    END;

    -----------------------------------------------------------------
    --     Валідація проекту акту первинної оцінки потреб
    -----------------------------------------------------------------
    FUNCTION Validate_Apop
        RETURN BOOLEAN
    IS
    BEGIN
        Check_Signer_Rc;
        Check_Rnsp;
        Check_Ap;

        RETURN NOT Error_Exists;
    END;

    -----------------------------------------------------------------
    --     Валідація проекту акту повторної оцінки потреб
    -----------------------------------------------------------------
    FUNCTION Validate_Pao
        RETURN BOOLEAN
    IS
    BEGIN
        Check_Signer_Rc;
        Check_Rnsp;
        Check_Ap;

        RETURN NOT Error_Exists;
    END;

    -----------------------------------------------------------------
    --     Валідація проекту акту проведення оцінки рівня безпеки дитини
    -----------------------------------------------------------------
    FUNCTION Validate_Orbd
        RETURN BOOLEAN
    IS
    BEGIN
        Check_Signer_Rc;
        Check_Rnsp;
        Check_Ap;

        RETURN NOT Error_Exists;
    END;

    -----------------------------------------------------------------
    --     Валідація проекту акту вторинної оцінки потреб
    -----------------------------------------------------------------
    FUNCTION Validate_Avop
        RETURN BOOLEAN
    IS
        l_Ats_Cnt   NUMBER;
        l_Ats_Nst   NUMBER;
    BEGIN
        Check_Signer_Rc;
        Check_Rnsp;
        Check_Ap;

        SELECT MAX (s.Ats_Nst), COUNT (*)
          INTO l_Ats_Nst, l_Ats_Cnt
          FROM At_Service s
         WHERE s.Ats_At = g_At.At_Id AND s.History_Status = 'A';

        IF l_Ats_Cnt = 0
        THEN
            Add_Error ('Не вказано жодної послуги');
        END IF;

        IF l_Ats_Cnt > 1
        THEN
            Add_Error ('Вказано більше однієї послуги');
        END IF;

        IF l_Ats_Cnt = 1
        THEN
            IF l_Ats_Nst IS NULL
            THEN
                Add_Error ('Не вказано тип послуги');
            ELSE
                Check_Print_Form_By_Svc;
            END IF;
        END IF;

        RETURN NOT Error_Exists;
    END;

    -----------------------------------------------------------------
    --     Валідація проекту інд. плану надання соцпослуг
    -----------------------------------------------------------------
    FUNCTION Validate_Ip
        RETURN BOOLEAN
    IS
        l_Ats_Cnt       NUMBER;
        l_Ats_Nst       NUMBER;
        l_ats_ss_term   VARCHAR2 (10);
        l_is_main       NUMBER := cmes$act_ip.check_main_ip (g_At.At_Id);
        l_ss_cnt        NUMBER := cmes$act_ip.get_ss_cnt (g_At.At_Id);
    BEGIN
        Check_Signer_Rc;
        Check_Rnsp;
        Check_Ap;

        IF (l_is_main = 1 AND l_ss_cnt = 1)
        THEN
            SELECT MAX (s.Ats_Nst), COUNT (*), MAX (s.ats_ss_term)
              INTO l_Ats_Nst, l_Ats_Cnt, l_ats_ss_term
              FROM At_Service s
             WHERE s.Ats_At = g_At.At_Id AND s.History_Status = 'A';

            IF l_Ats_Cnt = 0
            THEN
                Add_Error ('Не вказано жодної послуги');
            END IF;

            IF l_Ats_Cnt > 1
            THEN
                Add_Error ('Вказано більше однієї послуги');
            END IF;

            IF (l_ats_ss_term IS NOT NULL AND l_ats_ss_term != 'P')
            THEN
                Add_Error (
                    'Для одноразової послуги не потрібно створювати ІП!');
            END IF;

            IF l_Ats_Cnt = 1
            THEN
                IF l_Ats_Nst IS NULL
                THEN
                    Add_Error ('Не вказано тип послуги');
                ELSE
                    Check_Print_Form_By_Svc;
                END IF;
            END IF;
        ELSE
            --todo: якісь валідації для об'єднаного акту
            NULL;
        END IF;

        RETURN NOT Error_Exists;
    END;

    -----------------------------------------------------------------
    --     Валідація проекту договору про надання соцпослуг
    -----------------------------------------------------------------
    FUNCTION Validate_Tctr
        RETURN BOOLEAN
    IS
    BEGIN
        Check_Signer_Rc;
        Check_Rnsp;
        Check_Ap;

        RETURN NOT Error_Exists;
    END;

    -----------------------------------------------------------------
    --Валідація проекту повідомлення про припинення надання соцпослуг
    -----------------------------------------------------------------
    FUNCTION Validate_Pwnp
        RETURN BOOLEAN
    IS
    BEGIN
        -- КМ не знає хто з надавача це буде підписувати. тож це буде заповнено в момент підпису надавачем
        -- Check_Signer_Pr;
        Check_Rnsp;
        Check_Print_Form;

        IF g_At.At_Main_Link IS NULL
        THEN
            Add_Error (
                'Не вказано договір про надання СП в рамках якого виконується попередження');
        END IF;

        IF g_At.At_Rnp IS NULL
        THEN
            Add_Error ('Не вказано причину припинення надання СП');
        END IF;

        IF g_At.At_Action_Stop_Dt IS NULL
        THEN
            Add_Error ('Не вказано дату припинення надання СП');
        END IF;

        RETURN NOT Error_Exists;
    END;

    -----------------------------------------------------------------
    --Валідація проекту інформації про припинення надання соцпослуг
    -----------------------------------------------------------------
    FUNCTION Validate_Ipnp
        RETURN BOOLEAN
    IS
    BEGIN
        -- КМ не знає хто з надавача це буде підписувати. тож це буде заповнено в момент підпису надавачем
        -- Check_Signer_Pr(864);
        -- Check_Signer_Pr(861);
        Check_Rnsp;
        Check_Print_Form;

        -- КМ може ініціювати зупинення надання послуги. в цьому випадку РСТОПСС створюється після підписання цього акту.
        /*IF g_At.At_Main_Link IS NULL THEN
          Add_Error('Не вказано договір про надання СП в рамках якого вноситься інформація');
        END IF;*/

        IF g_At.At_Rnp IS NULL
        THEN
            Add_Error ('Не вказано причину припинення надання СП');
        END IF;

        IF g_At.At_Action_Stop_Dt IS NULL
        THEN
            Add_Error ('Не вказано дату припинення надання СП');
        END IF;

        RETURN NOT Error_Exists;
    END;

    -----------------------------------------------------------------
    --Валідація проекту рішення про припинення надання соцпослуг
    -----------------------------------------------------------------
    FUNCTION Validate_Rstopss
        RETURN BOOLEAN
    IS
        l_Ap   APPEAL%ROWTYPE;
    BEGIN
        /*IF Api$appeal.Get_Ap_Doc_Str(g_At.At_Ap, 'DIRECTION') = 'G' THEN
          Check_Signer_Pr;
        ELSE
          Check_Signer_Sb;
        END IF;*/

        SELECT *
          INTO l_Ap
          FROM Appeal ap
         WHERE ap.ap_id = g_At.At_Ap;

        Check_Rnsp;
        Check_Print_Form;

        IF l_Ap.Ap_Tp NOT IN ('R.OS')
        THEN
            IF NOT Check_Ndt_Exists (g_At.At_Id, '860')
            THEN
                Add_Error (
                    'Не додано файл документу ''Рішення про припинення надання соціальних послуг''');
            END IF;
        END IF;

        IF g_At.At_Main_Link IS NULL
        THEN
            Add_Error (
                'Не вказано договір про надання СП в рамках якого вноситься інформація');
        END IF;

        IF g_At.At_Rnp IS NULL
        THEN
            Add_Error ('Не вказано причину припинення надання СП');
        END IF;

        IF l_Ap.Ap_Tp NOT IN ('R.OS')
        THEN
            IF g_At.At_Action_Stop_Dt IS NULL
            THEN
                Add_Error ('Не вказано дату припинення надання СП');
            END IF;
        END IF;

        RETURN NOT Error_Exists;
    END;

    -----------------------------------------------------------------
    --Валідація проекту повідомлення про припинення надання соцпослуг
    -----------------------------------------------------------------
    FUNCTION Validate_Ppnp
        RETURN BOOLEAN
    IS
    BEGIN
        /*IF Api$appeal.Get_Ap_Doc_Str(g_At.At_Ap, 'DIRECTION') = 'G' THEN
          Check_Signer_Pr;
        ELSE
          Check_Signer_Sb;
        END IF;*/

        Check_Rnsp;
        Check_Print_Form;

        IF NOT Check_Ndt_Exists (g_At.At_Id, '862')
        THEN
            Add_Error (
                'Не додано файл документу ''Повідомлення про припинення надання соціальних послуг''');
        END IF;

        IF g_At.At_Main_Link IS NULL
        THEN
            Add_Error (
                'Не вказано договір про надання СП в рамках якого вноситься інформація');
        END IF;

        IF g_At.At_Rnp IS NULL
        THEN
            Add_Error ('Не вказано причину припинення надання СП');
        END IF;

        IF g_At.At_Action_Stop_Dt IS NULL
        THEN
            Add_Error ('Не вказано дату припинення надання СП');
        END IF;

        RETURN NOT Error_Exists;
    END;

    FUNCTION Validate_Shdr
        RETURN BOOLEAN
    IS
    BEGIN
        Check_Print_Form;
        Check_Signer_Rc;
        Check_Rnsp;
        Check_Ap;

        RETURN NOT Error_Exists;
    END;

    FUNCTION Validate_Nrnp
        RETURN BOOLEAN
    IS
    BEGIN
        --Check_Print_Form;
        --Check_Signer_Rc;
        Check_Rnsp;
        Check_Ap;

        RETURN NOT Error_Exists;
    END;

    FUNCTION Validate_Aprv
        RETURN BOOLEAN
    IS
    BEGIN
        Check_Print_Form;
        Check_Signer_Rc;
        Check_Rnsp;
        Check_Ap;

        RETURN NOT Error_Exists;
    END;

    FUNCTION Validate_Isnp
        RETURN BOOLEAN
    IS
    BEGIN
        Check_Print_Form;
        Check_Rnsp;

        RETURN NOT Error_Exists;
    END;

    FUNCTION Validate_Anpoe
        RETURN BOOLEAN
    IS
        l_cnt   NUMBER;
    BEGIN
        Check_Print_Form;
        Check_Rnsp;
        Check_Nst;
        Check_Nst_Ss_Term;

        SELECT COUNT (*)
          INTO l_cnt
          FROM at_section_feature t
         WHERE     t.atef_at = g_at.at_id
               AND t.atef_nda IN (2031, 2032)
               AND t.atef_feature = 'T';

        -- #115441
        IF (l_cnt IS NULL OR l_cnt = 0 OR l_cnt > 1)
        THEN
            Add_Error (
                'Не визначено рекомендації щодо подальшої роботи з отримувачем соціальних послуг: необхідно встановити або "є потреба у подальшому наданні соціальних послуг", або "роботу з отримувачем соціальних послуг можна завершити"');
        END IF;

        RETURN NOT Error_Exists;
    END;

    FUNCTION Validate_Oks
        RETURN BOOLEAN
    IS
    BEGIN
        Check_Print_Form;
        Check_Rnsp;

        RETURN NOT Error_Exists;
    END;

    FUNCTION Validate_Ndis
        RETURN BOOLEAN
    IS
    BEGIN
        Check_Print_Form;
        Check_Rnsp;

        RETURN NOT Error_Exists;
    END;

    FUNCTION Validate_Anpk
        RETURN BOOLEAN
    IS
    BEGIN
        Check_Print_Form;
        Check_Rnsp;

        RETURN NOT Error_Exists;
    END;

    FUNCTION Validate_Zrsp
        RETURN BOOLEAN
    IS
    BEGIN
        Check_Signer_Rc;
        Check_Print_Form;
        Check_Rnsp;

        RETURN NOT Error_Exists;
    END;


    FUNCTION Validate_Act (p_At_Id       IN            NUMBER,
                           p_Messages       OUT NOCOPY t_Messages,
                           p_At_St_New   IN            VARCHAR2 DEFAULT NULL)
        RETURN BOOLEAN
    IS
        l_Result   BOOLEAN;
    BEGIN
        Init (p_At_Id);

        IF p_At_St_New IS NOT NULL
        THEN
            Check_Is_Signed (p_At_Id, p_At_St_New);
        END IF;

        EXECUTE IMMEDIATE   'BEGIN :result := Api$act_Validation.Validate_'
                         || g_At.At_Tp
                         || '; END;'
            USING OUT l_Result;

        p_Messages := g_Messages;

        RETURN l_Result;
    END;

    FUNCTION Validate_Act (p_At_Id       IN     NUMBER,
                           p_Messages       OUT SYS_REFCURSOR,
                           p_At_St_New   IN     VARCHAR2 DEFAULT NULL)
        RETURN BOOLEAN
    IS
        l_Result   BOOLEAN;
    BEGIN
        l_Result := Validate_Act (p_At_Id, g_Messages, p_At_St_New);

        OPEN p_Messages FOR   SELECT *
                                FROM TABLE (g_Messages) t
                            ORDER BY DECODE (t.Msg_Tp,  'F', 1,  'E', 1,  2);

        RETURN l_Result;
    END;

    FUNCTION Validate_Act (p_At_Id IN NUMBER, p_Messages OUT VARCHAR2)
        RETURN BOOLEAN
    IS
        l_Result   BOOLEAN;
    BEGIN
        l_Result := Validate_Act (p_At_Id, g_Messages, NULL);

        SELECT LISTAGG (Msg_Text, '; ')
          INTO p_Messages
          FROM (  SELECT t.Msg_Text
                    FROM TABLE (g_Messages) t
                ORDER BY DECODE (t.Msg_Tp,  'F', 1,  'E', 1,  2));


        RETURN l_Result;
    END;
END Api$act_Validation;
/