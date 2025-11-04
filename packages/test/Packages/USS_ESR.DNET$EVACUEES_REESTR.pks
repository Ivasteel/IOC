/* Formatted on 8/12/2025 5:48:27 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.DNET$EVACUEES_REESTR
IS
    -- Author  : KELATEV
    -- Created : 29.01.2024 17:35:19
    -- Purpose : Реєстр евакуйованих осіб

    PROCEDURE Get_Journal (                   --p_Ser_Id            IN NUMBER,
                                              --p_Ser_If            IN NUMBER,
    p_Ser_Num             IN     VARCHAR2,
    p_Ser_Pib             IN     VARCHAR2,
    p_Ser_Birth_Dt_From   IN     DATE,
    p_Ser_Birth_Dt_To     IN     DATE,
    p_Ser_Document        IN     VARCHAR2,
    p_Ser_Numident        IN     VARCHAR2,
    p_Ser_Live_Address    IN     VARCHAR2,
    p_Ser_Mob_Phone       IN     VARCHAR2,
    p_Ser_Notes           IN     VARCHAR2,
    --p_Ser_Sc            IN NUMBER,

    Res_Cur                  OUT SYS_REFCURSOR);

    FUNCTION Get_Dynamic_Value (p_Col_Name      IN VARCHAR2,
                                p_Col_Data_Tp   IN VARCHAR2,
                                p_Col_Scale     IN NUMBER,
                                p_Ser_Id        IN NUMBER)
        RETURN VARCHAR2;

    PROCEDURE Get_Inspector_Card (p_Ser_Id   IN     NUMBER,
                                  Res_Cur       OUT SYS_REFCURSOR);

    -- #99513: видалення запису
    PROCEDURE delete_Card (p_ser_id IN NUMBER);
END Dnet$evacuees_Reestr;
/


GRANT EXECUTE ON USS_ESR.DNET$EVACUEES_REESTR TO DNET_PROXY
/

GRANT EXECUTE ON USS_ESR.DNET$EVACUEES_REESTR TO II01RC_USS_ESR_WEB
/


/* Formatted on 8/12/2025 5:49:30 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.DNET$EVACUEES_REESTR
IS
    --=================================================================
    PROCEDURE Get_Journal (                   --p_Ser_Id            IN NUMBER,
                                              --p_Ser_If            IN NUMBER,
    p_Ser_Num             IN     VARCHAR2,
    p_Ser_Pib             IN     VARCHAR2,
    p_Ser_Birth_Dt_From   IN     DATE,
    p_Ser_Birth_Dt_To     IN     DATE,
    p_Ser_Document        IN     VARCHAR2,
    p_Ser_Numident        IN     VARCHAR2,
    p_Ser_Live_Address    IN     VARCHAR2,
    p_Ser_Mob_Phone       IN     VARCHAR2,
    p_Ser_Notes           IN     VARCHAR2,
    --p_Ser_Sc            IN NUMBER,

    Res_Cur                  OUT SYS_REFCURSOR)
    IS
        l_Sql   CLOB;
    BEGIN
        l_Sql := 'SELECT t.*,
                     if_load_dt,
                     if_name
                FROM Src_Evacuees_Reestr t
                left join import_files if on (if.if_id = t.ser_if)
               WHERE 1 = 1 #
               ORDER BY Ser_If
               FETCH FIRST 502 ROWS ONLY';

        Api$search.Init (l_Sql);
        --Api$search.And_('Ser_Id', 'LIKE', p_Val_Str => p_Ser_Id);
        --Api$search.And_('Ser_If', 'LIKE', p_Val_Str => p_Ser_If);
        Api$search.And_ ('Ser_Num', 'LIKE', p_Val_Str => p_Ser_Num);
        Api$search.And_ ('Ser_Pib', 'LIKE', p_Val_Str => p_Ser_Pib);
        Api$search.And_ ('Ser_Birth_Dt',
                         '>=',
                         p_Val_Dt   => p_Ser_Birth_Dt_From);
        Api$search.And_ ('Ser_Birth_Dt', '<=', p_Val_Dt => p_Ser_Birth_Dt_To);
        Api$search.And_ ('Ser_Document', 'LIKE', p_Val_Str => p_Ser_Document);
        Api$search.And_ ('Ser_Numident', 'LIKE', p_Val_Str => p_Ser_Numident);
        Api$search.And_ ('Ser_Live_Address',
                         'LIKE',
                         p_Val_Str   => p_Ser_Live_Address);
        Api$search.And_ ('Ser_Mob_Phone',
                         'LIKE',
                         p_Val_Str   => p_Ser_Mob_Phone);
        Api$search.And_ ('Ser_Notes', 'LIKE', p_Val_Str => p_Ser_Notes);
        --Api$search.And_('Ser_Sc', 'LIKE', p_Val_Str => p_Ser_Sc);

        Res_Cur := Api$search.Exec;
    END;

    --=================================================================
    FUNCTION Get_Dynamic_Value (p_Col_Name      IN VARCHAR2,
                                p_Col_Data_Tp   IN VARCHAR2,
                                p_Col_Scale     IN NUMBER,
                                p_Ser_Id        IN NUMBER)
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
                         FROM uss_esr.SRC_EVACUEES_REESTR d
                        WHERE d.Ser_Id = :id'
            INTO l_Res
            USING p_Ser_Id;

        RETURN l_Res;
    END;

    --=================================================================
    PROCEDURE Get_Inspector_Card (p_Ser_Id   IN     NUMBER,
                                  Res_Cur       OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN Res_Cur FOR
              SELECT t.Comments                      AS NAME,
                     Get_Dynamic_Value (t.Column_Name,
                                        Ct.Data_Type,
                                        Ct.Data_Scale,
                                        p_Ser_Id)    AS VALUE
                FROM All_Col_Comments t
                     JOIN All_Tab_Columns Ct
                         ON     Ct.Table_Name = t.Table_Name
                            AND Ct.Column_Name = t.Column_Name
               WHERE t.Table_Name = UPPER ('SRC_EVACUEES_REESTR')
            ORDER BY Ct.Column_Id;
    END;

    -- #99513: видалення запису
    PROCEDURE delete_Card (p_ser_id IN NUMBER)
    IS
    BEGIN
        DELETE FROM SRC_EVACUEES_REESTR t
              WHERE t.ser_id = p_ser_id;
    END;
END Dnet$evacuees_Reestr;
/