/* Formatted on 8/12/2025 5:48:26 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.CMES$ACT_RSTOPSS
IS
    -- Author  : SHOSTAK
    -- Created : 23.09.2023 3:49:17 PM
    -- Purpose : Рішення про припинення надання СП #91944

    Pkg                           VARCHAR2 (50) := 'CMES$ACT_RSTOPSS';

    c_Rstopss_Form_Ndt   CONSTANT NUMBER := 864;                 -- скан--860;

    FUNCTION Get_Direction (p_At_Id IN NUMBER)
        RETURN VARCHAR2;

    /*PROCEDURE Save_Act(p_Ipnp_Id            IN NUMBER,
                       p_At_Signers         IN CLOB,
                       p_At_Documents       IN CLOB DEFAULT NULL,
                       p_At_Attrs           IN CLOB DEFAULT NULL,
                       p_At_Id      OUT NUMBER);*/

    PROCEDURE Save_Act (p_At_Id          IN NUMBER,
                        p_At_Signers     IN CLOB,
                        p_At_Documents   IN CLOB DEFAULT NULL);

    FUNCTION Get_Agent_Pib (p_Ap_Id IN NUMBER)
        RETURN VARCHAR2;

    PROCEDURE Get_Acts_Cm (p_At_Dt_Start     IN     DATE,
                           p_At_Dt_Stop      IN     DATE,
                           p_At_Num          IN     VARCHAR2,
                           p_At_St           IN     VARCHAR2,
                           -- ПІБ отримувача соціальної послуги
                           p_Receiver_Pib    IN     VARCHAR2,
                           p_Cmes_Owner_Id   IN     NUMBER,
                           p_At_Main_Link    IN     NUMBER,
                           p_At_Pc           IN     NUMBER,
                           p_At_Ap           IN     NUMBER,
                           p_Acts               OUT SYS_REFCURSOR);

    PROCEDURE Get_Acts_By_Tctr (p_Tctr_Id         IN     NUMBER,
                                p_Cmes_Owner_Id   IN     NUMBER,
                                p_Acts               OUT SYS_REFCURSOR);

    PROCEDURE Get_Act_Card (p_At_Id          IN     NUMBER,
                            p_Act_Cur           OUT SYS_REFCURSOR,
                            p_Services_Cur      OUT SYS_REFCURSOR,
                            p_Signers_Cur       OUT SYS_REFCURSOR,
                            p_Docs              OUT SYS_REFCURSOR,
                            p_Docs_Attr         OUT SYS_REFCURSOR,
                            p_Docs_Files        OUT SYS_REFCURSOR);

    PROCEDURE Get_Act_Card (p_At_Id          IN     NUMBER,
                            p_Act_Cur           OUT SYS_REFCURSOR,
                            p_Services_Cur      OUT SYS_REFCURSOR,
                            p_Signers_Cur       OUT SYS_REFCURSOR,
                            p_Doc_Files         OUT SYS_REFCURSOR,
                            P_doc_Attrs         OUT SYS_REFCURSOR);

    PROCEDURE Get_Act_Card (p_At_Id          IN     NUMBER,
                            p_Act_Cur           OUT SYS_REFCURSOR,
                            p_Services_Cur      OUT SYS_REFCURSOR,
                            p_Signers_Cur       OUT SYS_REFCURSOR,
                            p_Docs_Files        OUT SYS_REFCURSOR);

    PROCEDURE Get_Form_File (p_At_Id       IN     NUMBER,
                             p_Atd_Dh         OUT NUMBER,
                             p_File_Code      OUT VARCHAR2);

    PROCEDURE Get_Form_File (p_At_Id                  IN     NUMBER,
                             p_Atd_Dh                    OUT NUMBER,
                             p_File_Code                 OUT VARCHAR2,
                             p_File_Signs_Code_List      OUT VARCHAR2);

    PROCEDURE Get_Form_File (p_At_Id IN NUMBER, p_Doc_Cur OUT SYS_REFCURSOR);

    PROCEDURE Get_Form_Doc (p_At_Id IN NUMBER, p_Doc OUT SYS_REFCURSOR);

    PROCEDURE Send_To_Pr (p_At_Id NUMBER, p_Messages OUT SYS_REFCURSOR);

    PROCEDURE Set_Signed_Cm (p_At_Id              NUMBER,
                             p_file_code   IN     VARCHAR2,
                             p_Messages       OUT SYS_REFCURSOR);

    PROCEDURE Set_Signed_Pr (p_At_Id          NUMBER,
                             p_file_code   IN VARCHAR2 DEFAULT NULL);

    PROCEDURE Set_Reject_Pr (p_At_Id          NUMBER,
                             p_file_code   IN VARCHAR2 DEFAULT NULL);

    PROCEDURE Set_Declined (p_At_Id IN NUMBER, p_Reason IN VARCHAR2);

    PROCEDURE Approve_Act_Action (p_at_id IN NUMBER);

    FUNCTION Check_File_Access (p_File_Code IN VARCHAR2, p_Cmes_Id IN NUMBER --Ignore
                                                                            )
        RETURN VARCHAR2;
END Cmes$act_Rstopss;
/


GRANT EXECUTE ON USS_ESR.CMES$ACT_RSTOPSS TO II01RC_USS_ESR_PORTAL
/

GRANT EXECUTE ON USS_ESR.CMES$ACT_RSTOPSS TO PORTAL_PROXY
/


