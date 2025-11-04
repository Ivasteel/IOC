/* Formatted on 8/12/2025 6:10:44 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_RBM.DNET$DEMO
IS
    -- Author  : KELATEV
    -- Created : 24.02.2025 9:08:34
    -- Purpose :

    Package_Name   CONSTANT VARCHAR2 (100) := 'DNET$DEMO';

    --Атрибути докумена
    TYPE r_Document_Attr IS RECORD
    (
        Nda_Id        NUMBER,
        Val_String    VARCHAR2 (4000),
        Val_Int       INTEGER,
        Val_Dt        DATE,
        Val_Id        NUMBER,
        Val_Sum       NUMBER (18, 2)
    );

    TYPE t_Document_Attrs IS TABLE OF r_Document_Attr;

    --METHODS
    PROCEDURE Get_Demo_List (p_Res OUT SYS_REFCURSOR);

    PROCEDURE Save_Demo_Request (p_Nrd_Id IN NUMBER, p_Document IN CLOB);

    PROCEDURE Get_Demo_Info (p_Nrd_Id      IN     NUMBER,
                             p_Nrd_Res        OUT SYS_REFCURSOR,
                             p_Attrs_Res      OUT SYS_REFCURSOR);

    PROCEDURE Get_Demo_Request (p_Rdj_Id          NUMBER,
                                p_Rdj_Res     OUT SYS_REFCURSOR,
                                p_Attrs_Res   OUT SYS_REFCURSOR);

    PROCEDURE Delete_Demo_Request (p_Rdj_Id NUMBER);
END Dnet$demo;
/


GRANT EXECUTE ON IKIS_RBM.DNET$DEMO TO DNET_PROXY
/

GRANT EXECUTE ON IKIS_RBM.DNET$DEMO TO USS_ESR
/


/* Formatted on 8/12/2025 6:10:49 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_RBM.DNET$DEMO
IS
    ---------------------------------------------------------------------------
    -- Отримання параметрів запиту та відповіді
    -- #116917
    ---------------------------------------------------------------------------
    PROCEDURE Get_Demo_List (p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
              SELECT j.Rdj_Id,
                     n.Nrd_Name      AS Rdj_Nrd_Name,
                     j.Rdj_St,
                     St.Dic_Name     AS Rdj_St_Name,
                     r.Ur_Create_Dt,
                     r.Ur_Handle_Dt
                FROM Request_Demo_Journal      j,
                     Uss_Ndi.v_Ndi_Request_Demo n,
                     Uxp_Request               r,
                     Uss_Ndi.v_Ddn_Rdj_St      St
               WHERE     n.History_Status = 'A'
                     AND j.Rdj_Nrd = n.Nrd_Id
                     AND j.Rdj_Rn = r.Ur_Rn
                     AND j.Rdj_St <> 'H'
                     AND j.Rdj_St = St.Dic_Value
                     AND St.Dic_St = 'A'
            ORDER BY r.Ur_Create_Dt DESC;
    END;

    PROCEDURE Save_Attrs (p_Rn_Id       IN     NUMBER,
                          p_Doc_Attrs   IN OUT t_Document_Attrs)
    IS
        l_Rnp_Id       NUMBER;
        l_Rnpi_Id      NUMBER;

        l_Inn          Rn_Person.Rnp_Inn%TYPE;
        l_Doc_Number   Rn_Person.Rnp_Doc_Number%TYPE;
        l_Fn           Rnp_Identity_Info.Rnpi_Fn%TYPE;
        l_Ln           Rnp_Identity_Info.Rnpi_Ln%TYPE;
        l_Mn           Rnp_Identity_Info.Rnpi_Mn%TYPE;
    BEGIN
        FOR Rec IN (SELECT a.Nda_Id,
                           a.Val_Int,
                           a.Val_String,
                           n.Nda_Pt
                      FROM TABLE (p_Doc_Attrs)  a
                           JOIN Uss_Ndi.v_Ndi_Document_Attr n
                               ON     n.Nda_Id = a.Nda_Id
                                  AND n.History_Status = 'A'
                                  AND n.Nda_Pt IN (99,
                                                   125,
                                                   159,
                                                   160,
                                                   161))
        LOOP
            CASE Rec.Nda_Pt
                WHEN 99
                THEN
                    l_Inn := Rec.Val_String;
                WHEN 125
                THEN
                    l_Doc_Number := Rec.Val_String;
                WHEN 159
                THEN
                    l_Ln := Rec.Val_String;
                WHEN 160
                THEN
                    l_Fn := Rec.Val_String;
                WHEN 161
                THEN
                    l_Mn := Rec.Val_String;
                ELSE
                    NULL;
            END CASE;
        END LOOP;

        IF l_Inn IS NOT NULL OR l_Doc_Number IS NOT NULL
        THEN
            Api$request.Save_Rn_Person (p_Rnp_Id           => NULL,
                                        p_Rnp_Rn           => p_Rn_Id,
                                        p_Rnp_Sc           => NULL,
                                        p_Rnp_Inn          => l_Inn,
                                        p_Rnp_Ndt          => NULL,
                                        p_Rnp_Doc_Seria    => NULL,
                                        p_Rnp_Doc_Number   => l_Doc_Number,
                                        p_Rnp_Sc_Unique    => NULL,
                                        p_New_Id           => l_Rnp_Id);
        END IF;

        IF l_Fn IS NOT NULL OR l_Ln IS NOT NULL OR l_Mn IS NOT NULL
        THEN
            Api$request.Save_Rnp_Identity_Info (p_Rnpi_Id    => NULL,
                                                p_Rnpi_Rnp   => l_Rnp_Id,
                                                p_Rnpi_Rn    => p_Rn_Id,
                                                p_Rnpi_Fn    => l_Fn,
                                                p_Rnpi_Ln    => l_Ln,
                                                p_Rnpi_Mn    => l_Mn,
                                                p_New_Id     => l_Rnpi_Id);
        END IF;

        FOR Rec IN (SELECT a.Nda_Id,
                           a.Val_Int,
                           a.Val_Dt,
                           a.Val_String,
                           a.Val_Id,
                           a.Val_Sum,
                           n.Nda_Pt
                      FROM TABLE (p_Doc_Attrs)  a
                           JOIN Uss_Ndi.v_Ndi_Document_Attr n
                               ON     n.Nda_Id = a.Nda_Id
                                  AND n.History_Status = 'A'
                                  AND n.Nda_Pt NOT IN (99,
                                                       125,
                                                       159,
                                                       160,
                                                       161))
        LOOP
            IF    Rec.Val_Int IS NOT NULL
               OR Rec.Val_Sum IS NOT NULL
               OR Rec.Val_Id IS NOT NULL
               OR Rec.Val_Dt IS NOT NULL
               OR Rec.Val_String IS NOT NULL
            THEN
                Api$request.Save_Rn_Common_Info (
                    p_Rnc_Rn           => p_Rn_Id,
                    p_Rnc_Pt           => Rec.Nda_Pt,
                    p_Rnc_Val_Int      => Rec.Val_Int,
                    p_Rnc_Val_Sum      => Rec.Val_Sum,
                    p_Rnc_Val_Id       => Rec.Val_Id,
                    p_Rnc_Val_Dt       => Rec.Val_Dt,
                    p_Rnc_Val_String   => Rec.Val_String);
            END IF;
        END LOOP;
    END;

    ---------------------------------------------------------------------------
    -- Реєстрація запиту на
    -- #116917
    ---------------------------------------------------------------------------
    PROCEDURE Save_Demo_Request (p_Nrd_Id IN NUMBER, p_Document IN CLOB)
    IS
        l_Com_Wu      NUMBER;
        l_Hs_Id       NUMBER;

        l_Nrt_Id      NUMBER;
        l_Ur_Id       NUMBER;
        l_Rn_Id       NUMBER;
        l_Rdj_Id      NUMBER;

        l_Doc_Attrs   t_Document_Attrs;
    BEGIN
        l_Com_Wu := Ikis_Rbm_Context.Getcontext (    /*Ikis_Rbm_Context.Guid*/
                                                 'UID');
        l_Hs_Id := Ikis_Rbm.Tools.Gethistsession (l_Com_Wu);

        SELECT Nrd_Nrt
          INTO l_Nrt_Id
          FROM Uss_Ndi.v_Ndi_Request_Demo n
         WHERE n.Nrd_Id = p_Nrd_Id;

        Api$uxp_Request.Register_Out_Request (
            p_Ur_Plan_Dt     => SYSDATE,
            p_Ur_Urt         => NULL,
            p_Ur_Create_Wu   => l_Com_Wu,
            p_Ur_Ext_Id      => Api$demo.Generate_Req_Uid /*У звичайних запитах повинно передаватися СРКО*/
                                                         ,
            p_Ur_Body        => NULL,
            p_New_Id         => l_Ur_Id,
            p_Rn_Nrt         => l_Nrt_Id,
            p_Rn_Src         => 'USS',
            p_Rn_Hs_Ins      => l_Hs_Id,
            p_New_Rn_Id      => l_Rn_Id);

        --Реєструємо демо запит
        Api$demo.Save_Request (p_Rdj_Nrd   => p_Nrd_Id,
                               p_Rdj_Rn    => l_Rn_Id,
                               p_Rdj_Id    => l_Rdj_Id);

        --Переносимо атрибути із документу до запиту
        EXECUTE IMMEDIATE Type2xmltable (Package_Name,
                                         't_Document_Attrs',
                                         p_Version   => '2025-02-26')
            USING IN p_Document, OUT l_Doc_Attrs;

        Save_Attrs (p_Rn_Id => l_Rn_Id, p_Doc_Attrs => l_Doc_Attrs);
    END;

    ---------------------------------------------------------------------------
    -- Отримання інформації по демо запиту (поля+нотатки), для його створення
    -- #116917
    ---------------------------------------------------------------------------
    PROCEDURE Get_Demo_Info (p_Nrd_Id      IN     NUMBER,
                             p_Nrd_Res        OUT SYS_REFCURSOR,
                             p_Attrs_Res      OUT SYS_REFCURSOR)
    IS
        l_Ndt_Id   NUMBER;
    BEGIN
        SELECT n.Nrd_Ndt
          INTO l_Ndt_Id
          FROM Uss_Ndi.v_Ndi_Request_Demo n
         WHERE n.Nrd_Id = p_Nrd_Id;

        OPEN p_Nrd_Res FOR SELECT n.Nrd_Ndt, n.Nrd_Note
                             FROM Uss_Ndi.v_Ndi_Request_Demo n
                            WHERE n.Nrd_Id = p_Nrd_Id;

        OPEN p_Attrs_Res FOR
              SELECT DECODE (Pt.Pt_Data_Type, 'INTEGER', Nda.Nda_Def_Value)
                         Val_Int,
                     NULL
                         Val_Sum,
                     NULL
                         Val_Id,
                     NULL
                         Val_Dt,
                     NULL
                         Val_String,
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
                     c.Ndc_Code,
                     c.Ndc_Is_Global,
                     NVL (g.Nng_Name, 'Основна інформація')
                         AS Nng_Name
                FROM Uss_Ndi.v_Ndi_Document_Attr Nda
                     JOIN Uss_Ndi.v_Ndi_Param_Type Pt ON Pt.Pt_Id = Nda.Nda_Pt
                     LEFT JOIN Uss_Ndi.v_Ndi_Nda_Group g
                         ON (g.Nng_Id = Nda.Nda_Nng)
                     LEFT JOIN Uss_Ndi.v_Ndi_Dict_Config c
                         ON (c.Ndc_Id = Pt.Pt_Ndc)
               WHERE Nda.History_Status = 'A' AND Nda.Nda_Ndt = l_Ndt_Id
            ORDER BY NVL (g.Nng_Order, 0), Nda.Nda_Order;
    END;

    ---------------------------------------------------------------------------
    -- Отримання параметрів запиту та відповіді
    -- #116917
    ---------------------------------------------------------------------------
    PROCEDURE Get_Demo_Request (p_Rdj_Id          NUMBER,
                                p_Rdj_Res     OUT SYS_REFCURSOR,
                                p_Attrs_Res   OUT SYS_REFCURSOR)
    IS
        l_Rn_Id    NUMBER;
        l_Ndt_Id   NUMBER;
    BEGIN
        SELECT j.Rdj_Rn, n.Nrd_Ndt
          INTO l_Rn_Id, l_Ndt_Id
          FROM Request_Demo_Journal j, Uss_Ndi.v_Ndi_Request_Demo n
         WHERE Rdj_Id = p_Rdj_Id AND j.Rdj_Nrd = n.Nrd_Id;

        OPEN p_Rdj_Res FOR
            SELECT j.*,
                   n.Nrd_Name     AS Rdj_Nrd_Name,
                   n.Nrd_Note,
                   r.Ur_Create_Dt,
                   r.Ur_Handle_Dt
              FROM Request_Demo_Journal        j,
                   Uss_Ndi.v_Ndi_Request_Demo  n,
                   Uxp_Request                 r
             WHERE     Rdj_Id = p_Rdj_Id
                   AND j.Rdj_Nrd = n.Nrd_Id
                   AND j.Rdj_Rn = r.Ur_Rn;

        OPEN p_Attrs_Res FOR
              SELECT Val_Int,
                     Val_Sum,
                     Val_Id,
                     Val_Dt,
                     Val_String,
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
                     c.Ndc_Code,
                     c.Ndc_Is_Global,
                     NVL (g.Nng_Name, 'Основна інформація')     AS Nng_Name
                FROM Uss_Ndi.v_Ndi_Document_Attr Nda
                     JOIN Uss_Ndi.v_Ndi_Param_Type Pt ON Pt.Pt_Id = Nda.Nda_Pt
                     LEFT JOIN Uss_Ndi.v_Ndi_Nda_Group g
                         ON (g.Nng_Id = Nda.Nda_Nng)
                     LEFT JOIN Uss_Ndi.v_Ndi_Dict_Config c
                         ON (c.Ndc_Id = Pt.Pt_Ndc)
                     LEFT JOIN
                     (SELECT x_Pt_Id,
                             Val_String,
                             NULL     Val_Int,
                             NULL     Val_Sum,
                             NULL     Val_Id,
                             NULL     Val_Dt
                        FROM Rn_Person
                                 UNPIVOT (Val_String
                                     FOR x_Pt_Id
                                     IN (Rnp_Inn AS 99, Rnp_Doc_Number AS 125))
                       WHERE Rnp_Rn = l_Rn_Id
                      UNION ALL
                      SELECT x_Pt_Id,
                             Val_String,
                             NULL     Val_Int,
                             NULL     Val_Sum,
                             NULL     Val_Id,
                             NULL     Val_Dt
                        FROM Rnp_Identity_Info
                                 UNPIVOT (Val_String
                                     FOR x_Pt_Id
                                     IN (Rnpi_Ln AS 159,
                                         Rnpi_Fn AS 160,
                                         Rnpi_Mn AS 161))
                       WHERE Rnpi_Rn = l_Rn_Id
                      UNION ALL
                      SELECT i.Rnc_Pt             AS x_Pt_Id,
                             i.Rnc_Val_String     AS Val_String,
                             i.Rnc_Val_Int        AS Val_Int,
                             i.Rnc_Val_Sum        AS Val_Sum,
                             i.Rnc_Val_Id         AS Val_Id,
                             i.Rnc_Val_Dt         AS Val_Dt
                        FROM Rn_Common_Info i
                       WHERE i.Rnc_Rn = l_Rn_Id) t
                         ON Nda.Nda_Pt = x_Pt_Id
               WHERE Nda.History_Status = 'A' AND Nda.Nda_Ndt = l_Ndt_Id
            ORDER BY NVL (g.Nng_Order, 0), Nda.Nda_Order;
    END;

    ---------------------------------------------------------------------------
    -- Видалення запиту
    -- #116917
    ---------------------------------------------------------------------------
    PROCEDURE Delete_Demo_Request (p_Rdj_Id NUMBER)
    IS
    BEGIN
        Api$demo.Delete_Request (p_Rdj_Id => p_Rdj_Id);
    END;
END Dnet$demo;
/