/* Formatted on 8/12/2025 5:48:26 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.CMES$ACT_PPNP
IS
    -- Author  : SHOSTAK
    -- Created : 23.09.2023 4:27:05 PM
    -- Purpose :

    Pkg   VARCHAR2 (50) := 'CMES$ACT_PPNP';


    PROCEDURE Save_Act (p_Rstopss_Id     IN     NUMBER,
                        p_At_Signers     IN     CLOB,
                        p_At_Documents   IN     CLOB DEFAULT NULL,
                        p_At_Attrs       IN     CLOB DEFAULT NULL,
                        p_At_Id             OUT NUMBER);

    PROCEDURE Get_Acts_By_Tctr (p_Tctr_Id         IN     NUMBER,
                                p_Cmes_Owner_Id   IN     NUMBER,
                                p_Acts               OUT SYS_REFCURSOR);

    FUNCTION Get_Agent_Pib (p_Ap_Id IN NUMBER)
        RETURN VARCHAR2;

    PROCEDURE Get_Act_Card (p_At_Id         IN     NUMBER,
                            p_Act_Cur          OUT SYS_REFCURSOR,
                            p_Pers_Cur         OUT SYS_REFCURSOR,
                            p_Signers_Cur      OUT SYS_REFCURSOR);

    PROCEDURE Get_Act_Card (p_At_Id         IN     NUMBER,
                            p_Act_Cur          OUT SYS_REFCURSOR,
                            p_Pers_Cur         OUT SYS_REFCURSOR,
                            p_Signers_Cur      OUT SYS_REFCURSOR,
                            p_Docs             OUT SYS_REFCURSOR,
                            p_Docs_Attr        OUT SYS_REFCURSOR,
                            p_Docs_Files       OUT SYS_REFCURSOR);

    PROCEDURE Get_Form_File (p_At_Id       IN     NUMBER,
                             p_Atd_Dh         OUT NUMBER,
                             p_File_Code      OUT VARCHAR2);

    PROCEDURE Get_Form_File (p_At_Id                  IN     NUMBER,
                             p_Atd_Dh                    OUT NUMBER,
                             p_File_Code                 OUT VARCHAR2,
                             p_File_Signs_Code_List      OUT VARCHAR2);

    PROCEDURE Get_Form_File (p_At_Id IN NUMBER, p_Doc_Cur OUT SYS_REFCURSOR);

    PROCEDURE Get_Doc_Files (p_At_Id NUMBER, p_Res OUT SYS_REFCURSOR);

    PROCEDURE Get_Form_Doc (p_At_Id IN NUMBER, p_Doc OUT SYS_REFCURSOR);

    PROCEDURE Send_To_Pr (p_At_Id NUMBER, p_Messages OUT SYS_REFCURSOR);

    PROCEDURE Set_Signed_Pr (p_At_Id          NUMBER,
                             p_file_code   IN VARCHAR2 DEFAULT NULL);

    PROCEDURE Set_Canceled (p_At_Id IN NUMBER, p_Reason IN VARCHAR2);

    PROCEDURE Set_Declined (p_At_Id IN NUMBER, p_Reason IN VARCHAR2);

    FUNCTION Check_File_Access (p_File_Code IN VARCHAR2, p_Cmes_Id IN NUMBER --Ignore
                                                                            )
        RETURN VARCHAR2;
END Cmes$act_Ppnp;
/


GRANT EXECUTE ON USS_ESR.CMES$ACT_PPNP TO II01RC_USS_ESR_PORTAL
/

GRANT EXECUTE ON USS_ESR.CMES$ACT_PPNP TO PORTAL_PROXY
/


/* Formatted on 8/12/2025 5:49:23 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.CMES$ACT_PPNP
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

        g_Nda_Map (3116) := 'At_Head_Position';
        g_Nda_Map (3117) := 'At_Head_Nm';
        g_Nda_Map (3118) := 'At_Head_Ln';
    END;

    -----------------------------------------------------------
    --            ЗБЕРЕЖЕННЯ АКТУ
    -----------------------------------------------------------
    PROCEDURE Save_Act (p_Rstopss_Id     IN     NUMBER,
                        p_At_Signers     IN     CLOB,
                        p_At_Documents   IN     CLOB DEFAULT NULL,
                        p_At_Attrs       IN     CLOB DEFAULT NULL,
                        p_At_Id             OUT NUMBER)
    IS
        l_Cu_Id        NUMBER;
        l_At_Cu        NUMBER;
        l_At_St_Old    VARCHAR2 (10);
        l_Rstopss_St   VARCHAR2 (10);
        l_At_Rnspm     NUMBER;
        l_Signers      Api$act.t_At_Signers;
        l_Documents    Api$act.t_At_Documents;
        l_Ap_Id        NUMBER;
        l_Atd_Id       NUMBER;
        l_Attrs        Api$act.t_At_Document_Attrs;
    BEGIN
        Write_Audit ('Save_Act');
        l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;

        SELECT a.At_Rnspm,
               a.At_Cu,
               a.At_Ap,
               a.At_St
          INTO l_At_Rnspm,
               l_At_Cu,
               l_Ap_Id,
               l_Rstopss_St
          FROM Act a
         WHERE a.At_Id = p_Rstopss_Id AND a.At_Tp = 'RSTOPSS';


        IF l_At_Cu IS NULL OR l_At_Cu <> NVL (l_Cu_Id, -1)
        THEN
            Api$act.Raise_Unauthorized;
        END IF;

        IF l_Rstopss_St NOT IN ('RM.N')
        THEN
            Raise_Application_Error (
                -20000,
                'Збереження повідомлення можливо лише для рішень в стані "Очікує повідомлення НСП"');
        END IF;


        BEGIN
            SELECT a.At_Id, a.At_St
              INTO p_At_Id, l_At_St_Old
              FROM Act a
             WHERE     a.At_Main_Link = p_Rstopss_Id
                   AND a.At_Tp = 'PPNP'
                   AND a.at_st NOT IN ('MD', 'MR');
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                NULL;
        END;

        IF p_At_Id IS NOT NULL AND l_At_St_Old <> 'MN'
        THEN
            Raise_Application_Error (
                -20000,
                'Додавання підписантів в поточному статусі заборонено');
        END IF;

        IF p_At_Id IS NULL
        THEN
            Api$act.Init_Ppnp (p_Rstopss_Id   => p_Rstopss_Id,
                               p_At_Id        => p_At_Id);
        END IF;

        l_Signers := Api$act.Parse_Signers (p_At_Signers);
        l_Documents := Api$act.Parse_Documents (p_At_Documents);
        l_Attrs := Api$act.Parse_Attributes (p_At_Attrs);


        Api$act.Save_Signers (p_At_Id => p_At_Id, p_Signers => l_Signers);
        Api$act.Save_Documents (p_At_Id          => p_At_Id,
                                p_At_Documents   => l_Documents);

        /*Map_Nda2act;
        l_Atd_Id := Api$act.Get_Form_Doc(p_At_Id => p_At_Id, p_Atd_Ndt => Api$act.Define_Print_Form_Ndt(p_At_Id));
        Api$act.Save_Attributes(p_At_Id => p_At_Id, p_Atd_Id => l_Atd_Id, p_Attrs => l_Attrs, p_Nda_Map => g_Nda_Map);
      */
        Api$act.Write_At_Log (p_Atl_At        => p_At_Id,
                              p_Atl_Hs        => Tools.Gethistsessioncmes,
                              p_Atl_St        => l_At_St_Old,
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
                   --Загальна інформація
                   --12. ПІБ законного представника / уповноваженої особи ОСП
                   Get_Agent_Pib (a.At_Ap)
                       AS At_Agent_Pib,
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
                   --Ким сформовано форму ведення випадку
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
                   --Повідомлення – попередження про припинення надання соціальних послуг щодо кого
                   --18. Прізвище особи --19. Ім’я особи  --20. По-батькові особи
                   a.At_Sc,
                   Uss_Person.Api$sc_Tools.Get_Pib (a.At_Sc)
                       AS At_Sc_Pib,
                   --Підписант (керівник) повідомлення
                   --26. Посада підписанта
                   COALESCE (Api$act.Get_Signer_Position (a.At_Id, 'PR'),
                             Api$act.Get_Signer_Position (a.At_Id, 'SB'))
                       AS At_Approver_Position,
                   --27. Прізвище підписанта --28. Ім’я підписанта --29. По-батькові підписанта
                   COALESCE (Api$act.Get_Signer_Pib (a.At_Id, 'PR'),
                             Api$act.Get_Signer_Pib (a.At_Id, 'SB'))
                       AS At_Approver_Pib,
                   --Адреса для листування
                   a.At_Live_Address,
                   --ІД договору
                   t.At_Id
                       AS At_Tctr,
                   --9. Номер договору
                   t.At_Num
                       AS At_Tctr_Num,
                   --10. Дата договору
                   t.At_Dt
                       AS At_Tctr_Dt,
                   --Дата припинення надання СП
                   a.At_Action_Stop_Dt
                       AS At_Terminate_Dt,
                   --Причина припинення надання СП
                   a.At_Rnp,
                   r.Rnp_Name
                       AS At_Rnp_Name,
                   --Рішення про припинення
                   a.At_Main_Link
                       AS At_Rstopss
              FROM Tmp_Work_Ids  t
                   JOIN Act a ON t.x_Id = a.At_Id
                   JOIN Uss_Ndi.v_Ddn_At_Ppnp_St s ON a.At_St = s.Dic_Value
                   JOIN Uss_Ndi.v_Ddn_Ap_Src Sr ON a.At_Src = Sr.Dic_Value
                   LEFT JOIN Uss_Ndi.v_Ndi_Reason_Not_Pay r
                       ON a.At_Rnp = r.Rnp_Id
                   LEFT JOIN Ikis_Sys.v_Opfu o ON a.At_Org = o.Org_Id
                   LEFT JOIN At_Links l
                       ON a.At_Id = l.Atk_At AND l.Atk_Tp = 'TCTR'
                   LEFT JOIN Act t ON l.Atk_Link_At = t.At_Id;
    END;

    -----------------------------------------------------------
    --     ОТРИМАННЯ ПЕРЕЛІКУ ПОВІДОМЛЕНЬ ЗА ДОГОВОРОМ
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
                SELECT a.At_Id
                  FROM At_Links  l
                       JOIN Act a
                           ON     l.Atk_At = a.At_Id
                              AND a.At_Tp = 'PPNP'
                              AND a.At_Rnspm = p_Cmes_Owner_Id
                 WHERE     l.Atk_Link_At = p_Tctr_Id
                       AND l.Atk_Tp = 'TCTR'
                       AND a.At_St <> 'MD';
        ELSE
            l_Sc_Id := Ikis_Rbm.Tools.Getcusc (Ikis_Rbm.Tools.Getcurrentcu);

            INSERT INTO Tmp_Work_Ids (x_Id)
                SELECT a.At_Id
                  FROM At_Links  l
                       JOIN Act a ON l.Atk_At = a.At_Id AND a.At_Tp = 'PPNP'
                 WHERE     l.Atk_Link_At = p_Tctr_Id
                       AND l.Atk_Tp = 'TCTR'
                       AND a.At_St IN ('MP')
                       AND a.At_St <> 'MD'
                       AND (   a.At_Sc = l_Sc_Id
                            OR EXISTS
                                   (SELECT 1
                                      FROM At_Person p
                                     WHERE     p.Atp_At = a.At_Id
                                           AND p.Atp_Sc = l_Sc_Id
                                           AND p.History_Status = 'A'
                                           AND p.Atp_App_Tp IN ('Z', 'OS')));
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
                   --Загальна інформація
                   --12. ПІБ законного представника / уповноваженої особи ОСП
                   Get_Agent_Pib (a.At_Ap)
                       AS At_Agent_Pib,
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
                   --Ким сформовано форму ведення випадку
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
                   --Повідомлення – попередження про припинення надання соціальних послуг щодо кого
                   --18. Прізвище особи --19. Ім’я особи  --20. По-батькові особи
                   a.At_Sc,
                   Uss_Person.Api$sc_Tools.Get_Pib (a.At_Sc)
                       AS At_Sc_Pib,
                   --Підписант (керівник) повідомлення
                   --26. Посада підписанта
                   COALESCE (Api$act.Get_Signer_Position (a.At_Id, 'PR'),
                             Api$act.Get_Signer_Position (a.At_Id, 'SB'))
                       AS At_Approver_Position,
                   --27. Прізвище підписанта --28. Ім’я підписанта --29. По-батькові підписанта
                   COALESCE (Api$act.Get_Signer_Pib (a.At_Id, 'PR'),
                             Api$act.Get_Signer_Pib (a.At_Id, 'SB'))
                       AS At_Approver_Pib,
                   --місце проживання/перебування особи, яка отримувала соціальну(і) послугу(и) / законного представника / місцезнаходження органу опіки та піклування
                   a.At_Live_Address,
                   --ІД договору
                   t.At_Id
                       AS At_Tctr,
                   --9. Номер договору
                   t.At_Num
                       AS At_Tctr_Num,
                   --10. Дата договору
                   t.At_Dt
                       AS At_Tctr_Dt,
                   --Дата припинення надання СП
                   a.At_Action_Stop_Dt
                       AS At_Terminate_Dt,
                   --Причина припинення надання СП
                   a.At_Rnp,
                   r.Rnp_Name
                       AS At_Rnp_Name,
                   --Рішення про припинення
                   a.At_Main_Link
                       AS At_Rstopss,
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
                       AS decline_reason
              FROM Act  a
                   LEFT JOIN Uss_Ndi.v_Ddn_At_Ppnp_St s
                       ON a.At_St = s.Dic_Value
                   LEFT JOIN Uss_Ndi.v_Ddn_Ap_Src Sr
                       ON a.At_Src = Sr.Dic_Value
                   LEFT JOIN Uss_Ndi.v_Ndi_Reason_Not_Pay r
                       ON a.At_Rnp = r.Rnp_Id
                   LEFT JOIN Ikis_Sys.v_Opfu o ON a.At_Org = o.Org_Id
                   LEFT JOIN At_Links l
                       ON a.At_Id = l.Atk_At AND l.Atk_Tp = 'TCTR'
                   LEFT JOIN Act t ON l.Atk_Link_At = t.At_Id
             WHERE a.At_Id = p_At_Id;
    END;

    -----------------------------------------------------------
    --     ОТРИМАННЯ ДАНИХ ПОВІДОМЛЕННЯ. Для USS.Api
    -----------------------------------------------------------
    PROCEDURE Get_Act_Card (p_At_Id         IN     NUMBER,
                            p_Act_Cur          OUT SYS_REFCURSOR,
                            p_Pers_Cur         OUT SYS_REFCURSOR,
                            p_Signers_Cur      OUT SYS_REFCURSOR,
                            p_Docs             OUT SYS_REFCURSOR,
                            p_Docs_Attr        OUT SYS_REFCURSOR,
                            p_Docs_Files       OUT SYS_REFCURSOR)
    IS
    BEGIN
        Write_Audit ('Get_Act_Card');
        Check_Act_Access (p_At_Id);

        Api$Act.Check_At_Tp (p_At_Id, 'PPNP');

        Get_Act (p_At_Id, p_Act_Cur);
        Api$act.Get_Persons (p_At_Id, p_Pers_Cur);
        Api$act.Get_Signers (p_At_Id, p_Signers_Cur);
        Api$act.Get_Documents (p_At_Id, p_Docs);
        Api$act.Get_Doc_Attributes (p_At_Id, p_Docs_Attr);
        Api$Act.Get_Doc_Files (p_At_Id, p_Docs_Files);
    END;

    -----------------------------------------------------------
    --     ОТРИМАННЯ ДАНИХ ПОВІДОМЛЕННЯ. Для USS.Portal
    -----------------------------------------------------------
    PROCEDURE Get_Act_Card (p_At_Id         IN     NUMBER,
                            p_Act_Cur          OUT SYS_REFCURSOR,
                            p_Pers_Cur         OUT SYS_REFCURSOR,
                            p_Signers_Cur      OUT SYS_REFCURSOR)
    IS
    BEGIN
        Write_Audit ('Get_Act_Card');
        Check_Act_Access (p_At_Id);

        Api$Act.Check_At_Tp (p_At_Id, 'PPNP');

        Get_Act (p_At_Id, p_Act_Cur);
        Api$act.Get_Persons (p_At_Id, p_Pers_Cur);
        Api$act.Get_Signers (p_At_Id, p_Signers_Cur);
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
        l_Ndt_Id       NUMBER;
        l_Build_Proc   VARCHAR2 (1000);
    BEGIN
        Write_Audit ('Get_Form_File');
        Check_Act_Access (p_At_Id);

        l_Ndt_Id := Api$act.Define_Print_Form_Ndt (p_At_Id, l_Build_Proc);
        Api$act.Get_Form_File (p_At_Id             => p_At_Id,
                               p_At_Prj_St         => 'MN',
                               p_Form_Ndt          => l_Ndt_Id,
                               p_Form_Build_Proc   => l_Build_Proc,
                               p_Doc_Cur           => p_Doc_Cur);
    END;

    PROCEDURE Get_Doc_Files (p_At_Id NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        Api$Act.Get_Signed_Doc_Files (p_At_Id, p_Res);
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
    -- "ВІДПРАВКА" ПОВІДОМЛЕННЯ НАДАВАЧУ НА ПІДПИМ
    -----------------------------------------------------------
    PROCEDURE Send_To_Pr (p_At_Id NUMBER, p_Messages OUT SYS_REFCURSOR)
    IS
    BEGIN
        Write_Audit ('Send_To_Pr');
        Check_Act_Access (p_At_Id);

        IF Api$appeal.Get_Ap_Doc_Str (Api$act.Get_At_Ap (p_At_Id),
                                      'DIRECTION') =
           'SB'
        THEN
            Raise_Application_Error (
                -20000,
                'Опрацювання повідомлення повинно виконуватись спеціалістами ОСЗН');
        END IF;

        --Виконуємо зміну статуса лише у разі, якщо проект акту пройшов всі контролі
        IF Api$act_Validation.Validate_Act (p_At_Id, p_Messages)
        THEN
            Api$act.Set_At_St (
                p_At_Id       => p_At_Id,
                p_At_St_Old   => 'MN',
                p_At_St_New   => 'MV.N',
                p_Log_Msg     => CHR (38) || '252',
                p_Wrong_St_Msg   =>
                    'Відправка повідомлення надавачу можлива лише в стані проекту');
        END IF;
    END;

    -----------------------------------------------------------
    -- ЗБЕРЕЖЕННЯ ВІДМІТКИ ПРО НАКЛАДАННЯ ПІДПИСУ НСП
    -----------------------------------------------------------
    PROCEDURE Set_Signed_Pr (p_At_Id          NUMBER,
                             p_file_code   IN VARCHAR2 DEFAULT NULL)
    IS
        l_At_Rstopss   NUMBER;
        l_Messages     VARCHAR2 (32000);
    BEGIN
        Write_Audit ('Set_Signed_Pr');

        /*
        IF Api$appeal.Get_Ap_Doc_Str(Api$act.Get_At_Ap(p_At_Id), 'DIRECTION') = 'SB' THEN
          Raise_Application_Error(-20000,
                                  'Опрацювання цього повідомлення повинно виконуватись спеціалістами ОСЗН');
        END IF;

        IF Api$act_Validation.Validate_Act(p_At_Id, l_Messages) THEN
          Raise_Application_Error(-20000,
                                  l_Messages);

        END IF;
        */

        Cmes$act.Set_Signed_Pr (p_At_Id => p_At_Id, p_file_code => p_file_code);
        Api$act.Set_At_St (
            p_At_Id       => p_At_Id,
            p_At_St_Old   => 'MV.N',                                    --MV.N
            p_At_St_New   => 'MP',                                        --MP
            p_Log_Msg     => CHR (38) || '253',
            p_Wrong_St_Msg   =>
                'Затвердження надавачем можливо лише в стані "Очікує підписання"');

        --Отримуємо ІД рішення про припинення
        SELECT a.At_Main_Link
          INTO l_At_Rstopss
          FROM Act a
         WHERE a.At_Id = p_At_Id;

        --Змінюємо стан рішення про припинення
        Api$act.Approve_Act (l_At_Rstopss);
    END;

    -----------------------------------------------------------
    -- ПЕРЕВОД АКТУ В СТАН "СКАСОВАНО"
    -----------------------------------------------------------
    PROCEDURE Set_Canceled (p_At_Id IN NUMBER, p_Reason IN VARCHAR2)
    IS
    BEGIN
        Write_Audit ('Set_Canceled');

        IF p_Reason IS NULL
        THEN
            Raise_Application_Error (-20000, 'Не вказано причину скасування');
        END IF;

        IF Api$appeal.Get_Ap_Doc_Str (Api$act.Get_At_Ap (p_At_Id),
                                      'DIRECTION') =
           'SB'
        THEN
            Raise_Application_Error (
                -20000,
                'Опрацювання цього повідомлення повинно виконуватись спеціалістами ОСЗН');
        END IF;

        Cmes$act.Check_Act_Access_Cm (p_At_Id);

        Api$act.Set_At_St (
            p_At_Id          => p_At_Id,
            p_At_St_Old      => 'MN',
            p_At_St_New      => 'MD',
            p_Log_Msg        => CHR (38) || '230#' || p_Reason,
            p_Wrong_St_Msg   => 'Скасування можливо лише в стані проекту');
    END;

    -----------------------------------------------------------
    -- ПЕРЕВОД АКТУ В СТАН "ВІДХИЛЕНО"
    -----------------------------------------------------------
    PROCEDURE Set_Declined (p_At_Id IN NUMBER, p_Reason IN VARCHAR2)
    IS
        l_Cu_Id   NUMBER;
        l_At_St   VARCHAR2 (10);
    BEGIN
        Write_Audit ('Set_Declined');

        IF p_Reason IS NULL
        THEN
            Raise_Application_Error (-20000, 'Не вказано причину відхилення');
        END IF;

        l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;
        l_At_St := Api$act.Get_At_St (p_At_Id);


        IF NOT Cmes$act.Check_Act_Access_Pr (p_At_Id)
        THEN
            Raise_Application_Error (
                -20000,
                'Відхилення може виконувати лише надавач соц. послуг');
        END IF;

        Api$act.Set_At_St (
            p_At_Id       => p_At_Id,
            p_At_St_Old   => 'MV.N',
            p_At_St_New   => 'MR',
            p_Log_Msg     => CHR (38) || '231#' || p_Reason,
            p_Wrong_St_Msg   =>
                'Відхилити можливо лише в стані "Очікує підписання"');
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
END Cmes$act_Ppnp;
/