/* Formatted on 8/12/2025 5:49:23 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.CMES$ACT_RSTOPSS
IS
    g_Nda_Map   Api$act.t_Nda_Map;

    PROCEDURE Write_Audit (p_Proc_Name IN VARCHAR2)
    IS
    BEGIN
        Tools.Writemsg (Pkg || '.' || p_Proc_Name);
    END;

    -----------------------------------------------------------
    --     ПЕРЕВІРКА ПРАВА ДОСТУПУ ДО АКТУ
    -----------------------------------------------------------
    PROCEDURE Check_Act_Access (p_At_Id IN NUMBER)
    IS
    BEGIN
        Cmes$act.Check_Act_Access (p_At_Id);
    END;

    -----------------------------------------------------------
    -- МАПІНГ ПОЛІВ АКТУ ЩО ЗБЕРІГАЮТЬСЯ В АТРИБУТИ ДОКУМЕНТА
    -----------------------------------------------------------
    PROCEDURE Map_Nda2act
    IS
    BEGIN
        IF g_Nda_Map.COUNT > 0
        THEN
            RETURN;
        END IF;

        g_Nda_Map (3093) := 'At_Spec_Position';
        g_Nda_Map (3094) := 'At_Spec_Nm';
        g_Nda_Map (3095) := 'At_Spec_Ln';

        g_Nda_Map (3096) := 'At_Head_Position';
        g_Nda_Map (3097) := 'At_Head_Nm';
        g_Nda_Map (3098) := 'At_Head_Ln';
    END;


    -----------------------------------------------------------
    --            ЗБЕРЕЖЕННЯ АКТУ
    -----------------------------------------------------------
    /*PROCEDURE Save_Act(p_Ipnp_Id            IN NUMBER,
                       p_At_Signers         IN CLOB,
                       p_At_Documents       IN CLOB DEFAULT NULL,
                       p_At_Attrs           IN CLOB DEFAULT NULL,
                       p_At_Id      OUT NUMBER) IS
      l_Cu_Id    NUMBER;
      l_At_Cu    NUMBER;
      l_Ap_Id    NUMBER;
      l_At_St    VARCHAR2(10);
      l_Signers    Api$act.t_At_Signers;
      l_Documents  Api$act.t_At_Documents;
      l_Atd_Id        NUMBER;
      l_Attrs         Api$act.t_At_Document_Attrs;
    BEGIN
      Write_Audit('Save_Act');
      l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;

      SELECT a.At_Ap, a.At_Cu, a.At_Main_Link
        INTO l_Ap_Id, l_At_Cu, p_At_Id
        FROM Act a
       WHERE a.At_Id = p_Ipnp_Id
         AND a.at_tp = 'IPNP';

      IF l_At_Cu IS NULL
         OR l_At_Cu <> Nvl(l_Cu_Id, -1) THEN
        Api$act.Raise_Unauthorized;
      END IF;

      IF l_Ap_Id IS NULL THEN
        Raise_Application_Error(-20000,
                                'Створення рішення про припинення можливо лише за наявності зетвердженої інформації про припинення та наказу');
      END IF;

      IF p_At_Id IS NULL THEN
        raise_application_error(-20000, 'Сепціаліст ОСЗН ще не створив рішення про припинення надання соціальних послуг');
        \*Api$act.Init_Act_By_Appeals(p_Mode => 3, p_Ap_Id => l_Ap_Id, p_Messages => l_Messages);
        SELECT a.At_Id, a.At_St
          INTO p_At_Id, l_At_St
          FROM Act a
         WHERE a.At_Ap = l_Ap_Id
           AND a.At_Tp = 'RSTOPSS'
           AND a.At_St IN ('RS.C');
        CLOSE l_Messages;

        UPDATE Act a
           SET a.At_Main_Link    = p_At_Id,
               a.At_Main_Link_Tp = 'RSTOPSS'
         WHERE a.At_Id = p_Ipnp_Id;*\

      ELSE
        l_At_St := Api$act.Get_At_St(p_At_Id);
        IF l_At_St NOT IN (\*'RR',*\ 'RS.C') THEN
          Raise_Application_Error(-20000,
                                  'Додавання підписантів в поточному стані не можливо');
        END IF;
      END IF;

      l_Signers := Api$act.Parse_Signers(p_At_Signers);
      l_Documents := Api$act.Parse_Documents(p_At_Documents);
      l_Attrs := Api$act.Parse_Attributes(p_At_Attrs);

      Api$act.Save_Signers(p_At_Id => p_At_Id, p_Signers => l_Signers);
      Api$act.Save_Documents(p_At_Id => p_At_Id, p_At_Documents => l_Documents);

      Map_Nda2act;
      l_Atd_Id := Api$act.Get_Form_Doc(p_At_Id => p_At_Id, p_Atd_Ndt => Api$act.Define_Print_Form_Ndt(p_At_Id));
      Api$act.Save_Attributes(p_At_Id => p_At_Id, p_Atd_Id => l_Atd_Id, p_Attrs => l_Attrs, p_Nda_Map => g_Nda_Map);

      Api$act.Write_At_Log(p_Atl_At      => p_At_Id,
                           p_Atl_Hs      => Tools.Gethistsessioncmes,
                           p_Atl_St      => l_At_St,
                           p_Atl_Message => Chr(38) || '226',
                           p_Atl_St_Old  => NULL);
    END;
  */

    PROCEDURE Save_Act (p_At_Id          IN NUMBER,
                        p_At_Signers     IN CLOB,
                        p_At_Documents   IN CLOB DEFAULT NULL)
    IS
        l_Cu_Id       NUMBER;
        l_At_Cu       NUMBER;
        l_Ap_Id       NUMBER;
        l_ap_tp       VARCHAR2 (10);
        l_At_St       VARCHAR2 (10);
        l_Signers     Api$act.t_At_Signers;
        l_Documents   Api$act.t_At_Documents;
        l_Atd_Id      NUMBER;
    --l_Attrs         Api$act.t_At_Document_Attrs;
    BEGIN
        Write_Audit ('Save_Act');
        l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;

        SELECT a.ap_tp
          INTO l_ap_tp
          FROM act t JOIN appeal a ON (ap_id = t.at_ap)
         WHERE t.at_id = p_At_Id;

        IF (l_ap_tp NOT IN ('R.OS'))
        THEN
            SELECT a.At_Ap, a.At_Cu
              INTO l_Ap_Id, l_At_Cu
              FROM at_links l JOIN Act a ON (a.at_id = l.atk_at)
             WHERE l.atk_link_at = p_At_Id AND a.at_tp = 'IPNP';

            IF l_At_Cu IS NULL OR l_At_Cu <> NVL (l_Cu_Id, -1)
            THEN
                Api$act.Raise_Unauthorized;
            END IF;

            IF l_Ap_Id IS NULL
            THEN
                Raise_Application_Error (
                    -20000,
                    'Створення рішення про припинення можливо лише за наявності зетвердженої інформації про припинення та наказу');
            END IF;
        END IF;

        IF p_At_Id IS NULL
        THEN
            raise_application_error (
                -20000,
                'Сепціаліст ОСЗН ще не створив рішення про припинення надання соціальних послуг');
        ELSE
            l_At_St := Api$act.Get_At_St (p_At_Id);

            IF l_At_St NOT IN (                                      /*'RR',*/
                               'RS.C')
            THEN
                Raise_Application_Error (
                    -20000,
                    'Додавання підписантів в поточному стані не можливо');
            END IF;
        END IF;

        l_Signers := Api$act.Parse_Signers (p_At_Signers);
        l_Documents := Api$act.Parse_Documents (p_At_Documents);
        --l_Attrs := Api$act.Parse_Attributes(p_At_Attrs);

        Api$act.Save_Signers (p_At_Id => p_At_Id, p_Signers => l_Signers);

        -- КМ редагує виключно 864 документ, тому щоб інші не правились виключаємо їх з колекції
        /*SELECT *
          bulk collect into l_Documents
          FROM table(l_Documents) t
         where t.atd_ndt = 864;*/

        Api$act.Save_Documents (p_At_Id          => p_At_Id,
                                p_At_Documents   => l_Documents);

        --Map_Nda2act;
        --l_Atd_Id := Api$act.Get_Form_Doc(p_At_Id => p_At_Id, p_Atd_Ndt => Api$act.Define_Print_Form_Ndt(p_At_Id));
        --Api$act.Save_Attributes(p_At_Id => p_At_Id, p_Atd_Id => l_Atd_Id, p_Attrs => l_Attrs, p_Nda_Map => g_Nda_Map);

        Api$act.Write_At_Log (p_Atl_At        => p_At_Id,
                              p_Atl_Hs        => Tools.Gethistsessioncmes,
                              p_Atl_St        => l_At_St,
                              p_Atl_Message   => CHR (38) || '226',
                              p_Atl_St_Old    => NULL);
    END;



    -----------------------------------------------------------
    --   ОТРИМАННЯ ПІБ законного представника / уповноваженої особи ОСП
    -----------------------------------------------------------
    FUNCTION Get_Agent_Pib (p_Ap_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (300);
    BEGIN
        SELECT MAX (Uss_Person.Api$sc_Tools.Get_Pib (p.App_Sc))
          INTO l_Result
          FROM Ap_Person p
         WHERE     p.App_Ap = p_Ap_Id
               AND p.App_Tp = 'Z'
               AND NOT EXISTS
                       (SELECT 1
                          FROM Ap_Person Pp
                         WHERE     Pp.App_Ap = p_Ap_Id
                               AND Pp.History_Status = 'A'
                               AND Pp.App_Tp = 'OS');

        RETURN l_Result;
    END;

    -----------------------------------------------------------
    --ОТРИМАННЯ ПЕРЕЛІКУ ПОВІДОМЛЕНЬ(ПОПЕРЕДНЬО ВІДФІЛЬТРОВАНИХ)
    -----------------------------------------------------------
    PROCEDURE Get_Act_List (p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT a.At_Id,
                   a.At_Org,
                   o.Org_Name
                       AS At_Org_Name,
                   --12. ПІБ законного представника / уповноваженої особи ОСП
                   Get_Agent_Pib (a.At_Ap)
                       AS At_Agent_Pib,
                   --Загальна інформація
                   --8. Номер
                   a.At_Num,
                   --9. Дата реєстрації
                   a.At_Dt,
                   a.at_ap,
                   --10. Джерело
                   a.At_Src,
                   Sr.Dic_Name
                       AS At_Src_Name,
                   --12. Статус
                   a.At_St,
                   s.Dic_Name
                       AS At_St_Name,
                   --Ким сформовано рішення про припинення надання соціальних послуг
                   --Посада
                   Api$act.Get_At_Spec_Position (a.At_Wu,
                                                 a.At_Cu,
                                                 a.At_Rnspm)
                       AS At_Spec_Position,
                   --15. Прізвище особи, яка сформувала --16. Ім’я особи, яка сформувала --17. По - батькові особи, яка сформувала
                   Api$act.Get_At_Spec_Name (a.At_Wu, a.At_Cu)
                       AS At_Spec_Name,
                   --13. Назва НСП
                   a.At_Rnspm,
                   Uss_Rnsp.Api$find.Get_Nsp_Name (a.At_Rnspm)
                       AS At_Rnsp_Name,
                   --Рішення про припинення надання соціальних послуг щодо кого
                   --18. Прізвище особи --19. Ім’я особи  --20. По-батькові особи
                   a.At_Sc,
                   Uss_Person.Api$sc_Tools.Get_Pib (a.At_Sc)
                       AS At_Sc_Pib,
                   --Підписант (керівник) рішення
                   --26. Посада підписанта
                   COALESCE (Api$act.Get_Signer_Position (a.At_Id, 'PR'),
                             Api$act.Get_Signer_Position (a.At_Id, 'SB'))
                       AS At_Approver_Position,
                   --27. Прізвище підписанта --28. Ім’я підписанта --29. По-батькові підписанта
                   COALESCE (Api$act.Get_Signer_Pib (a.At_Id, 'PR'),
                             Api$act.Get_Signer_Pib (a.At_Id, 'SB'))
                       AS At_Approver_Pib,
                   --ІД договору
                   Tt.At_Id
                       AS At_Tctr,
                   --9. Номер договору
                   Tt.At_Num
                       AS At_Tctr_Num,
                   --10. Дата договору
                   Tt.At_Dt
                       AS At_Tctr_Dt,
                   --Дата припинення надання СП
                   a.At_Action_Stop_Dt
                       AS At_Terminate_Dt,
                   --Причина припинення надання СП
                   NVL (a.At_Rnp,
                        (SELECT MAX (z.atda_val_string)
                           FROM at_document_attr z
                          WHERE z.atda_at = a.at_id AND z.atda_nda = 3092))
                       AS At_Rnp,
                   NVL (
                       r.Rnp_Name,
                       (SELECT MAX (zr.rnp_name)
                          FROM at_document_attr  z
                               LEFT JOIN Uss_Ndi.v_Ndi_Reason_Not_Pay zr
                                   ON (zr.rnp_id = z.atda_val_string)
                         WHERE z.atda_at = a.at_id AND z.atda_nda = 3092))
                       AS At_Rnp_Name,
                   ipnp.at_id
                       AS at_ipnp,
                   -- Тип обробки рішення: SB - ОСЗН, G - Надавач
                   Get_Direction (a.at_id)
                       AS Act_Process_Src,
                   -- № повідомлення
                    (SELECT MAX (d.atd_id)
                       FROM at_document d
                      WHERE     d.atd_at = a.at_id
                            AND d.atd_ndt = 862
                            AND d.history_status = 'A')
                       AS act_ppnp_num,
                   -- Дата повідомлення
                    (SELECT MIN (s.ati_sign_dt)
                       FROM at_document  d
                            JOIN at_signers s ON (s.ati_atd = d.atd_id)
                      WHERE     d.atd_at = a.at_id
                            AND d.atd_ndt = 862
                            AND s.history_status = 'A'
                            AND s.ati_is_signed = 'T'
                            AND d.history_status = 'A')
                       AS act_ppnp_dt,
                   -- Номер розпорядчого документу
                   api$act.Get_By_Ap_Attr_Val_Str (p_ap_id    => a.at_ap,
                                                   p_Nda_Id   => 4289)
                       AS act_num_r,
                   -- Дата розпорядчого документу
                   api$act.Get_By_Ap_Attr_Val_Dt (p_ap_id    => a.at_ap,
                                                  p_Nda_Id   => 4290)
                       AS act_dt_r
              FROM Tmp_Work_Ids  t
                   JOIN Act a ON t.x_Id = a.At_Id
                   JOIN Uss_Ndi.v_Ddn_At_Rstopss_St s
                       ON a.At_St = s.Dic_Value
                   JOIN Uss_Ndi.v_Ddn_Ap_Src Sr ON a.At_Src = Sr.Dic_Value
                   LEFT JOIN Uss_Ndi.v_Ndi_Reason_Not_Pay r
                       ON a.At_Rnp = r.Rnp_Id
                   LEFT JOIN Ikis_Sys.v_Opfu o ON a.At_Org = o.Org_Id
                   LEFT JOIN At_Links l
                       ON a.At_Id = l.Atk_At AND l.Atk_Tp = 'TCTR'
                   LEFT JOIN Act Tt ON l.Atk_Link_At = Tt.At_Id
                   LEFT JOIN Act ipnp
                       ON     ipnp.at_main_link = a.at_id
                          AND ipnp.at_main_link_tp = 'RSTOPSS'
                          AND ipnp.at_st NOT IN ('ND', 'NR')
                          AND ipnp.at_tp = 'IPNP';
    END;

    -----------------------------------------------------------
    --     ОТРИМАННЯ ПЕРЕЛІКУ РІШЕНЬ ДЛЯ КМа
    -----------------------------------------------------------
    PROCEDURE Get_Acts_Cm (p_At_Dt_Start     IN     DATE,
                           p_At_Dt_Stop      IN     DATE,
                           p_At_Num          IN     VARCHAR2,
                           p_At_St           IN     VARCHAR2,
                           -- ПІБ отримувача соціальної послуги
                           p_Receiver_Pib    IN     VARCHAR2,
                           p_Cmes_Owner_Id   IN     NUMBER,
                           p_At_Main_Link    IN     NUMBER,
                           p_At_Pc           IN     NUMBER,
                           p_At_Ap           IN     NUMBER,
                           p_Acts               OUT SYS_REFCURSOR)
    IS
        l_Cu_Id   NUMBER;
    BEGIN
        Write_Audit ('Get_Acts_Cm');
        l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;

        DELETE FROM Tmp_Work_Ids;

        IF     p_Cmes_Owner_Id IS NOT NULL
           AND Ikis_Rbm.Api$cmes_Auth.Is_Role_Assigned (
                   p_Cmes_Id         => Ikis_Rbm.Api$cmes_Auth.c_Cmes_Ss_Provider,
                   p_Cmes_Owner_Id   => p_Cmes_Owner_Id,
                   p_Cr_Code         => 'NSP_CM')
        THEN
            INSERT INTO Tmp_Work_Ids (x_Id)
                SELECT a.At_Id
                  FROM Act a
                 WHERE     a.At_Rnspm = p_Cmes_Owner_Id
                       AND a.At_Tp = 'RSTOPSS'
                       AND a.At_Cu = l_Cu_Id
                       --Додаткові фільтри
                       AND a.At_Dt BETWEEN NVL (p_At_Dt_Start, a.At_Dt)
                                       AND NVL (p_At_Dt_Stop, a.At_Dt)
                       --За постановкою ЖХ видаєо тільки договора що укладені обома сторонами
                       -- AND a.At_St NOT IN ('DN', 'DD', 'DR', 'DV', 'DS')
                       AND a.At_St NOT IN (                          /*'RR',*/
                                           'RS.S', 'RS.B')
                       AND (p_At_St IS NULL OR a.At_St = p_At_St)
                       AND (p_At_Num IS NULL OR a.At_Num LIKE p_At_Num || '%')
                       AND (   p_At_Main_Link IS NULL
                            OR a.At_Main_Link = p_At_Main_Link)
                       AND (p_At_Pc IS NULL OR a.At_Pc = p_At_Pc)
                       AND (p_At_Ap IS NULL OR a.At_Ap = p_At_Ap)
                       --ПІБ отримувача соціальної послуги
                       AND (   p_Receiver_Pib IS NULL
                            OR EXISTS
                                   (SELECT 1
                                      FROM Uss_Person.v_Sc_Info i
                                     WHERE     i.Sco_Id = a.At_Sc
                                           AND UPPER (
                                                      i.Sco_Ln
                                                   || ' '
                                                   || i.Sco_Fn
                                                   || ' '
                                                   || i.Sco_Ln) LIKE
                                                      UPPER (p_Receiver_Pib)
                                                   || '%'));
        END IF;

        Get_Act_List (p_Acts);
    END;

    -----------------------------------------------------------
    --     ОТРИМАННЯ ПЕРЕЛІКУ РІШЕНЬ ЗА ДОГОВОРОМ
    -----------------------------------------------------------
    PROCEDURE Get_Acts_By_Tctr (p_Tctr_Id         IN     NUMBER,
                                p_Cmes_Owner_Id   IN     NUMBER,
                                p_Acts               OUT SYS_REFCURSOR)
    IS
        l_Sc_Id   NUMBER;
    BEGIN
        Write_Audit ('Get_Acts_By_Tctr');

        DELETE FROM Tmp_Work_Ids;

        IF     p_Cmes_Owner_Id IS NOT NULL
           AND (   Ikis_Rbm.Api$cmes_Auth.Is_Role_Assigned (
                       p_Cmes_Id         =>
                           Ikis_Rbm.Api$cmes_Auth.c_Cmes_Ss_Provider,
                       p_Cmes_Owner_Id   => p_Cmes_Owner_Id,
                       p_Cr_Code         => 'NSP_SPEC')
                OR Ikis_Rbm.Api$cmes_Auth.Is_Role_Assigned (
                       p_Cmes_Id         =>
                           Ikis_Rbm.Api$cmes_Auth.c_Cmes_Ss_Provider,
                       p_Cmes_Owner_Id   => p_Cmes_Owner_Id,
                       p_Cr_Code         => 'NSP_CM'))
        THEN
            INSERT INTO Tmp_Work_Ids (x_Id)
                SELECT DISTINCT a.At_Id
                  FROM At_Links  l
                       JOIN Act a
                           ON     l.Atk_At = a.At_Id
                              AND a.At_Tp = 'RSTOPSS'
                              AND a.At_Rnspm = p_Cmes_Owner_Id
                 WHERE l.Atk_Link_At = p_Tctr_Id AND l.Atk_Tp = 'TCTR';
        ELSE
            l_Sc_Id := Ikis_Rbm.Tools.Getcusc (Ikis_Rbm.Tools.Getcurrentcu);

            INSERT INTO Tmp_Work_Ids (x_Id)
                SELECT DISTINCT a.At_Id
                  FROM At_Links  l
                       JOIN Act a
                           ON l.Atk_At = a.At_Id AND a.At_Tp = 'RSTOPSS'
                 WHERE     l.Atk_Link_At = p_Tctr_Id
                       AND l.Atk_Tp = 'TCTR'
                       AND (   a.At_Sc = l_Sc_Id
                            OR EXISTS
                                   (SELECT 1
                                      FROM At_Person p
                                     WHERE     p.Atp_At = a.At_Id
                                           AND p.Atp_Sc = l_Sc_Id
                                           AND p.History_Status = 'A'
                                           AND p.Atp_App_Tp IN ('Z')));
        END IF;

        Get_Act_List (p_Acts);
    END;

    -----------------------------------------------------------
    --          ОТРИМАННЯ ОСНОВНИХ ДАНИХ ПОВІДОМЛЕННЯ
    -----------------------------------------------------------
    PROCEDURE Get_Act (p_At_Id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        Map_Nda2act;

        OPEN p_Res FOR
            SELECT a.At_Id,
                   a.At_Org,
                   o.Org_Name
                       AS At_Org_Name,
                   --12. ПІБ законного представника / уповноваженої особи ОСП
                   Get_Agent_Pib (a.At_Ap)
                       AS At_Agent_Pib,
                   a.At_Ap,
                   --Загальна інформація
                   --8. Номер
                   a.At_Num,
                   --9. Дата реєстрації
                   a.At_Dt,
                   --10. Джерело
                   a.At_Src,
                   Sr.Dic_Name
                       AS At_Src_Name,
                   --12. Статус
                   a.At_St,
                   s.Dic_Name
                       AS At_St_Name,
                   --Ким сформовано рішення про припинення надання соціальних послуг
                   --Посада
                   Api$act.Get_At_Spec_Position (a.At_Wu,
                                                 a.At_Cu,
                                                 a.At_Rnspm)
                       AS At_Spec_Position,
                   --15. Прізвище особи, яка сформувала --16. Ім’я особи, яка сформувала --17. По - батькові особи, яка сформувала
                   Api$act.Get_At_Spec_Name (a.At_Wu, a.At_Cu)
                       AS At_Spec_Name,
                   --13. Назва НСП
                   a.At_Rnspm,
                   Uss_Rnsp.Api$find.Get_Nsp_Name (a.At_Rnspm)
                       AS At_Rnsp_Name,
                   --Рішення про припинення надання соціальних послуг щодо кого
                   --18. Прізвище особи --19. Ім’я особи  --20. По-батькові особи
                   a.At_Sc,
                   Uss_Person.Api$sc_Tools.Get_Pib (a.At_Sc)
                       AS At_Sc_Pib,
                   --Підписант (керівник) рішення
                   --26. Посада підписанта
                   COALESCE (Api$act.Get_Signer_Position (a.At_Id, 'PR'),
                             Api$act.Get_Signer_Position (a.At_Id, 'SB'))
                       AS At_Approver_Position,
                   --27. Прізвище підписанта --28. Ім’я підписанта --29. По-батькові підписанта
                   COALESCE (Api$act.Get_Signer_Pib (a.At_Id, 'PR'),
                             Api$act.Get_Signer_Pib (a.At_Id, 'SB'))
                       AS At_Approver_Pib,
                   --ІД договору
                   Tt.At_Id
                       AS At_Tctr,
                   --9. Номер договору
                   Tt.At_Num
                       AS At_Tctr_Num,
                   --10. Дата договору
                   Tt.At_Dt
                       AS At_Tctr_Dt,
                   --Дата припинення надання СП
                   a.At_Action_Stop_Dt
                       AS At_Terminate_Dt,
                   --Причина припинення надання СП
                   NVL (a.At_Rnp,
                        (SELECT MAX (z.atda_val_string)
                           FROM at_document_attr z
                          WHERE z.atda_at = a.at_id AND z.atda_nda = 3092))
                       AS At_Rnp,
                   NVL (
                       r.Rnp_Name,
                       (SELECT MAX (zr.rnp_name)
                          FROM at_document_attr  z
                               LEFT JOIN Uss_Ndi.v_Ndi_Reason_Not_Pay zr
                                   ON (zr.rnp_id = z.atda_val_string)
                         WHERE z.atda_at = a.at_id AND z.atda_nda = 3092))
                       AS At_Rnp_Name,
                   ipnp.at_id
                       AS at_ipnp,
                   Api$act.Get_Attr_Val_Field (p_At_Id,
                                               'At_Spec_Position',
                                               g_Nda_Map)
                       At_Spec_Position_Attr,
                   Api$act.Get_Attr_Val_Field (p_At_Id,
                                               'At_Spec_Nm',
                                               g_Nda_Map)
                       At_Spec_Nm,
                   Api$act.Get_Attr_Val_Field (p_At_Id,
                                               'At_Spec_Ln',
                                               g_Nda_Map)
                       At_Spec_Ln,
                   Api$act.Get_Attr_Val_Field (p_At_Id,
                                               'At_Head_Position',
                                               g_Nda_Map)
                       At_Head_Position,
                   Api$act.Get_Attr_Val_Field (p_At_Id,
                                               'At_Head_Nm',
                                               g_Nda_Map)
                       At_Head_Nm,
                   Api$act.Get_Attr_Val_Field (p_At_Id,
                                               'At_Head_Ln',
                                               g_Nda_Map)
                       At_Head_Ln,
                   Cmes$act.Get_Decline_Reason (a.at_id)
                       AS decline_reason,
                   -- Номер розпорядчого документу
                   api$act.Get_By_Ap_Attr_Val_Str (p_ap_id    => a.at_ap,
                                                   p_Nda_Id   => 4289)
                       AS act_num_r,
                   -- Дата розпорядчого документу
                   api$act.Get_By_Ap_Attr_Val_Dt (p_ap_id    => a.at_ap,
                                                  p_Nda_Id   => 4290)
                       AS act_dt_r
              FROM Act  a
                   LEFT JOIN Uss_Ndi.v_Ddn_At_Rstopss_St s
                       ON a.At_St = s.Dic_Value
                   LEFT JOIN Uss_Ndi.v_Ddn_Ap_Src Sr
                       ON a.At_Src = Sr.Dic_Value
                   LEFT JOIN Uss_Ndi.v_Ndi_Reason_Not_Pay r
                       ON a.At_Rnp = r.Rnp_Id
                   LEFT JOIN Ikis_Sys.v_Opfu o ON a.At_Org = o.Org_Id
                   LEFT JOIN At_Links l
                       ON a.At_Id = l.Atk_At AND l.Atk_Tp = 'TCTR'
                   LEFT JOIN Act Tt ON l.Atk_Link_At = Tt.At_Id
                   LEFT JOIN Act ipnp
                       ON     ipnp.at_main_link = a.at_id
                          AND ipnp.at_main_link_tp = 'RSTOPSS'
                          AND ipnp.at_st NOT IN ('ND', 'NR')
                          AND ipnp.at_tp = 'IPNP'
             WHERE a.At_Id = p_At_Id;
    END;

    --------------------------------------------------------------
    --           ОТРИМАННЯ ПОСЛУГ
    --------------------------------------------------------------
    PROCEDURE Get_Services (p_At_Id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT s.*, t.Nst_Name AS Ats_Nst_Name
              --todo: уточнити щодо статусу
              FROM At_Service  s
                   JOIN Uss_Ndi.v_Ndi_Service_Type t ON s.Ats_Nst = t.Nst_Id
             WHERE s.Ats_At = p_At_Id;
    END;

    PROCEDURE Get_Documents (p_At_Id       IN     NUMBER,
                             p_hide_docs   IN     NUMBER,
                             p_Res            OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT d.*,
                   t.Ndt_Name_Short                                 AS Atd_Ndt_Name,
                   api$act.Doc_Exists_Sign (d.atd_at, d.atd_ndt)    AS Doc_Exists_Sign
              FROM At_Document  d
                   JOIN Uss_Ndi.v_Ndi_Document_Type t ON d.Atd_Ndt = t.Ndt_Id
             WHERE     d.Atd_At = p_At_Id
                   AND d.History_Status = 'A'
                   AND (   p_hide_docs IS NULL
                        OR     p_hide_docs IS NOT NULL
                           AND t.ndt_id NOT IN (860, 862));
    END;

    PROCEDURE Get_Doc_Files (p_At_Id              NUMBER,
                             p_hide_docs   IN     NUMBER,
                             p_Res            OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT *
              FROM (SELECT d.Atd_Id,
                           d.Atd_Doc                          AS Doc_Id,
                           d.Atd_Dh                           AS Dh_Id,
                           f.File_Code,
                           f.File_Name,
                           f.File_Mime_Type,
                           f.File_Size,
                           f.File_Hash,
                           f.File_Create_Dt,
                           f.File_Description,
                           s.File_Code                        AS File_Sign_Code,
                           s.File_Hash                        AS File_Sign_Hash,
                           (SELECT LISTAGG (Fs.File_Code, ',')
                                   WITHIN GROUP (ORDER BY
                                                     Ss.Dats_Id)
                              FROM Uss_Doc.v_Doc_Attach_Signs  Ss
                                   JOIN Uss_Doc.v_Files Fs
                                       ON Ss.Dats_Sign_File =
                                          Fs.File_Id
                             WHERE Ss.Dats_Dat = a.Dat_Id)    AS File_Signs,
                           a.Dat_Num
                      FROM At_Document  d
                           JOIN Uss_Doc.v_Doc_Attachments a
                               ON d.Atd_Dh = a.Dat_Dh
                           JOIN Uss_Doc.v_Files f ON a.Dat_File = f.File_Id
                           LEFT JOIN Uss_Doc.v_Files s
                               ON a.Dat_Sign_File = s.File_Id
                     WHERE     d.Atd_At = p_At_Id
                           AND d.History_Status = 'A'
                           AND (   p_hide_docs IS NULL
                                OR     p_hide_docs IS NOT NULL
                                   AND d.atd_ndt NOT IN (860, 862)));
    END;

    FUNCTION has_nrp_400 (p_at_id IN NUMBER)
        RETURN NUMBER
    IS
        l_rnp   NUMBER;
    BEGIN
        SELECT NVL (t.at_rnp, api$act_rpt.AtDocAtrId (p_at_id, 3076))
          INTO l_rnp
          FROM act t
         WHERE t.at_id = p_at_id;

        RETURN CASE WHEN l_rnp = 400 THEN 1 ELSE 0 END;
    END;

    -----------------------------------------------------------
    --     ОТРИМАННЯ ДАНИХ ПОВІДОМЛЕННЯ. Для USS.Api
    -----------------------------------------------------------
    PROCEDURE Get_Act_Card (p_At_Id          IN     NUMBER,
                            p_Act_Cur           OUT SYS_REFCURSOR,
                            p_Services_Cur      OUT SYS_REFCURSOR,
                            p_Signers_Cur       OUT SYS_REFCURSOR,
                            p_Docs              OUT SYS_REFCURSOR,
                            p_Docs_Attr         OUT SYS_REFCURSOR,
                            p_Docs_Files        OUT SYS_REFCURSOR)
    IS
        l_Sc_Id         NUMBER
                            := Ikis_Rbm.Tools.Getcusc (Ikis_Rbm.Tools.Getcurrentcu);
        l_has_npr_400   NUMBER := has_nrp_400 (p_At_Id);
    BEGIN
        Write_Audit ('Get_Act_Card');
        Check_Act_Access (p_At_Id);

        Api$Act.Check_At_Tp (p_At_Id, 'RSTOPSS');

        Get_Act (p_At_Id, p_Act_Cur);
        Get_Services (p_At_Id, p_Services_Cur);
        Api$act.Get_Signers (p_At_Id, p_Signers_Cur);
        -- #110817
        Get_Documents (
            p_At_Id,
            CASE WHEN l_Sc_Id IS NOT NULL AND l_has_npr_400 = 1 THEN 1 END,
            p_Docs);
        Get_Doc_Files (
            p_At_Id,
            CASE WHEN l_Sc_Id IS NOT NULL AND l_has_npr_400 = 1 THEN 1 END,
            p_Docs_Files);
        Api$act.Get_Doc_Attributes (p_At_Id, p_Docs_Attr);
    END;

    -----------------------------------------------------------
    --     ОТРИМАННЯ ДАНИХ ПОВІДОМЛЕННЯ. Для USS.Portal
    -----------------------------------------------------------
    PROCEDURE Get_Act_Card (p_At_Id          IN     NUMBER,
                            p_Act_Cur           OUT SYS_REFCURSOR,
                            p_Services_Cur      OUT SYS_REFCURSOR,
                            p_Signers_Cur       OUT SYS_REFCURSOR,
                            p_Docs_Files        OUT SYS_REFCURSOR)
    IS
        l_Sc_Id         NUMBER
                            := Ikis_Rbm.Tools.Getcusc (Ikis_Rbm.Tools.Getcurrentcu);
        l_has_npr_400   NUMBER := has_nrp_400 (p_At_Id);
    BEGIN
        Write_Audit ('Get_Act_Card');
        Check_Act_Access (p_At_Id);

        Api$Act.Check_At_Tp (p_At_Id, 'RSTOPSS');

        Get_Act (p_At_Id, p_Act_Cur);
        Get_Services (p_At_Id, p_Services_Cur);
        Api$act.Get_Signers (p_At_Id, p_Signers_Cur);
        -- #110817
        Get_Doc_Files (
            p_At_Id,
            CASE WHEN l_Sc_Id IS NOT NULL AND l_has_npr_400 = 1 THEN 1 END,
            p_Docs_Files);
    END;

    PROCEDURE Get_Signed_Doc_Files (p_At_Id              NUMBER,
                                    p_hide_docs   IN     NUMBER,
                                    p_Res            OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT *
              FROM (SELECT d.Atd_Id,
                           atd_ndt,
                           d.Atd_Doc                                       AS Doc_Id,
                           d.Atd_Dh                                        AS Dh_Id,
                           f.File_Code,
                           f.File_Name,
                           f.File_Mime_Type,
                           f.File_Size,
                           f.File_Hash,
                           f.File_Create_Dt,
                           f.File_Description,
                           s.File_Code                                     AS File_Sign_Code,
                           s.File_Hash                                     AS File_Sign_Hash,
                           (SELECT LISTAGG (Fs.File_Code, ',')
                                   WITHIN GROUP (ORDER BY
                                                     Ss.Dats_Id)
                              FROM Uss_Doc.v_Doc_Attach_Signs  Ss
                                   JOIN Uss_Doc.v_Files Fs
                                       ON Ss.Dats_Sign_File =
                                          Fs.File_Id
                             WHERE Ss.Dats_Dat = a.Dat_Id)                 AS File_Signs,
                           a.Dat_Num,
                           MAX (a.dat_num) OVER (PARTITION BY d.atd_id)    max_dat_num
                      FROM At_Document  d
                           JOIN Uss_Doc.v_Doc_Attachments a
                               ON d.Atd_Dh = a.Dat_Dh
                           JOIN Uss_Doc.v_Files f ON a.Dat_File = f.File_Id
                           LEFT JOIN Uss_Doc.v_Files s
                               ON a.Dat_Sign_File = s.File_Id
                     WHERE     d.Atd_At = p_At_Id
                           --AND d.atd_ndt in (862,864)
                           AND d.History_Status = 'A'
                           AND (   p_hide_docs IS NULL
                                OR     p_hide_docs IS NOT NULL
                                   AND d.atd_ndt NOT IN (860, 862))
                           --#92377
                           AND EXISTS
                                   (SELECT 1
                                      FROM At_Signers Sg
                                     WHERE     Sg.Ati_Atd = d.Atd_Id
                                           AND Sg.History_Status = 'A'
                                           AND Sg.Ati_Is_Signed = 'T')
                           AND NOT EXISTS
                                   (SELECT 1
                                      FROM At_Signers Sg
                                     WHERE     Sg.Ati_Atd = d.Atd_Id
                                           AND Sg.History_Status = 'A'
                                           AND NVL (Sg.Ati_Is_Signed, 'F') =
                                               'F'))
             --#93366
             WHERE        atd_ndt IN (860, 862)
                      AND (   File_Signs IS NOT NULL
                           OR File_Sign_Code IS NOT NULL)
                      AND dat_num = max_dat_num
                   OR atd_ndt NOT IN (860, 862);
    END;

    PROCEDURE Get_Doc_Attributes (p_At_Id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT a.*, n.Nda_Name AS Atda_Nda_Name
              FROM At_Document  d
                   JOIN At_Document_Attr a
                       ON d.Atd_Id = a.Atda_Atd AND a.History_Status = 'A'
                   JOIN Uss_Ndi.v_Ndi_Document_Attr n
                       ON a.Atda_Nda = n.Nda_Id
             WHERE     d.Atd_At = p_At_Id
                   AND d.atd_ndt = 862
                   AND d.History_Status = 'A';
    END;

    -----------------------------------------------------------
    --     ОТРИМАННЯ ДАНИХ ПОВІДОМЛЕННЯ 862. Для USS.Portal
    -----------------------------------------------------------
    PROCEDURE Get_Act_Card (p_At_Id          IN     NUMBER,
                            p_Act_Cur           OUT SYS_REFCURSOR,
                            p_Services_Cur      OUT SYS_REFCURSOR,
                            p_Signers_Cur       OUT SYS_REFCURSOR,
                            p_Doc_Files         OUT SYS_REFCURSOR,
                            P_doc_Attrs         OUT SYS_REFCURSOR)
    IS
        l_Sc_Id         NUMBER
                            := Ikis_Rbm.Tools.Getcusc (Ikis_Rbm.Tools.Getcurrentcu);
        l_has_npr_400   NUMBER := has_nrp_400 (p_At_Id);
    BEGIN
        Write_Audit ('Get_Act_Card');
        Check_Act_Access (p_At_Id);

        Api$Act.Check_At_Tp (p_At_Id, 'RSTOPSS');

        Get_Act (p_At_Id, p_Act_Cur);
        Get_Services (p_At_Id, p_Services_Cur);
        Api$act.Get_Signers (p_At_Id, p_Signers_Cur);
        --Get_Signed_Doc_Files(p_At_Id, p_Doc_Files);
        -- #110817
        Get_Signed_Doc_Files (
            p_At_Id,
            CASE WHEN l_Sc_Id IS NOT NULL AND l_has_npr_400 = 1 THEN 1 END,
            p_Doc_Files);
        Get_Doc_Attributes (p_At_Id, p_Doc_Attrs);
    END;

    -----------------------------------------------------------
    --            ОТРИМАННЯ ДРУКОВАНОЇ ФОРМИ АКТУ
    --               (вже побудованої)
    -----------------------------------------------------------
    PROCEDURE Get_Form_File (p_At_Id       IN     NUMBER,
                             p_Atd_Dh         OUT NUMBER,
                             p_File_Code      OUT VARCHAR2)
    IS
    BEGIN
        Write_Audit ('Get_Form_File');
        Check_Act_Access (p_At_Id);

        Api$act.Get_Form_File (
            p_At_Id       => p_At_Id,
            p_Form_Ndt    => Api$act.Define_Print_Form_Ndt (p_At_Id),
            p_Atd_Dh      => p_Atd_Dh,
            p_File_Code   => p_File_Code);
    END;

    ---------------------------------------------------------------
    --             ОТРИМАННЯ ДРУКОВАНОЇ ФОРМИ АКТУ
    --      (вже побудованої, з кодами підписів через кому)
    ---------------------------------------------------------------
    PROCEDURE Get_Form_File (p_At_Id                  IN     NUMBER,
                             p_Atd_Dh                    OUT NUMBER,
                             p_File_Code                 OUT VARCHAR2,
                             p_File_Signs_Code_List      OUT VARCHAR2)
    IS
    BEGIN
        Write_Audit ('Get_Form_File');
        Check_Act_Access (p_At_Id);

        Api$act.Get_Form_File (
            p_At_Id                  => p_At_Id,
            p_Form_Ndt               => Api$act.Define_Print_Form_Ndt (p_At_Id),
            p_Atd_Dh                 => p_Atd_Dh,
            p_File_Code              => p_File_Code,
            p_File_Signs_Code_List   => p_File_Signs_Code_List);
    END;

    -----------------------------------------------------------
    --     ОТРИМАННЯ ДРУКОВАНОЇ ФОРМИ АКТУ
    -----------------------------------------------------------
    PROCEDURE Get_Form_File (p_At_Id IN NUMBER, p_Doc_Cur OUT SYS_REFCURSOR)
    IS
        l_Cu_Id          NUMBER;
        l_At_St          VARCHAR2 (10);
        l_Atd_Id         NUMBER;
        l_Doc_Id         NUMBER;
        l_Dh_Id          NUMBER;
        l_File_Code      VARCHAR2 (50);
        l_File_Hash      VARCHAR2 (50);
        l_File_Content   BLOB;
        l_Form_Ndt       NUMBER;
        l_Build_Proc     VARCHAR2 (200);
    BEGIN
        Write_Audit ('Get_Form_File');
        Check_Act_Access (p_At_Id);

        l_Form_Ndt := Api$act.Define_Print_Form_Ndt (p_At_Id, l_Build_Proc);

        Api$act.Get_Form_Doc (p_At_Id     => p_At_Id,
                              p_Atd_Ndt   => l_Form_Ndt,
                              p_Doc       => p_Doc_Cur);
    /*

    SELECT a.At_St
      INTO l_At_St
      FROM Act a
     WHERE a.At_Id = p_At_Id
       FOR UPDATE;

    SELECT MAX(d.Atd_Id), MAX(d.Atd_Doc), MAX(d.Atd_Dh)
      INTO l_Atd_Id, l_Doc_Id, l_Dh_Id
      FROM At_Document d
     WHERE d.Atd_At = p_At_Id
       AND d.Atd_Ndt = l_Form_Ndt
       AND d.History_Status = 'A';

    l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;

    IF l_Atd_Id IS NULL THEN
      Uss_Doc.Api$documents.Save_Document(p_Doc_Id        => NULL,
                                          p_Doc_Ndt       => l_Form_Ndt,
                                          p_Doc_Actuality => 'U',
                                          p_New_Id        => l_Doc_Id);

      Uss_Doc.Api$documents.Save_Doc_Hist(p_Dh_Id        => NULL,
                                          p_Dh_Doc       => l_Doc_Id,
                                          p_Dh_Sign_Alg  => NULL,
                                          p_Dh_Ndt       => l_Form_Ndt,
                                          p_Dh_Sign_File => NULL,
                                          p_Dh_Actuality => 'U',
                                          p_Dh_Dt        => SYSDATE,
                                          p_Dh_Wu        => NULL,
                                          p_Dh_Src       => 'CMES',
                                          p_Dh_Cu        => l_Cu_Id,
                                          p_New_Id       => l_Dh_Id);



      INSERT INTO At_Document
        (Atd_Id, Atd_At, Atd_Ndt, Atd_Doc, Atd_Dh, History_Status)
      VALUES
        (0, p_At_Id, l_Form_Ndt, l_Doc_Id, l_Dh_Id, 'A')
      RETURNING Atd_Id INTO l_Atd_Id;
    ELSE
      BEGIN
        SELECT File_Code, File_Hash
        INTO l_File_Code, l_File_Hash
        FROM(SELECT f.File_Code, f.File_Hash, nvl(a.dat_num,-1) dat_num, nvl(max(a.dat_num) over (),-1) max_dat_num
             FROM Uss_Doc.v_Doc_Attachments a
             JOIN Uss_Doc.v_Files f
               ON a.Dat_File = f.File_Id
              WHERE a.Dat_Dh = l_Dh_Id)
         WHERE dat_Num =  max_dat_num;
      EXCEPTION
        WHEN No_Data_Found THEN
          NULL;
      END;
    END IF;

    IF l_At_St IN ('RS.C', 'RS.S') THEN
      --Виконуємо побудову друк. форми акту тільки якщо він в стані проекту
      --Для всіх інших станів передбачається, що друковану форму вже ствоерно
      EXECUTE IMMEDIATE 'select ' || l_Build_Proc || '(:p_At_Id) from dual'
        INTO l_File_Content
        USING IN p_At_Id;
    END IF;

    OPEN p_Doc_Cur FOR
      SELECT l_Atd_Id AS Atd_Id, l_Form_Ndt AS Atd_Ndt, l_Doc_Id AS Atd_Doc, l_Dh_Id AS Atd_Dh, l_File_Code AS File_Code,
             l_File_Hash AS File_Hash, l_File_Content AS File_Content
        FROM Dual;*/
    END;


    -----------------------------------------------------------
    --ОТРИМАННЯ ІДЕНТИФІКАТОРІВ ДОКУМЕНТУ ДРУКОВАНОЇ ФОРМИ АКТУ
    -----------------------------------------------------------
    PROCEDURE Get_Form_Doc (p_At_Id IN NUMBER, p_Doc OUT SYS_REFCURSOR)
    IS
    BEGIN
        Write_Audit ('Get_Form_Doc');
        Api$act.Get_Form_Doc (
            p_At_Id     => p_At_Id,
            p_Atd_Ndt   => Api$act.Define_Print_Form_Ndt (p_At_Id),
            p_Doc       => p_Doc);
    END;

    -----------------------------------------------------------
    -- Визначення хто приймав рішення про надання СП(НСП/ОСЗН)
    -----------------------------------------------------------
    FUNCTION Get_Direction (p_At_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (10);
    BEGIN
        SELECT Api$appeal.Get_Ap_Doc_Str (d.At_Ap, 'DIRECTION')
          INTO l_Result
          FROM Act a JOIN Act d ON a.At_Main_Link = d.At_Id
         WHERE a.At_Id = p_At_Id;

        RETURN l_Result;
    END;

    -----------------------------------------------------------
    -- "ВІДПРАВКА" АКТУ НАДАВАЧУ НА ПІДПИС
    -----------------------------------------------------------
    PROCEDURE Send_To_Pr (p_At_Id NUMBER, p_Messages OUT SYS_REFCURSOR)
    IS
    BEGIN
        Write_Audit ('Send_To_Pr');
        Check_Act_Access (p_At_Id);

        IF Api$act_Validation.Validate_Act (p_At_Id, p_Messages)
        THEN
            Api$act.Approve_Act (p_At_Id);
        END IF;
    END;

    -----------------------------------------------------------
    -- "ВІДПРАВКА" ПОВІДОМЛЕННЯ НАДАВАЧУ НА ПІДПИМ
    -----------------------------------------------------------
    PROCEDURE Set_Signed_Cm (p_At_Id              NUMBER,
                             p_file_code   IN     VARCHAR2,
                             p_Messages       OUT SYS_REFCURSOR)
    IS
    BEGIN
        Write_Audit ('Set_Signed_Cm');

        /*
        --#111840
        IF Get_Direction(p_At_Id) = 'SB' THEN
          Raise_Application_Error(-20000,
                                  'Опрацювання цього рішення повинно виконуватись спеціалістами ОСЗН');
        END IF;
        */

        Cmes$act.Set_Signed_Cm (p_At_Id => p_At_Id, p_file_code => p_file_code);
        --#111840
        --Виконуємо зміну статуса лише у разі, якщо проект акту пройшов всі контролі
        --IF Api$act_Validation.Validate_Act(p_At_Id, p_Messages) THEN
        Api$act.Approve_Act (p_At_Id);
    --END IF;
    END;

    -----------------------------------------------------------
    -- ЗБЕРЕЖЕННЯ ВІДМІТКИ ПРО ПОВЕРНЕННЯ ВІД НСП
    -----------------------------------------------------------
    PROCEDURE Set_Reject_Pr (p_At_Id          NUMBER,
                             p_file_code   IN VARCHAR2 DEFAULT NULL)
    IS
    BEGIN
        Write_Audit ('Set_Reject_Pr');
        --#111840
        /*
        IF Get_Direction(p_At_Id) = 'SB' THEN
          Raise_Application_Error(-20000,
                                  'Опрацювання цього рішення повинно виконуватись спеціалістами ОСЗН');
        END IF;
        */
        Api$act.Rejects_Act (p_At_Id);
    END;


    -----------------------------------------------------------
    -- ЗБЕРЕЖЕННЯ ВІДМІТКИ ПРО НАКЛАДАННЯ ПІДПИСУ НСП
    -----------------------------------------------------------
    PROCEDURE Set_Signed_Pr (p_At_Id          NUMBER,
                             p_file_code   IN VARCHAR2 DEFAULT NULL)
    IS
    BEGIN
        Write_Audit ('Set_Signed_Pr');
        --#111840
        /*
        IF Get_Direction(p_At_Id) = 'SB' THEN
          Raise_Application_Error(-20000,
                                  'Опрацювання цього рішення повинно виконуватись спеціалістами ОСЗН');
        END IF;
        */
        Cmes$act.Set_Signed_Pr (p_At_Id => p_At_Id, p_file_code => p_file_code);
        Api$act.Approve_Act (p_At_Id);
    END;

    -----------------------------------------------------------
    -- ПЕРЕВОД АКТУ В СТАН "ВІДХИЛЕНО"
    -----------------------------------------------------------
    PROCEDURE Set_Declined (p_At_Id IN NUMBER, p_Reason IN VARCHAR2)
    IS
        l_St        VARCHAR2 (10);
        l_St_Name   VARCHAR2 (100);
    BEGIN
        Write_Audit ('Set_Declined');
        Check_Act_Access (p_At_Id);

        IF Get_Direction (p_At_Id) = 'SB'
        THEN
            Raise_Application_Error (
                -20000,
                'Опрацювання цього рішення повинно виконуватись спеціалістами ОСЗН');
        END IF;

        Api$act.Rejects_Act (p_At_Id     => p_At_Id,
                             p_St        => l_St,
                             p_St_Name   => l_St_Name);
        Api$act.Write_At_Log (
            p_Atl_At        => p_At_Id,
            p_Atl_Hs        => Tools.Gethistsessioncmes (),
            p_Atl_St        => l_St,
            p_Atl_Message   => CHR (38) || '231#' || p_Reason,
            p_Atl_St_Old    => NULL);
    END;


    PROCEDURE Approve_Act_Action (p_at_id IN NUMBER)
    IS
        l_Tctr_Id            NUMBER;
        l_Pdsp_Id            NUMBER;
        l_Ap_id              NUMBER;
        l_At_Num             Act.At_Num%TYPE;
        l_Unclosed_Svc_Cnt   NUMBER;
        l_hs                 NUMBER
                                 := NVL (Api$act.g_hs, Tools.Gethistsession);
    BEGIN
        --#110881 прибрано відповідно до цієї задачі
        --IF NOT Api$act.Act_Exists(p_At_Main_Link => p_At_Id, p_At_Main_Link_Tp => 'RSTOPSS', p_At_Tp => 'PPNP', p_At_St => 'MP') THEN
        --  Raise_Application_Error(-20000,'Не затверджено повідомлення про припинення надання СП');
        --  null;
        --END IF;

        --Отримуємо ідентифікатор договору по якому створено рішення про припинення
        --#111840
        SELECT API$APPEAL.Get_Ap_Attr_Str (at_ap, 3062), at_ap
          INTO l_Tctr_Id, l_Ap_Id
          FROM act
         WHERE at_id = p_at_id;

        IF l_Tctr_Id IS NULL
        THEN
            SELECT MAX (l.Atk_Link_At)
              INTO l_Tctr_Id
              FROM At_Links l JOIN Act a ON l.Atk_Link_At = a.At_Id
             WHERE     l.Atk_At = p_At_Id
                   AND l.Atk_Tp = 'TCTR'
                   AND a.At_St = 'DT';
        END IF;

        IF l_Tctr_Id IS NULL
        THEN
            RETURN;
        END IF;

        --Отримуємо номер рішення про припинення та ідентифікатор рішення про надання
        SELECT a.At_Num,
               NVL (a.At_Main_Link,
                    (SELECT at.At_Main_Link
                       FROM act at
                      WHERE at.at_id = l_Tctr_Id))
          INTO l_At_Num, l_Pdsp_Id
          FROM Act a
         WHERE a.At_Id = p_At_Id;

        uss_esr.cmes$sc_journal.Update_SC_JOURNAL (p_At_Id);

        --Закриваємо індивідуальні плани
        FOR Rec
            IN (SELECT a.At_Id
                  FROM At_Links  l
                       JOIN Act a ON l.Atk_At = a.At_Id AND a.At_Tp = 'IP'
                 WHERE     l.Atk_Link_At = l_Pdsp_Id
                       AND l.Atk_Tp = 'DECISION'
                       AND a.At_St IN ('IT'))
        LOOP
            Api$act.Set_At_St (
                p_At_Id          => Rec.At_Id,
                p_At_St_Old      => 'IT',
                p_At_St_New      => 'IC',                                 --IR
                p_Log_Msg        => CHR (38) || '257#' || l_At_Num,
                p_Wrong_St_Msg   => 'Стан індивідуального плану було змінено');
        END LOOP;


        /*#102437*/
        UPDATE at_service t
           SET t.ats_st = 'ST'
         WHERE t.ats_at = l_pdsp_id--and t.ats_nst in (select ats_nst from At_Service z where z.ats_at = p_at_id AND z.History_Status = 'A')
                                   --and t.ats_st IN ('SG', 'SU')
                                   ;

        UPDATE at_service t
           SET t.ats_st = 'ST'
         WHERE t.ats_at = l_tctr_id--and t.ats_nst in (select ats_nst from At_Service z where z.ats_at = p_at_id AND z.History_Status = 'A')
                                   ;

        SELECT COUNT (*)
          INTO l_Unclosed_Svc_Cnt
          FROM At_Service  Ts
               LEFT JOIN At_Service Rs
                   ON     Rs.Ats_At = p_at_id
                      AND Ts.Ats_Nst = Rs.Ats_Nst
                      AND Rs.History_Status = 'A'
         WHERE     Ts.Ats_At = l_Tctr_Id
               AND Ts.History_Status = 'A'
               --todo: уточнити чи треба аналізувати статус послуг
               --AND Ts.Ats_St IN ('SG', 'P')
               AND Ts.Ats_St NOT IN ('ST')--AND Rs.Ats_Id IS NULL
                                          ;

        --Якщо припиняються всі послуги наявні в договорі
        IF l_Unclosed_Svc_Cnt = 0
        THEN
            --Закриваємо договір
            Api$act.Set_At_St (
                p_At_Id          => l_Tctr_Id,
                p_At_St_Old      => 'DT',
                p_At_St_New      => 'DP',
                p_Log_Msg        => CHR (38) || '256#' || l_At_Num,
                p_Wrong_St_Msg   => 'Стан договору було змінено');

            --Закриваємо PDSP
            Api$act.Set_At_St (
                p_At_Id          => l_Pdsp_Id,
                p_At_St_Old      => 'SS',
                p_At_St_New      => 'SV',
                p_Log_Msg        => CHR (38) || '256#' || l_At_Num,
                p_Wrong_St_Msg   => 'Стан договору було змінено');

            API$ESR_Action.PrepareWrite_Visit_at_log (
                p_at_Id,
                CHR (38) || '153#' || l_at_num,
                NULL,
                l_hs);
        END IF;
    END;

    -----------------------------------------------------------
    --     ПЕРЕВІРКА НАЯВНОСТІ ДОСТУПУ ДО ФАЙЛУ
    -----------------------------------------------------------
    FUNCTION Check_File_Access (p_File_Code IN VARCHAR2, p_Cmes_Id IN NUMBER --Ignore
                                                                            )
        RETURN VARCHAR2
    IS
    BEGIN
        Write_Audit ('Check_File_Access');
        RETURN Cmes$act.Check_File_Access (p_File_Code   => p_File_Code,
                                           p_Cmes_Id     => p_Cmes_Id);
    END;
END Cmes$act_Rstopss;
/