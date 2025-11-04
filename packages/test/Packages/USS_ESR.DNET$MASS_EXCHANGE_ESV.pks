/* Formatted on 8/12/2025 5:48:27 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.DNET$MASS_EXCHANGE_ESV
IS
    -- Author  : BOGDAN
    -- Created : 11.10.2024 11:44:34
    -- Purpose : Рядки вивантаження ЄСВ ('ESV')

    FUNCTION Get_Dynamic_Value (p_Col_Name      IN VARCHAR2,
                                p_Col_Data_Tp   IN VARCHAR2,
                                p_Col_Scale     IN NUMBER,
                                p_Meur_Id       IN NUMBER)
        RETURN VARCHAR2;

    PROCEDURE Get_Packet_Card (p_Me_Id           IN     NUMBER,
                               p_Meur_numident   IN     VARCHAR2,
                               p_Meur_Ln         IN     VARCHAR2,
                               p_Meur_Fn         IN     VARCHAR2,
                               p_Meur_Mn         IN     VARCHAR2,
                               Res_Cur              OUT SYS_REFCURSOR);

    PROCEDURE Get_Row_Card (p_Meur_Id IN NUMBER, Insp_Cur OUT SYS_REFCURSOR);
END Dnet$mass_Exchange_Esv;
/


GRANT EXECUTE ON USS_ESR.DNET$MASS_EXCHANGE_ESV TO DNET_PROXY
/

GRANT EXECUTE ON USS_ESR.DNET$MASS_EXCHANGE_ESV TO II01RC_USS_ESR_WEB
/


/* Formatted on 8/12/2025 5:49:30 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.DNET$MASS_EXCHANGE_ESV
IS
    FUNCTION Get_Dynamic_Value (p_Col_Name      IN VARCHAR2,
                                p_Col_Data_Tp   IN VARCHAR2,
                                p_Col_Scale     IN NUMBER,
                                p_Meur_Id       IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Res   VARCHAR2 (4000);
    BEGIN
        EXECUTE IMMEDIATE   'SELECT '
                         || CASE
                                WHEN     p_Col_Data_Tp = 'NUMBER'
                                     AND p_Col_Scale IS NOT NULL
                                     AND p_Col_Scale > 0
                                THEN
                                       'to_char('
                                    || p_Col_Name
                                    || ', ''FM9G999G999G999G999G990D00'', ''NLS_NUMERIC_CHARACTERS='''','''''''''')'
                                WHEN p_Col_Data_Tp = 'DATE'
                                THEN
                                       'to_char('
                                    || p_Col_Name
                                    || ', ''DD.MM.YYYY'')'
                                ELSE
                                    p_Col_Name
                            END
                         || '
                         FROM me_esv_unload_rows d
                        WHERE d.Meur_id = :id'
            INTO l_Res
            USING p_Meur_Id;

        RETURN l_Res;
    END;

    -- Картка пакету
    PROCEDURE Get_Packet_Card (p_Me_Id           IN     NUMBER,
                               p_Meur_numident   IN     VARCHAR2,
                               p_Meur_Ln         IN     VARCHAR2,
                               p_Meur_Fn         IN     VARCHAR2,
                               p_Meur_Mn         IN     VARCHAR2,
                               Res_Cur              OUT SYS_REFCURSOR)
    IS
        l_Org_To   NUMBER := Tools.Getcurrorgto;
        l_Org      NUMBER := Tools.Getcurrorg;
    BEGIN
        OPEN Res_Cur FOR
            SELECT /*+ FIRST_ROWS(502) */
                   t.*, c.pc_num
              FROM v_me_esv_unload_rows  t
                   LEFT JOIN personalcase c ON (c.pc_id = t.meur_pc)
             WHERE     Meur_Me = p_Me_Id
                   AND (   p_Meur_numident IS NULL
                        OR t.meur_numident LIKE p_Meur_numident || '%')
                   AND (   p_Meur_Ln IS NULL
                        OR UPPER (t.Meur_Ln) LIKE UPPER (p_Meur_Ln) || '%')
                   AND (   p_Meur_Fn IS NULL
                        OR UPPER (t.Meur_nm) LIKE UPPER (p_Meur_Fn) || '%')
                   AND (   p_Meur_Mn IS NULL
                        OR UPPER (t.meur_ftn) LIKE UPPER (p_Meur_Mn) || '%')
             FETCH FIRST 502 ROWS ONLY;
    END;

    -- Форма "Дані вивантаження ЄСВ"
    PROCEDURE Get_Row_Card (p_Meur_Id IN NUMBER, Insp_Cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN Insp_Cur FOR
              SELECT t.Comments                       AS NAME,
                     Get_Dynamic_Value (t.Column_Name,
                                        Ct.Data_Type,
                                        Ct.Data_Scale,
                                        p_Meur_Id)    AS VALUE
                FROM All_Col_Comments t
                     JOIN All_Tab_Columns Ct
                         ON     Ct.Table_Name = t.Table_Name
                            AND Ct.Column_Name = t.Column_Name
               WHERE     t.Table_Name = UPPER ('me_esv_unload_rows')
                     AND NOT EXISTS
                             (SELECT *
                                FROM All_Cons_Columns z
                               WHERE     z.Table_Name = t.Table_Name
                                     AND z.Column_Name = t.Column_Name)
            ORDER BY Ct.Column_Id;
    END;
BEGIN
    NULL;
END Dnet$mass_Exchange_Esv;
/