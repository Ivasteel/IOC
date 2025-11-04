/* Formatted on 8/12/2025 5:48:27 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.DNET$MASS_EXCHANGE_DPS
IS
    -- Author  : KELATEV
    -- Created : 07.02.2024 16:36:54
    -- Purpose : Верифікація ДЦЗ


    FUNCTION Get_Dynamic_Value (p_Col_Name      IN VARCHAR2,
                                p_Col_Data_Tp   IN VARCHAR2,
                                p_Col_Scale     IN NUMBER,
                                p_Memr_Id       IN NUMBER)
        RETURN VARCHAR2;

    -- Картка пакету
    PROCEDURE Get_Packet_Card (p_Me_Id             IN     NUMBER,
                               p_Pc_Num            IN     VARCHAR2,
                               p_Mprr_n_Id         IN     VARCHAR2,
                               p_Mprr_Surname      IN     VARCHAR2,
                               p_Mprr_Name         IN     VARCHAR2,
                               p_Mprr_Patronymic   IN     VARCHAR2,
                               p_Org_Id            IN     NUMBER,
                               Res_Cur                OUT SYS_REFCURSOR);


    -- Вкладка ЕОС "Верифікація в ДЦЗ"
    PROCEDURE Get_Packet_Card_Pc (p_Pc_Id   IN     NUMBER,
                                  Res_Cur      OUT SYS_REFCURSOR);

    -- Кнопка "Сформувати файл"
    PROCEDURE Generate_File (p_Me_Id IN NUMBER, p_Jb_Id OUT NUMBER);

    -- Кнопка "Скасувати"
    PROCEDURE Reject_Packet (p_Me_Id IN NUMBER);


    -- Форма "Дані верифікації з ДЦЗ"
    PROCEDURE Get_Row_Card (p_Mprr_Id   IN     NUMBER,
                            Insp_Cur       OUT SYS_REFCURSOR,
                            Row_Cur        OUT SYS_REFCURSOR);

    -- Форма "Картка рішення"
    PROCEDURE Get_Result_Card (p_Mpsr_Id   IN     NUMBER,
                               Res_Cur        OUT SYS_REFCURSOR);
END Dnet$mass_Exchange_Dps;
/


GRANT EXECUTE ON USS_ESR.DNET$MASS_EXCHANGE_DPS TO DNET_PROXY
/

GRANT EXECUTE ON USS_ESR.DNET$MASS_EXCHANGE_DPS TO II01RC_USS_ESR_WEB
/


/* Formatted on 8/12/2025 5:49:30 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.DNET$MASS_EXCHANGE_DPS
IS
    FUNCTION Get_Dynamic_Value (p_Col_Name      IN VARCHAR2,
                                p_Col_Data_Tp   IN VARCHAR2,
                                p_Col_Scale     IN NUMBER,
                                p_Memr_Id       IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Res   VARCHAR2 (4000);
    BEGIN
        EXECUTE IMMEDIATE   'SELECT '
                         || CASE
                                WHEN p_Col_Name = 'MPRR_ST'
                                THEN
                                    '(select dic_name from uss_ndi.v_ddn_memr_st z where z.dic_value = d.mprr_st)'
                                WHEN p_Col_Name = 'MPRR_DOCTYPE'
                                THEN
                                    'CASE WHEN d.MPRR_DOCTYPE = 99 THEN
                               ''Інший документ''
                               ELSE
                                 (select ndt_name from uss_ndi.v_ndi_document_type z where z.ndt_id = d.MPRR_DOCTYPE)
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
                         FROM Me_Dps_Request_Rows d
                        WHERE d.Mprr_id = :id'
            INTO l_Res
            USING p_Memr_Id;

        RETURN l_Res;
    END;


    -- Картка пакету
    PROCEDURE Get_Packet_Card (p_Me_Id             IN     NUMBER,
                               p_Pc_Num            IN     VARCHAR2,
                               p_Mprr_n_Id         IN     VARCHAR2,
                               p_Mprr_Surname      IN     VARCHAR2,
                               p_Mprr_Name         IN     VARCHAR2,
                               p_Mprr_Patronymic   IN     VARCHAR2,
                               p_Org_Id            IN     NUMBER,
                               Res_Cur                OUT SYS_REFCURSOR)
    IS
        l_Org_To   NUMBER := Tools.Getcurrorgto;
        l_Org      NUMBER := Tools.Getcurrorg;
    BEGIN
        OPEN Res_Cur FOR
            SELECT /*+ FIRST_ROWS(100) */
                   t.Mprr_Id,
                   t.Mprr_Pc,
                   t.Mprr_n_Id,
                   t.Mprr_Surname,
                   t.Mprr_Name,
                   t.Mprr_Patronymic,
                   t.Mprr_St,
                   Pc.Pc_Num,
                   Uss_Person.Api$sc_Tools.Get_Vpo_Num (Pc.Pc_Sc)    AS Vpo_Num
              FROM v_Me_Dps_Request_Rows  t
                   JOIN v_Personalcase Pc ON Pc.Pc_Id = t.Mprr_Pc
             WHERE     Mprr_Me = p_Me_Id
                   AND (p_Pc_Num IS NULL OR Pc.Pc_Num LIKE p_Pc_Num || '%')
                   AND (   p_Mprr_n_Id IS NULL
                        OR t.Mprr_n_Id LIKE p_Mprr_n_Id || '%')
                   AND (   p_Mprr_Surname IS NULL
                        OR UPPER (t.Mprr_Surname) LIKE
                               UPPER (p_Mprr_Surname) || '%')
                   AND (   p_Mprr_Name IS NULL
                        OR UPPER (t.Mprr_Name) LIKE
                               UPPER (p_Mprr_Name) || '%')
                   AND (   p_Mprr_Patronymic IS NULL
                        OR UPPER (t.Mprr_Patronymic) LIKE
                               UPPER (p_Mprr_Patronymic) || '%')
                   AND (   (    l_Org_To IN (30, 40, 20)
                            AND (   p_Org_Id IS NULL
                                 OR p_Org_Id = 0
                                 OR Pc.Com_Org = p_Org_Id))
                        OR (    l_Org_To IN (31)
                            AND (   p_Org_Id IS NULL
                                 OR     p_Org_Id = 0
                                    AND Pc.Com_Org IN (SELECT * FROM Tmp_Org)
                                 OR Pc.Com_Org = p_Org_Id))
                        OR (    l_Org_To IN (21)
                            AND Pc.Com_Org IN
                                    (SELECT Org_Id
                                       FROM Opfu, Uss_Ndi.v_Ndi_Nsss2dszn
                                      WHERE     Org_St = 'A'
                                            AND Org_To = 32
                                            AND Org_Org = N2d_Org_Dszn
                                            AND N2d_Org_Nsss = l_Org))
                        OR (    l_Org_To NOT IN (30,
                                                 40,
                                                 31,
                                                 20,
                                                 21)
                            AND (Pc.Com_Org = l_Org)))
             FETCH FIRST 100 ROWS ONLY;
    END;

    -- Вкладка ЕОС "Верифікація в ДЦЗ" -- чи потрібно?
    PROCEDURE Get_Packet_Card_Pc (p_Pc_Id   IN     NUMBER,
                                  Res_Cur      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN Res_Cur FOR
              SELECT t.Mprr_Id,
                     t.Mprr_Pc,
                     t.Mprr_n_Id,
                     t.Mprr_Surname,
                     t.Mprr_Name,
                     t.Mprr_Patronymic,
                     e.Me_Month
                FROM v_Me_Dps_Request_Rows t
                     JOIN Mass_Exchanges e ON e.Me_Id = t.Mprr_Me
               WHERE Mprr_Pc = p_Pc_Id
            ORDER BY Me_Month DESC;
    END;

    -- Кнопка "Сформувати файл"
    PROCEDURE Generate_File (p_Me_Id IN NUMBER, p_Jb_Id OUT NUMBER)
    IS
    BEGIN
        Api$mass_Exchange.Make_Exchange_File (p_Me_Id, p_Jb_Id);
    END;

    -- Кнопка "Скасувати"
    PROCEDURE Reject_Packet (p_Me_Id IN NUMBER)
    IS
    BEGIN
        Api$mass_Exchange.Reject_Packet (p_Me_Id);
    END;

    -- Форма "Дані верифікації з ДЦЗ"
    PROCEDURE Get_Row_Card (p_Mprr_Id   IN     NUMBER,
                            Insp_Cur       OUT SYS_REFCURSOR,
                            Row_Cur        OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN Insp_Cur FOR
              SELECT t.Comments                       AS NAME,
                     Get_Dynamic_Value (t.Column_Name,
                                        Ct.Data_Type,
                                        Ct.Data_Scale,
                                        p_Mprr_Id)    AS VALUE
                FROM All_Col_Comments t
                     JOIN All_Tab_Columns Ct
                         ON     Ct.Table_Name = t.Table_Name
                            AND Ct.Column_Name = t.Column_Name
               WHERE     t.Table_Name = UPPER ('ME_DPS_REQUEST_ROWS')
                     AND NOT EXISTS
                             (SELECT *
                                FROM All_Cons_Columns z
                               WHERE     z.Table_Name = t.Table_Name
                                     AND z.Column_Name = t.Column_Name)
            ORDER BY Ct.Column_Id;

        OPEN Row_Cur FOR
            SELECT t.*,
                   D1.Dic_Name     AS Mpsr_Result_Name,
                   D2.Dic_Name     AS Mpsr_n_Close_Reason_Name,
                   D3.Dic_Name     AS Mpsr_Result_Income_Name
              FROM v_Me_Dps_Result_Rows  t
                   LEFT JOIN Uss_Ndi.v_Ddn_Mpsr_Result D1
                       ON D1.Dic_Value = t.Mpsr_Result
                   LEFT JOIN Uss_Ndi.v_Ddn_Mpsr_n_Close_Reason D2
                       ON D2.Dic_Value = t.Mpsr_n_Close_Reason
                   LEFT JOIN Uss_Ndi.v_Ddn_Mpsr_Result_Income D3
                       ON D3.Dic_Value = t.Mpsr_Result_Income
             WHERE t.Mpsr_Mprr = p_Mprr_Id;
    END;

    -- Форма "Картка рішення"
    PROCEDURE Get_Result_Card (p_Mpsr_Id   IN     NUMBER,
                               Res_Cur        OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN Res_Cur FOR
            SELECT t.*,
                   D1.Dic_Name     AS Mpsr_Result_Name,
                   D2.Dic_Name     AS Mpsr_n_Close_Reason_Name,
                   D3.Dic_Name     AS Mpsr_Result_Income_Name
              FROM v_Me_Dps_Result_Rows  t
                   LEFT JOIN Uss_Ndi.v_Ddn_Mpsr_Result D1
                       ON D1.Dic_Value = t.Mpsr_Result
                   LEFT JOIN Uss_Ndi.v_Ddn_Mpsr_n_Close_Reason D2
                       ON D2.Dic_Value = t.Mpsr_n_Close_Reason
                   LEFT JOIN Uss_Ndi.v_Ddn_Mpsr_Result_Income D3
                       ON D3.Dic_Value = t.Mpsr_Result_Income
             WHERE t.Mpsr_Id = p_Mpsr_Id;
    END;
BEGIN
    NULL;
END Dnet$mass_Exchange_Dps;
/