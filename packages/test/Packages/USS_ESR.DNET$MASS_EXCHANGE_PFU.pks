/* Formatted on 8/12/2025 5:48:27 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.DNET$MASS_EXCHANGE_PFU
IS
    -- Author  : BOGDAN
    -- Created : 08.05.2024 18:06:48
    -- Purpose : Верифікація ПФУ ('PFU_51', 'PFU_131', 'PFU_132')

    FUNCTION Get_Dynamic_Value (p_Col_Name      IN VARCHAR2,
                                p_Col_Data_Tp   IN VARCHAR2,
                                p_Col_Scale     IN NUMBER,
                                p_M3rr_Id       IN NUMBER)
        RETURN VARCHAR2;

    -- Картка пакету
    PROCEDURE Get_Packet_Card (p_Me_Id             IN     NUMBER,
                               p_M3rr_n_Id         IN     VARCHAR2,
                               p_M3rr_Surname      IN     VARCHAR2,
                               p_M3rr_Name         IN     VARCHAR2,
                               p_M3rr_Patronymic   IN     VARCHAR2,
                               Res_Cur                OUT SYS_REFCURSOR);

    -- Форма "Дані верифікації з ПФУ"
    PROCEDURE Get_Row_Card (p_M3rr_Id   IN     NUMBER,
                            Insp_Cur       OUT SYS_REFCURSOR,
                            Row_Cur        OUT SYS_REFCURSOR);

    -- Форма "Картка рішення"
    PROCEDURE Get_Result_Card (p_M3sr_Id   IN     NUMBER,
                               Res_Cur        OUT SYS_REFCURSOR);
END Dnet$mass_Exchange_Pfu;
/


GRANT EXECUTE ON USS_ESR.DNET$MASS_EXCHANGE_PFU TO DNET_PROXY
/

GRANT EXECUTE ON USS_ESR.DNET$MASS_EXCHANGE_PFU TO II01RC_USS_ESR_WEB
/


/* Formatted on 8/12/2025 5:49:31 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.DNET$MASS_EXCHANGE_PFU
IS
    FUNCTION Get_Dynamic_Value (p_Col_Name      IN VARCHAR2,
                                p_Col_Data_Tp   IN VARCHAR2,
                                p_Col_Scale     IN NUMBER,
                                p_M3rr_Id       IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Res   VARCHAR2 (4000);
    BEGIN
        EXECUTE IMMEDIATE   'SELECT '
                         || CASE
                                /*WHEN p_Col_Name = 'MDRR_ST' THEN
                                 '(select dic_name from uss_ndi.v_ddn_m3rr_st z where z.dic_value = d.mdrr_st)'*/
                                WHEN p_Col_Name = 'M3RR_DOC_TP'
                                THEN
                                    'CASE WHEN M3RR_DOC_TP = -1 THEN
                               ''Інший документ''
                               ELSE
                                 (select ndt_name from uss_ndi.v_ndi_document_type z where z.ndt_id = M3RR_DOC_TP)
                          END'
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
                         FROM ME_332VPO_REQUEST_ROWS d
                        WHERE d.M3rr_id = :id'
            INTO l_Res
            USING p_M3rr_Id;

        RETURN l_Res;
    END;

    -- Картка пакету
    PROCEDURE Get_Packet_Card (p_Me_Id             IN     NUMBER,
                               p_M3rr_n_Id         IN     VARCHAR2,
                               p_M3rr_Surname      IN     VARCHAR2,
                               p_M3rr_Name         IN     VARCHAR2,
                               p_M3rr_Patronymic   IN     VARCHAR2,
                               Res_Cur                OUT SYS_REFCURSOR)
    IS
        l_Org_To   NUMBER := Tools.Getcurrorgto;
        l_Org      NUMBER := Tools.Getcurrorg;
    BEGIN
        OPEN Res_Cur FOR
            SELECT /*+ FIRST_ROWS(502) */
                   t.*,
                   Uss_Person.Api$sc_Tools.Get_Vpo_Num (t.m3rr_sc)    AS Vpo_Num
              FROM v_Me_332vpo_Request_Rows t
             WHERE     M3rr_Me = p_Me_Id
                   AND (   p_M3rr_n_Id IS NULL
                        OR t.m3rr_numident LIKE p_M3rr_n_Id || '%')
                   AND (   p_M3rr_Surname IS NULL
                        OR UPPER (t.M3rr_Ln) LIKE
                               UPPER (p_M3rr_Surname) || '%')
                   AND (   p_M3rr_Name IS NULL
                        OR UPPER (t.M3rr_Fn) LIKE UPPER (p_M3rr_Name) || '%')
                   AND (   p_M3rr_Patronymic IS NULL
                        OR UPPER (t.m3rr_mn) LIKE
                               UPPER (p_M3rr_Patronymic) || '%')
             FETCH FIRST 502 ROWS ONLY;
    END;

    -- Форма "Дані верифікації з ПФУ"
    PROCEDURE Get_Row_Card (p_M3rr_Id   IN     NUMBER,
                            Insp_Cur       OUT SYS_REFCURSOR,
                            Row_Cur        OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN Insp_Cur FOR
              SELECT t.Comments                       AS NAME,
                     Get_Dynamic_Value (t.Column_Name,
                                        Ct.Data_Type,
                                        Ct.Data_Scale,
                                        p_M3rr_Id)    AS VALUE
                FROM All_Col_Comments t
                     JOIN All_Tab_Columns Ct
                         ON     Ct.Table_Name = t.Table_Name
                            AND Ct.Column_Name = t.Column_Name
               WHERE     t.Table_Name = UPPER ('ME_332VPO_REQUEST_ROWS')
                     AND NOT EXISTS
                             (SELECT *
                                FROM All_Cons_Columns z
                               WHERE     z.Table_Name = t.Table_Name
                                     AND z.Column_Name = t.Column_Name)
            ORDER BY Ct.Column_Id;

        OPEN Row_Cur FOR
            SELECT t.*,
                   uss_person.api$sc_tools.GET_PIB (t.m3sr_sc)    AS M3sr_Sc_Pib
              FROM v_Me_332vpo_Result_Rows t
             WHERE t.M3sr_M3rr = p_M3rr_Id;
    END;

    -- Форма "Картка рішення"
    PROCEDURE Get_Result_Card (p_M3sr_Id   IN     NUMBER,
                               Res_Cur        OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN Res_Cur FOR
            SELECT t.*,
                   uss_person.api$sc_tools.GET_PIB (t.m3sr_sc)    AS M3sr_Sc_Pib
              FROM v_Me_332VPO_Result_Rows t
             WHERE t.M3sr_Id = p_M3sr_Id;
    END;
BEGIN
    NULL;
END Dnet$mass_Exchange_Pfu;
/