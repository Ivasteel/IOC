/* Formatted on 8/12/2025 5:57:57 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_RNSP.DNET$DOCUMENT
IS
    -- Author  : LESHA
    -- Created : 15.04.2022 17:30:22
    -- Purpose :

    Package_Name         CONSTANT VARCHAR2 (100) := 'DNET$DOCUMENT';

    c_Xml_Dt_Fmt         CONSTANT VARCHAR2 (30) := 'YYYY-MM-DD"T"HH24:MI:SS';

    Msg_Opt_Block_Viol   CONSTANT NUMBER := 6011;

    --Атрибути докумена
    TYPE r_rn_Document_Attr IS RECORD
    (
        rnda_Id            rn_Document_Attr.rnda_Id%TYPE,
        rnda_Nda           rn_Document_Attr.rnda_Nda%TYPE,
        rnda_Val_String    rn_Document_Attr.rnda_Val_String%TYPE,
        rnda_Val_Int       rn_Document_Attr.rnda_Val_Int%TYPE,
        rnda_Val_Dt        TIMESTAMP,
        rnda_Val_Id        rn_Document_Attr.rnda_Val_Id%TYPE,
        rnda_Val_Sum       rn_Document_Attr.rnda_Val_Sum%TYPE,
        rnda_Apd           rn_Document_Attr.rnda_rnd%TYPE,
        Deleted            NUMBER
    );

    TYPE t_rn_Document_Attrs IS TABLE OF r_rn_Document_Attr;


    --=============================================--
    --                    ЗБЕРЕЖЕННЯ атрибутів документів
    --=============================================--
    PROCEDURE Save_Document_attrs (p_rnd_Id     IN rn_Document.rnd_Id%TYPE,
                                   p_rn_attrs   IN CLOB);

    --=============================================--
    --                    СТВОРЕННЯ нового документу
    --=============================================--

    PROCEDURE Save_Doc (p_rnd_Id      IN rn_Document.rnd_Id%TYPE,
                        p_rnd_Rnspm   IN rn_Document.Rnd_Rnspm%TYPE,
                        p_rnd_Ndt     IN rn_Document.rnd_Ndt%TYPE,
                        p_rnd_Doc     IN rn_Document.rnd_Doc%TYPE,
                        p_rnd_Dh      IN rn_Document.rnd_Dh%TYPE,
                        p_rnd_St      IN rn_Document.Rnd_St%TYPE,
                        p_rn_attrs    IN CLOB);

    -- документи не по зверненням по картці рнсп
    PROCEDURE GET_DOC_LIST (p_Rnspm_Id   IN     NUMBER,
                            DOC_CUR         OUT SYS_REFCURSOR,
                            ATTR_CUR        OUT SYS_REFCURSOR,
                            FILES_CUR       OUT SYS_REFCURSOR);


    -- Логування при підпису
    PROCEDURE WRITE_CRYPTO_LOG (p_event_tp IN VARCHAR2, p_event_info IN CLOB);
END DNET$Document;
/


GRANT EXECUTE ON USS_RNSP.DNET$DOCUMENT TO DNET_PROXY
/

GRANT EXECUTE ON USS_RNSP.DNET$DOCUMENT TO II01RC_USS_RNSP_WEB
/


/* Formatted on 8/12/2025 5:58:00 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_RNSP.DNET$DOCUMENT
IS
    --=============================================--
    PROCEDURE Updatexmlsqllog (p_Lxs_Pkg_Name    VARCHAR2,
                               p_Lxs_Type_Name   VARCHAR2,
                               p_Lxs_Xml         CLOB)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        UPDATE Logxmlsql Ddd
           SET Ddd.Lxs_Xml = p_Lxs_Xml
         WHERE     Lxs_Pkg_Name = p_Lxs_Pkg_Name
               AND Lxs_Type_Name = p_Lxs_Type_Name
               AND Lxs_Com_Wu = Uss_rnsp_Context.Getcontext ('uid')
               AND Ddd.Lxs_Xml IS NULL;

        COMMIT;
    END;

    --=============================================--
    --                    ЗБЕРЕЖЕННЯ атрибутів документів
    --=============================================--
    PROCEDURE Save_Document_attrs (p_rnd_Id     IN rn_Document.rnd_Id%TYPE,
                                   p_rn_attrs   IN CLOB)
    IS
        l_Com_Wu              Appeal.Com_Wu%TYPE;
        l_Com_Org             Appeal.Com_Org%TYPE;
        l_Hs_Id               NUMBER;
        l_New_Id              NUMBER;

        l_Err_Cnt             NUMBER;
        l_rn_Document_attrs   t_rn_Document_attrs;
    BEGIN
        DBMS_SESSION.set_nls ('NLS_NUMERIC_CHARACTERS', '''. ''');

        l_Com_Wu := Uss_rnsp_Context.Getcontext ('uid');
        l_Com_Org := Uss_rnsp_Context.Getcontext ('org');
        l_Hs_Id := Tools.Gethistsessiona;

        -- +++++++++++++++++++++++++++   ДОКУМЕНТИ +++++++++++++++++++++++++++
        IF /*l_Ap_St IN (Api$appeal.c_Ap_St_New, Api$appeal.c_Ap_St_Reg_In_Work, Api$appeal.c_Ap_St_Wait_Docs, Api$appeal.c_Ap_St_Attr)
           AND*/
           p_rn_attrs IS NOT NULL
        THEN
            --Парсинг документів
            EXECUTE IMMEDIATE Type2xmltable (Package_Name,
                                             't_rn_Document_Attrs',
                                             TRUE,
                                             TRUE)
                BULK COLLECT INTO l_rn_Document_attrs
                USING p_rn_attrs;

            Updatexmlsqllog (Package_Name, 't_rn_Document_attrs', p_rn_attrs);
        END IF;


        FOR Rec
            IN (SELECT a.Deleted,
                       NVL (a.rnda_Id, Da.rnda_Id)     AS rnda_Id,
                       a.rnda_Nda,
                       a.rnda_Val_Int                  AS Val_Int,
                       a.rnda_Val_Dt                   AS Val_Dt,
                       a.rnda_Val_String               AS Val_String,
                       a.rnda_Val_Id                   AS Val_Id,
                       a.rnda_Val_Sum                  AS Val_Sum
                  FROM TABLE (l_rn_Document_attrs)  a
                       LEFT JOIN rn_Document_Attr Da
                           ON     Da.rnda_rnd = p_rnd_Id
                              AND a.rnda_Nda = Da.rnda_Nda
                              AND Da.History_Status = 'A')
        LOOP
            IF Rec.Deleted = 1 AND Rec.rnda_Id > 0
            THEN
                --Видаляємо атрибут
                Api$Document.Delete_Document_Attr (p_Id => Rec.rnda_Id);
            ELSE
                Api$Document.Save_Document_Attr (
                    p_rnda_Id           => Rec.rnda_Id,
                    p_rnda_rnd          => p_rnd_Id,
                    p_rnda_Nda          => Rec.rnda_Nda,
                    p_rnda_Val_Int      => Rec.Val_Int,
                    p_rnda_Val_Dt       => Rec.Val_Dt,
                    p_rnda_Val_String   => Rec.Val_String,
                    p_rnda_Val_Id       => Rec.Val_Id,
                    p_rnda_Val_Sum      => Rec.Val_Sum,
                    p_New_Id            => l_New_Id);
            END IF;
        END LOOP;
    /*
      EXCEPTION
        WHEN api$Document.Ex_Opt_Block_Viol THEN
          Raise_Application_Error(-20000, Ikis_Message_Util.Get_Message(Msg_Opt_Block_Viol));
    */
    END;

    --=============================================--
    --                    СТВОРЕННЯ нового документу
    --=============================================--

    PROCEDURE Save_Doc (p_rnd_Id      IN rn_Document.rnd_Id%TYPE,
                        p_rnd_Rnspm   IN rn_Document.Rnd_Rnspm%TYPE,
                        p_rnd_Ndt     IN rn_Document.rnd_Ndt%TYPE,
                        p_rnd_Doc     IN rn_Document.rnd_Doc%TYPE,
                        p_rnd_Dh      IN rn_Document.rnd_Dh%TYPE,
                        p_rnd_St      IN rn_Document.Rnd_St%TYPE,
                        p_rn_attrs    IN CLOB)
    IS
        l_Com_Wu              Appeal.Com_Wu%TYPE;
        l_Com_Org             Appeal.Com_Org%TYPE;
        l_Hs_Id               NUMBER;
        l_New_Id              NUMBER := p_rnd_Id;
        l_New_rnda_Id         NUMBER;

        l_Err_Cnt             NUMBER;
        l_rn_Document_attrs   t_rn_Document_attrs;
    BEGIN
        l_Com_Wu := Uss_rnsp_Context.Getcontext ('uid');
        l_Com_Org := Uss_rnsp_Context.Getcontext ('org');
        l_Hs_Id := Tools.Gethistsessiona;

        api$document.Save_Document (p_rnd_Id      => p_rnd_Id,
                                    p_rnd_Rnspm   => p_rnd_Rnspm,
                                    p_rnd_Ndt     => p_rnd_Ndt,
                                    p_rnd_Doc     => p_rnd_Doc,
                                    p_rnd_St      => p_rnd_St,
                                    p_New_Id      => l_New_Id,
                                    p_Com_Wu      => l_Com_Wu,
                                    p_rnd_Dh      => p_rnd_Dh);

        -- +++++++++++++++++++++++++++   ДОКУМЕНТИ +++++++++++++++++++++++++++
        IF /*l_Ap_St IN (Api$appeal.c_Ap_St_New, Api$appeal.c_Ap_St_Reg_In_Work, Api$appeal.c_Ap_St_Wait_Docs, Api$appeal.c_Ap_St_Attr)
           AND*/
           p_rn_attrs IS NOT NULL
        THEN
            --Парсинг документів
            EXECUTE IMMEDIATE Type2xmltable (Package_Name,
                                             't_rn_Document_Attrs',
                                             TRUE,
                                             TRUE)
                BULK COLLECT INTO l_rn_Document_attrs
                USING p_rn_attrs;

            Updatexmlsqllog (Package_Name, 't_rn_Document_attrs', p_rn_attrs);
        END IF;


        FOR Rec
            IN (SELECT a.Deleted,
                       NVL (a.rnda_Id, Da.rnda_Id)     AS rnda_Id,
                       a.rnda_Nda,
                       a.rnda_Val_Int                  AS Val_Int,
                       a.rnda_Val_Dt                   AS Val_Dt,
                       a.rnda_Val_String               AS Val_String,
                       a.rnda_Val_Id                   AS Val_Id,
                       a.rnda_Val_Sum                  AS Val_Sum
                  FROM TABLE (l_rn_Document_attrs)  a
                       LEFT JOIN rn_Document_Attr Da
                           ON     Da.rnda_rnd = p_rnd_Id
                              AND a.rnda_Nda = Da.rnda_Nda
                              AND Da.History_Status = 'A')
        LOOP
            IF Rec.Deleted = 1 AND Rec.rnda_Id > 0
            THEN
                --Видаляємо атрибут
                Api$Document.Delete_Document_Attr (p_Id => Rec.rnda_Id);
            ELSE
                Api$Document.Save_Document_Attr (
                    p_rnda_Id           => Rec.rnda_Id,
                    p_rnda_rnd          => l_New_Id,
                    p_rnda_Nda          => Rec.rnda_Nda,
                    p_rnda_Val_Int      => Rec.Val_Int,
                    p_rnda_Val_Dt       => Rec.Val_Dt,
                    p_rnda_Val_String   => Rec.Val_String,
                    p_rnda_Val_Id       => Rec.Val_Id,
                    p_rnda_Val_Sum      => Rec.Val_Sum,
                    p_New_Id            => l_New_rnda_Id);
            END IF;
        END LOOP;
    /*
      EXCEPTION
        WHEN api$Document.Ex_Opt_Block_Viol THEN
          Raise_Application_Error(-20000, Ikis_Message_Util.Get_Message(Msg_Opt_Block_Viol));
    */
    END;


    -- info:   Выбор информации об документах в обращении
    -- params: p_ap_id - ідентифікатор обращения
    -- note:
    PROCEDURE Get_Documents (p_Rnspm_Id NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT d.rnd_Id,
                   d.rnd_Ndt,
                   t.Ndt_Name_Short
                       AS rnd_Ndt_Name,
                   d.rnd_Doc,
                   d.rnd_App,
                   d.rnd_rnspm,
                   d.rnd_st,
                   p.App_Ln || ' ' || p.App_Fn || ' ' || p.App_Mn
                       AS Rnd_App_Name,
                   --серія та номер документа
                    (SELECT a.rnda_Val_String
                       FROM rn_Document_Attr  a
                            JOIN Uss_Ndi.v_Ndi_Document_Attr n
                                ON     a.rnda_Nda = n.Nda_Id
                                   AND n.Nda_Class = 'DSN'
                      WHERE a.rnda_rnd = d.rnd_Id AND a.History_Status = 'A')
                       AS rnd_Seria_Num,
                   d.rnd_Dh,
                   d.rnd_Dh
                       AS rnd_Dh_Old,
                   s.aps_nst,
                   (SELECT MAX (z.DIC_NAME)
                      FROM uss_ndi.V_DDN_RNSP_RND_ST z
                     WHERE z.DIC_VALUE = d.rnd_st)
                       AS rnd_st_name
              /*           (SELECT COUNT(*) FROM rn_Document_Attr z WHERE z.rnda_rnd = d.rnd_id AND z.history_status = 'A'
                                 AND z.rnda_val_int IS NOT NULL OR z.rnda_val_sum IS NOT NULL OR z.rnda_val_id IS not NULL OR z.rnda_val_dt IS NOT NULL OR z.rnda_val_string IS NOT NULL
                         ) AS Is_Attributed*/
              FROM rn_Document  d
                   LEFT JOIN Uss_Ndi.v_Ndi_Document_Type t
                       ON d.rnd_Ndt = t.Ndt_Id
                   LEFT JOIN Ap_Person p ON d.rnd_App = p.App_Id
                   LEFT JOIN ap_service s ON (s.aps_id = d.rnd_aps)
             WHERE     d.rnd_rnspm = p_Rnspm_Id
                   AND d.rnd_ap IS NULL
                   AND d.History_Status = 'A';
    END;

    ----------------------------------------
    -- info:   Выбор информации об документах (атрибуты)
    -- params: p_ap_id - ідентифікатор обращения
    -- note:
    PROCEDURE Get_Documents_Attr (p_Rnspm_Id NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
              SELECT rnda.rnda_Id,
                     rnda.rnda_rnd,
                     rnda.rnda_Nda,
                     rnda.rnda_Val_Int,
                     rnda.rnda_Val_Dt,
                     rnda.rnda_Val_String,
                     rnda.rnda_Val_Id,
                     rnda.rnda_Val_Sum,
                     Nda.Nda_Id,
                     Nda.Nda_Name,
                     Nda.Nda_Is_Key,
                     Nda.Nda_Ndt,
                     Nda.Nda_Order,
                     Nda.Nda_Pt,
                     Nda.Nda_Is_Req,
                     Nda.Nda_Def_Value,
                     Nda.Nda_Can_Edit,
                     Nda.Nda_Need_Show,
                     Pt.Pt_Id,
                     Pt.Pt_Code,
                     Pt.Pt_Name,
                     Pt.Pt_Ndc,
                     Pt.Pt_Edit_Type,
                     Pt.Pt_Data_Type,
                     --CASE WHEN rnda.rnda_apda IS NOT NULL THEN 'T' ELSE 'F' END AS is_Disabled,
                     CASE WHEN nda.nda_can_edit = 'T' THEN 'T' ELSE 'F' END    AS is_Disabled
                FROM rn_Document rnd
                     JOIN rn_Document_Attr rnda
                         ON     rnda.rnda_rnd = rnd.rnd_Id
                            AND rnda.History_Status = 'A'
                     JOIN Uss_Ndi.v_Ndi_Document_Attr Nda
                         ON Nda.Nda_Id = rnda.rnda_Nda
                     JOIN Uss_Ndi.v_Ndi_Param_Type Pt ON Pt.Pt_Id = Nda.Nda_Pt
               WHERE     rnd.rnd_rnspm = p_Rnspm_Id
                     AND rnd.rnd_ap IS NULL
                     AND rnd.History_Status = 'A'
            ORDER BY Nda.Nda_Order;
    END;

    -- info:   Выбор информации об документах (файлы)
    -- params: p_ap_id - ідентифікатор обращения
    -- note:
    PROCEDURE Get_Documents_Files (p_Rnspm_Id       NUMBER,
                                   p_Res        OUT SYS_REFCURSOR)
    IS
    BEGIN
        Uss_Doc.Api$documents.Clear_Tmp_Work_Ids;

        INSERT INTO Uss_Doc.Tmp_Work_Ids (x_Id)
            SELECT DISTINCT rnd_Dh
              FROM rn_Document d
             WHERE     d.rnd_rnspm = p_Rnspm_Id
                   AND d.rnd_ap IS NULL
                   AND History_Status = 'A';

        --отримуємо дані файлів з електронного архіву
        Uss_Doc.Api$documents.Get_Attachments (p_Doc_Id        => NULL,
                                               p_Dh_Id         => NULL,
                                               p_Res           => p_Res,
                                               p_Params_Mode   => 3);
    END;

    -- документи не по зверненням по картці рнсп
    PROCEDURE GET_DOC_LIST (p_Rnspm_Id   IN     NUMBER,
                            DOC_CUR         OUT SYS_REFCURSOR,
                            ATTR_CUR        OUT SYS_REFCURSOR,
                            FILES_CUR       OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.WriteMsg ('DNET$Document.' || $$PLSQL_UNIT);
        Get_Documents (p_Rnspm_Id => p_Rnspm_Id, p_Res => Doc_Cur);
        Get_Documents_Attr (p_Rnspm_Id => p_Rnspm_Id, p_Res => Attr_Cur);
        Get_Documents_Files (p_Rnspm_Id => p_Rnspm_Id, p_Res => Files_Cur);
    END;


    -- Логування при підпису
    PROCEDURE WRITE_CRYPTO_LOG (p_event_tp IN VARCHAR2, p_event_info IN CLOB)
    IS
        l_id   NUMBER;
    BEGIN
        l_id :=
            IKIS_SYSWEB.write_crypto_log (p_event_tp,
                                          p_event_info,
                                          tools.GetCurrWu);
    END;
END DNET$Document;
/